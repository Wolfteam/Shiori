import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/notification_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const _dbFolder = 'shiori_notification_bloc_tests';

void main() {
  late final TelemetryService telemetryService;
  late final LoggingService loggingService;
  late final NotificationService notificationService;
  late final SettingsService settingsService;
  late final LocaleService localeService;
  late final GenshinService genshinService;
  late final DataService dataService;
  late final NotificationsBloc notificationsBloc;
  late final ResourceService resourceService;
  late final String dbPath;

  const defaultTitle = 'Notification title';
  const defaultBody = 'Notification body';
  const defaultNote = 'Notification note';
  const fragileResinKey = 'fragile-resin';
  const realmCurrency = 'realm-currency';
  const keqingKey = 'keqing';
  const primogemKey = 'primogem';

  final customNotificationCompletesAt = DateTime.now().add(const Duration(days: 1));

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    loggingService = MockLoggingService();
    telemetryService = MockTelemetryService();
    notificationService = MockNotificationService();
    settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    when(settingsService.useTwentyFourHoursFormat).thenReturn(true);
    when(settingsService.serverResetTime).thenReturn(AppServerResetTimeType.northAmerica);
    localeService = LocaleServiceImpl(settingsService);
    resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);
    dataService = DataServiceImpl(
      genshinService,
      CalculatorAscMaterialsServiceImpl(genshinService, resourceService),
      resourceService,
    );
    notificationsBloc = NotificationsBloc(dataService, notificationService, settingsService, telemetryService);

    return Future(() async {
      await genshinService.init(settingsService.language);
      dbPath = await getDbPath(_dbFolder);
      await dataService.initForTests(dbPath);
    });
  });

  tearDownAll(() {
    return Future(() async {
      await dataService.closeThemAll();
      await deleteDbFolder(dbPath);
    });
  });

  void checkState(
    NotificationState state,
    AppNotificationType type, {
    String title = defaultTitle,
    String body = defaultBody,
    String note = defaultNote,
    bool showNotification = true,
    bool checkKey = true,
    bool checkNote = false,
  }) {
    if (checkKey) {
      //By default the key starts at 0
      expect(state.key, 0, reason: 'A newly added notification should get key 0');
    }
    expect(state.title, title, reason: 'Notification state should carry the expected title (type=${type.name})');
    expect(state.body, body, reason: 'Notification state should carry the expected body (type=${type.name})');
    if (checkNote) {
      expect(state.note, note, reason: 'Notification state should carry the expected note (type=${type.name})');
    }
    expect(state.isTitleValid, true, reason: 'A non-empty title should be valid (type=${type.name})');
    expect(state.isBodyValid, true, reason: 'A non-empty body should be valid (type=${type.name})');
    expect(state.showNotification, showNotification, reason: 'Notification state should reflect showNotification=$showNotification (type=${type.name})');
    expect(state.type, type, reason: 'Notification state type should be ${type.name}, got ${state.type.name}');
    expect(state.images, isNotEmpty, reason: 'Notification state should offer selectable images (type=${type.name})');
    expect(state.images.any((el) => el.isSelected), true, reason: 'Exactly one image should be selected (type=${type.name})');
    for (final item in state.images) {
      checkItemKeyAndImage(item.itemKey, item.image);
    }
  }

  void checkNotDirtyFields(NotificationState state, {bool shouldBeDirty = true}) {
    expect(state.isTitleDirty, shouldBeDirty, reason: 'Title dirty flag should be $shouldBeDirty for this notification state');
    expect(state.isNoteDirty, shouldBeDirty, reason: 'Note dirty flag should be $shouldBeDirty for this notification state');
    expect(state.isBodyDirty, shouldBeDirty, reason: 'Body dirty flag should be $shouldBeDirty for this notification state');
  }

  NotificationBloc buildBloc() {
    return NotificationBloc(
      dataService,
      notificationService,
      genshinService,
      localeService,
      loggingService,
      telemetryService,
      settingsService,
      resourceService,
      notificationsBloc,
    );
  }

  test(
    'Initial state',
    () => expect(
      buildBloc().state,
      const NotificationState.resin(currentResin: 0), reason: 'A freshly constructed NotificationBloc should start in NotificationState.resin with currentResin=0'),
  );

  blocTest<NotificationBloc, NotificationState>(
    'Add should generated a default resin state',
    build: () => buildBloc(),
    act: (bloc) => bloc.add(const NotificationEvent.add(defaultTitle: defaultTitle, defaultBody: defaultBody)),
    verify: (bloc) {
      final state = bloc.state;
      switch (state) {
        case NotificationStateResin():
          checkState(state, AppNotificationType.resin, checkKey: false);
          checkNotDirtyFields(state, shouldBeDirty: false);
          expect(state.showOtherImages, false, reason: 'A default resin notification should not show other images');
          expect(state.currentResin, 0, reason: 'A default resin notification should start with currentResin=0');
        default:
          throw InvalidStateError();
      }
    },
  );

  group('Load', () {
    blocTest<NotificationBloc, NotificationState>(
      'a resin notification',
      setUp: () async {
        await dataService.notifications.saveResinNotification(fragileResinKey, defaultTitle, defaultBody, 60, note: defaultNote);
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      build: () => buildBloc(),
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.resin));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateResin():
            checkState(state, AppNotificationType.resin, checkNote: true);
            checkNotDirtyFields(state);
            expect(state.currentResin, 60, reason: 'Editing the saved resin notification should load currentResin=60');
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'an expedition notification',
      setUp: () async {
        final material = genshinService.materials.getAllMaterialsThatCanBeObtainedFromAnExpedition().first;
        await dataService.notifications.saveExpeditionNotification(
          material.key,
          defaultTitle,
          defaultBody,
          ExpeditionTimeType.twelveHours,
          note: defaultNote,
          withTimeReduction: true,
        );
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      build: () => buildBloc(),
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.expedition));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateExpedition():
            checkState(state, AppNotificationType.expedition, checkNote: true);
            checkNotDirtyFields(state);
            expect(state.withTimeReduction, true, reason: 'Editing the saved expedition notification should load withTimeReduction=true');
            expect(state.expeditionTimeType, ExpeditionTimeType.twelveHours, reason: 'Editing the saved expedition notification should load expeditionTimeType=twelveHours');
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'a farming artifact notification',
      setUp: () async {
        final artifact = genshinService.artifacts.getArtifactsForCard().first;
        await dataService.notifications.saveFarmingArtifactNotification(
          artifact.key,
          ArtifactFarmingTimeType.twelveHours,
          defaultTitle,
          defaultBody,
          note: defaultNote,
        );
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      build: () => buildBloc(),
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.farmingArtifacts));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateFarmingArtifact():
            checkState(state, AppNotificationType.farmingArtifacts, checkNote: true);
            checkNotDirtyFields(state);
            expect(state.artifactFarmingTimeType, ArtifactFarmingTimeType.twelveHours, reason: 'Editing the saved farming-artifact notification should load artifactFarmingTimeType=twelveHours');
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'a farming material notification',
      setUp: () async {
        final material = genshinService.materials.getAllMaterialsThatHaveAFarmingRespawnDuration().first;
        await dataService.notifications.saveFarmingMaterialNotification(
          material.key,
          defaultTitle,
          defaultBody,
          note: defaultNote,
        );
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      build: () => buildBloc(),
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.farmingMaterials));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateFarmingMaterial():
            checkState(state, AppNotificationType.farmingMaterials, checkNote: true);
            checkNotDirtyFields(state);
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'a gadget notification',
      setUp: () async {
        final gadget = genshinService.gadgets.getAllGadgetsForNotifications().first;
        await dataService.notifications.saveGadgetNotification(gadget.key, defaultTitle, defaultBody, note: defaultNote);
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      build: () => buildBloc(),
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.gadget));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateGadget():
            checkState(state, AppNotificationType.gadget, checkNote: true);
            checkNotDirtyFields(state);
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'a furniture notification',
      setUp: () async {
        final furniture = genshinService.furniture.getDefaultFurnitureForNotifications();
        await dataService.notifications.saveFurnitureNotification(
          furniture.key,
          FurnitureCraftingTimeType.fourteenHours,
          defaultTitle,
          defaultBody,
          note: defaultNote,
        );
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      build: () => buildBloc(),
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.furniture));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateFurniture():
            checkState(state, AppNotificationType.furniture, checkNote: true);
            checkNotDirtyFields(state);
            expect(state.timeType, FurnitureCraftingTimeType.fourteenHours, reason: 'Editing the saved furniture notification should load timeType=fourteenHours');
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'a realm currency notification',
      setUp: () async {
        await dataService.notifications.saveRealmCurrencyNotification(
          realmCurrency,
          RealmRankType.luxury,
          7,
          100,
          defaultTitle,
          defaultBody,
          note: defaultNote,
        );
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      build: () => buildBloc(),
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.realmCurrency));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateRealmCurrency():
            checkState(state, AppNotificationType.realmCurrency, checkNote: true);
            checkNotDirtyFields(state);
            expect(state.currentRealmRankType, RealmRankType.luxury, reason: 'Editing the saved realm-currency notification should load currentRealmRankType=luxury');
            expect(state.currentTrustRank, 7, reason: 'Editing the saved realm-currency notification should load currentTrustRank=7');
            expect(state.currentRealmCurrency, 100, reason: 'Editing the saved realm-currency notification should load currentRealmCurrency=100');
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'a weekly boss notification',
      setUp: () async {
        final boss = genshinService.monsters.getAllMonstersForCard().where((el) => el.type == MonsterType.boss).first;
        await dataService.notifications.saveWeeklyBossNotification(
          boss.key,
          settingsService.serverResetTime,
          defaultTitle,
          defaultBody,
          note: defaultNote,
        );
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      build: () => buildBloc(),
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.weeklyBoss));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateWeeklyBoss():
            checkState(state, AppNotificationType.weeklyBoss, checkNote: true);
            checkNotDirtyFields(state);
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'a daily check in notification',
      setUp: () async {
        await dataService.notifications.saveDailyCheckInNotification(primogemKey, defaultTitle, defaultBody, note: defaultNote);
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      build: () => buildBloc(),
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.dailyCheckIn));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateDailyCheckIn():
            checkState(state, AppNotificationType.dailyCheckIn, checkNote: true);
            checkNotDirtyFields(state);
          default:
            throw InvalidStateError();
        }
      },
    );
  });

  group('Load custom', () {
    const values = AppNotificationItemType.values;
    for (final type in values) {
      blocTest<NotificationBloc, NotificationState>(
        'a custom $type notification',
        setUp: () async {
          var key = '';
          switch (type) {
            case AppNotificationItemType.character:
              key = keqingKey;
            case AppNotificationItemType.weapon:
              key = genshinService.weapons.getWeaponsForCard().firstWhere((el) => el.rarity == 1).key;
            case AppNotificationItemType.artifact:
              key = genshinService.artifacts.getArtifactsForCard().first.key;
            case AppNotificationItemType.monster:
              key = genshinService.monsters.getAllMonstersForCard().firstWhere((el) => el.type == MonsterType.abyssOrder).key;
            case AppNotificationItemType.material:
              key = fragileResinKey;
          }
          await dataService.notifications.saveCustomNotification(
            key,
            defaultTitle,
            defaultBody,
            customNotificationCompletesAt,
            type,
            note: defaultNote,
          );
        },
        tearDown: () async {
          await dataService.deleteThemAll();
        },
        build: () => buildBloc(),
        act: (bloc) {
          final notification = dataService.notifications.getAllNotifications().first;
          return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.custom));
        },
        verify: (bloc) {
          final state = bloc.state;
          switch (state) {
            case NotificationStateCustom():
              checkState(state, AppNotificationType.custom, checkNote: true);
              checkNotDirtyFields(state);
              expect(state.itemType, type, reason: 'Editing a saved custom notification should load itemType=${type.name}, got ${state.itemType.name}');
            default:
              throw InvalidStateError();
          }
        },
      );
    }
  });

  group('Common value changed', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: defaultTitle, defaultBody: defaultBody))
        ..add(const NotificationEvent.titleChanged(newValue: 'Title'))
        ..add(const NotificationEvent.bodyChanged(newValue: 'Body'))
        ..add(const NotificationEvent.noteChanged(newValue: 'Note'))
        ..add(const NotificationEvent.showNotificationChanged(show: false)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateResin():
            checkState(
              state,
              AppNotificationType.resin,
              title: 'Title',
              body: 'Body',
              note: 'Note',
              showNotification: false,
              checkKey: false,
            );
            checkNotDirtyFields(state);
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => buildBloc(),
      setUp: () async {
        await dataService.notifications.saveResinNotification(fragileResinKey, defaultTitle, defaultBody, 60, note: defaultNote);
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.resin))
          ..add(const NotificationEvent.titleChanged(newValue: 'Title'))
          ..add(const NotificationEvent.bodyChanged(newValue: 'Body'))
          ..add(const NotificationEvent.noteChanged(newValue: 'Note'))
          ..add(const NotificationEvent.showNotificationChanged(show: false));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateResin():
            checkState(
              state,
              AppNotificationType.resin,
              title: 'Title',
              body: 'Body',
              note: 'Note',
              showNotification: false,
              checkKey: false,
            );
            checkNotDirtyFields(state);
          default:
            throw InvalidStateError();
        }
      },
    );
  });

  group('Value changed - resin specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: defaultTitle, defaultBody: defaultBody))
        ..add(const NotificationEvent.resinChanged(newValue: 100)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateResin():
            checkState(state, AppNotificationType.resin, checkKey: false);
            checkNotDirtyFields(state, shouldBeDirty: false);
            expect(state.currentResin, 100, reason: 'resinChanged(100) should set currentResin to 100');
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => buildBloc(),
      setUp: () async {
        await dataService.notifications.saveResinNotification(fragileResinKey, defaultTitle, defaultBody, 60, note: defaultNote);
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.resin))
          ..add(const NotificationEvent.resinChanged(newValue: 100));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateResin():
            checkState(state, AppNotificationType.resin);
            checkNotDirtyFields(state);
            expect(state.currentResin, 100, reason: 'resinChanged(100) on the edited notification should set currentResin to 100');
          default:
            throw InvalidStateError();
        }
      },
    );
  });

  group('Value changed - expedition specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: defaultTitle, defaultBody: defaultBody))
        ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.expedition))
        ..add(const NotificationEvent.expeditionTimeTypeChanged(newValue: ExpeditionTimeType.fourHours))
        ..add(const NotificationEvent.timeReductionChanged(withTimeReduction: true)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateExpedition():
            checkState(state, AppNotificationType.expedition, checkKey: false);
            checkNotDirtyFields(state, shouldBeDirty: false);
            expect(state.expeditionTimeType, ExpeditionTimeType.fourHours, reason: 'expeditionTimeTypeChanged(fourHours) should set expeditionTimeType to fourHours');
            expect(state.withTimeReduction, true, reason: 'timeReductionChanged(true) should set withTimeReduction to true');
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => buildBloc(),
      setUp: () async {
        await dataService.notifications.saveExpeditionNotification(
          'mora',
          defaultTitle,
          defaultBody,
          ExpeditionTimeType.fourHours,
          note: defaultNote,
          withTimeReduction: true,
        );
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.expedition))
          ..add(const NotificationEvent.expeditionTimeTypeChanged(newValue: ExpeditionTimeType.eightHours))
          ..add(const NotificationEvent.timeReductionChanged(withTimeReduction: false));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateExpedition():
            checkState(state, AppNotificationType.expedition, checkKey: false);
            checkNotDirtyFields(state);
            expect(state.expeditionTimeType, ExpeditionTimeType.eightHours, reason: 'expeditionTimeTypeChanged(eightHours) on the edited notification should set expeditionTimeType to eightHours');
            expect(state.withTimeReduction, false, reason: 'timeReductionChanged(false) on the edited notification should set withTimeReduction to false');
          default:
            throw InvalidStateError();
        }
      },
    );
  });

  group('Value changed - farming artifact specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: defaultTitle, defaultBody: defaultBody))
        ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.farmingArtifacts))
        ..add(const NotificationEvent.artifactFarmingTimeTypeChanged(newValue: ArtifactFarmingTimeType.twelveHours)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateFarmingArtifact():
            checkState(state, AppNotificationType.farmingArtifacts, checkKey: false);
            checkNotDirtyFields(state, shouldBeDirty: false);
            expect(state.artifactFarmingTimeType, ArtifactFarmingTimeType.twelveHours, reason: 'artifactFarmingTimeTypeChanged(twelveHours) should set artifactFarmingTimeType to twelveHours');
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => buildBloc(),
      setUp: () async {
        final artifact = genshinService.artifacts.getArtifactsForCard().first;
        await dataService.notifications.saveFarmingArtifactNotification(
          artifact.key,
          ArtifactFarmingTimeType.twelveHours,
          defaultTitle,
          defaultBody,
          note: defaultNote,
        );
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.farmingArtifacts))
          ..add(const NotificationEvent.artifactFarmingTimeTypeChanged(newValue: ArtifactFarmingTimeType.twentyFourHours));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateFarmingArtifact():
            checkState(state, AppNotificationType.farmingArtifacts, checkKey: false);
            checkNotDirtyFields(state);
            expect(state.artifactFarmingTimeType, ArtifactFarmingTimeType.twentyFourHours, reason: 'artifactFarmingTimeTypeChanged(twentyFourHours) on the edited notification should set artifactFarmingTimeType to twentyFourHours');
          default:
            throw InvalidStateError();
        }
      },
    );
  });

  group('Value changed - farming materials specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => buildBloc(),
      act: (bloc) {
        final newMaterial = genshinService.materials.getAllMaterialsThatHaveAFarmingRespawnDuration().last;
        final imgPath = resourceService.getMaterialImagePath(newMaterial.image, newMaterial.type);
        return bloc
          ..add(const NotificationEvent.add(defaultTitle: defaultTitle, defaultBody: defaultBody))
          ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.farmingMaterials))
          ..add(NotificationEvent.imageChanged(newValue: imgPath));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateFarmingMaterial():
            checkState(state, AppNotificationType.farmingMaterials, checkKey: false);
            checkNotDirtyFields(state, shouldBeDirty: false);
            final newMaterial = genshinService.materials.getAllMaterialsThatHaveAFarmingRespawnDuration().last;
            final imgPath = resourceService.getMaterialImagePath(newMaterial.image, newMaterial.type);
            expect(state.images.any((el) => el.isSelected && el.image == imgPath), isTrue, reason: 'imageChanged should select the material image $imgPath');
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => buildBloc(),
      setUp: () async {
        final material = genshinService.materials.getAllMaterialsThatHaveAFarmingRespawnDuration().first;
        await dataService.notifications.saveFarmingMaterialNotification(
          material.key,
          defaultTitle,
          defaultBody,
          note: defaultNote,
        );
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        final newMaterial = genshinService.materials.getAllMaterialsThatHaveAFarmingRespawnDuration().last;
        final imgPath = resourceService.getMaterialImagePath(newMaterial.image, newMaterial.type);
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.farmingMaterials))
          ..add(NotificationEvent.imageChanged(newValue: imgPath));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateFarmingMaterial():
            checkState(state, AppNotificationType.farmingMaterials, checkKey: false);
            checkNotDirtyFields(state);
            final newMaterial = genshinService.materials.getAllMaterialsThatHaveAFarmingRespawnDuration().last;
            final imgPath = resourceService.getMaterialImagePath(newMaterial.image, newMaterial.type);
            expect(state.images.any((el) => el.isSelected && el.image == imgPath), isTrue, reason: 'imageChanged on the edited notification should select the material image $imgPath');
          default:
            throw InvalidStateError();
        }
      },
    );
  });

  group('Value changed - gadgets specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => buildBloc(),
      act: (bloc) {
        final gadget = genshinService.gadgets.getAllGadgetsForNotifications().last;
        final imgPath = resourceService.getGadgetImagePath(gadget.image);
        return bloc
          ..add(const NotificationEvent.add(defaultTitle: defaultTitle, defaultBody: defaultBody))
          ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.gadget))
          ..add(NotificationEvent.imageChanged(newValue: imgPath));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateGadget():
            checkState(state, AppNotificationType.gadget, checkKey: false);
            checkNotDirtyFields(state, shouldBeDirty: false);
            final gadget = genshinService.gadgets.getAllGadgetsForNotifications().last;
            final imgPath = resourceService.getGadgetImagePath(gadget.image);
            expect(state.images.any((el) => el.isSelected && el.image == imgPath), isTrue, reason: 'imageChanged should select the gadget image $imgPath');
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => buildBloc(),
      setUp: () async {
        final gadget = genshinService.gadgets.getAllGadgetsForNotifications().first;
        await dataService.notifications.saveGadgetNotification(gadget.key, defaultTitle, defaultBody, note: defaultNote);
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        final gadget = genshinService.gadgets.getAllGadgetsForNotifications().last;
        final imgPath = resourceService.getGadgetImagePath(gadget.image);
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.gadget))
          ..add(NotificationEvent.imageChanged(newValue: imgPath));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateGadget():
            checkState(state, AppNotificationType.gadget, checkKey: false);
            checkNotDirtyFields(state);
            final gadget = genshinService.gadgets.getAllGadgetsForNotifications().last;
            final imgPath = resourceService.getGadgetImagePath(gadget.image);
            expect(state.images.any((el) => el.isSelected && el.image == imgPath), isTrue, reason: 'imageChanged on the edited notification should select the gadget image $imgPath');
          default:
            throw InvalidStateError();
        }
      },
    );
  });

  group('Value changed - furniture specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: defaultTitle, defaultBody: defaultBody))
        ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.furniture))
        ..add(const NotificationEvent.furnitureCraftingTimeTypeChanged(newValue: FurnitureCraftingTimeType.fourteenHours)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateFurniture():
            checkState(state, AppNotificationType.furniture, checkKey: false);
            checkNotDirtyFields(state, shouldBeDirty: false);
            expect(state.timeType, FurnitureCraftingTimeType.fourteenHours, reason: 'furnitureCraftingTimeTypeChanged(fourteenHours) should set timeType to fourteenHours');
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => buildBloc(),
      setUp: () async {
        final furniture = genshinService.furniture.getDefaultFurnitureForNotifications();
        await dataService.notifications.saveFurnitureNotification(
          furniture.key,
          FurnitureCraftingTimeType.sixteenHours,
          defaultTitle,
          defaultBody,
          note: defaultNote,
        );
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.furniture))
          ..add(const NotificationEvent.furnitureCraftingTimeTypeChanged(newValue: FurnitureCraftingTimeType.sixteenHours));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateFurniture():
            checkState(state, AppNotificationType.furniture, checkKey: false);
            checkNotDirtyFields(state);
            expect(state.timeType, FurnitureCraftingTimeType.sixteenHours, reason: 'furnitureCraftingTimeTypeChanged(sixteenHours) on the edited notification should set timeType to sixteenHours');
          default:
            throw InvalidStateError();
        }
      },
    );
  });

  group('Value changed - realm currency specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: defaultTitle, defaultBody: defaultBody))
        ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.realmCurrency))
        ..add(const NotificationEvent.realmCurrencyChanged(newValue: 100))
        ..add(const NotificationEvent.realmTrustRankLevelChanged(newValue: 10))
        ..add(const NotificationEvent.realmRankTypeChanged(newValue: RealmRankType.luxury)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateRealmCurrency():
            checkState(state, AppNotificationType.realmCurrency, checkKey: false);
            checkNotDirtyFields(state, shouldBeDirty: false);
            expect(state.currentRealmCurrency, 100, reason: 'realmCurrencyChanged(100) should set currentRealmCurrency to 100');
            expect(state.currentTrustRank, 10, reason: 'realmTrustRankLevelChanged(10) should set currentTrustRank to 10');
            expect(state.currentRealmRankType, RealmRankType.luxury, reason: 'realmRankTypeChanged(luxury) should set currentRealmRankType to luxury');
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => buildBloc(),
      setUp: () async {
        await dataService.notifications.saveRealmCurrencyNotification(
          realmCurrency,
          RealmRankType.luxury,
          10,
          100,
          defaultTitle,
          defaultBody,
          note: defaultNote,
        );
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.realmCurrency))
          ..add(const NotificationEvent.realmCurrencyChanged(newValue: 1000))
          ..add(const NotificationEvent.realmTrustRankLevelChanged(newValue: 9))
          ..add(const NotificationEvent.realmRankTypeChanged(newValue: RealmRankType.luxury));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateRealmCurrency():
            checkState(state, AppNotificationType.realmCurrency, checkKey: false);
            checkNotDirtyFields(state);
            expect(state.currentRealmCurrency, 1000, reason: 'realmCurrencyChanged(1000) on the edited notification should set currentRealmCurrency to 1000');
            expect(state.currentTrustRank, 9, reason: 'realmTrustRankLevelChanged(9) on the edited notification should set currentTrustRank to 9');
            expect(state.currentRealmRankType, RealmRankType.luxury, reason: 'realmRankTypeChanged(luxury) on the edited notification should set currentRealmRankType to luxury');
          default:
            throw InvalidStateError();
        }
      },
    );
  });

  group('Value changed - weekly boss specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: defaultTitle, defaultBody: defaultBody))
        ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.weeklyBoss)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateWeeklyBoss():
            checkState(state, AppNotificationType.weeklyBoss, checkKey: false);
            checkNotDirtyFields(state, shouldBeDirty: false);
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => buildBloc(),
      setUp: () async {
        final boss = genshinService.monsters.getAllMonstersForCard().firstWhere((el) => el.type == MonsterType.boss).key;
        await dataService.notifications.saveWeeklyBossNotification(
          boss,
          AppServerResetTimeType.northAmerica,
          defaultTitle,
          defaultBody,
          note: defaultNote,
        );
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      act: (bloc) {
        final boss = genshinService.monsters.getAllMonstersForCard().lastWhere((el) => el.type == MonsterType.boss);
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.weeklyBoss))
          ..add(NotificationEvent.imageChanged(newValue: boss.image));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateWeeklyBoss():
            checkState(state, AppNotificationType.weeklyBoss, checkKey: false);
            checkNotDirtyFields(state);
            final boss = genshinService.monsters.getAllMonstersForCard().lastWhere((el) => el.type == MonsterType.boss);
            expect(state.images.any((el) => el.isSelected && el.image == boss.image), isTrue, reason: 'imageChanged should select the weekly boss image ${boss.image}');
          default:
            throw InvalidStateError();
        }
      },
    );
  });

  group('Value changed - custom specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: defaultTitle, defaultBody: defaultBody))
        ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.custom))
        ..add(const NotificationEvent.itemTypeChanged(newValue: AppNotificationItemType.character)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateCustom():
            checkState(state, AppNotificationType.custom, checkKey: false);
            checkNotDirtyFields(state, shouldBeDirty: false);
            expect(state.itemType, AppNotificationItemType.character, reason: 'itemTypeChanged(character) should set itemType to character');
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => buildBloc(),
      setUp: () async {
        final boss = genshinService.monsters.getAllMonstersForCard().firstWhere((el) => el.type == MonsterType.boss).key;
        await dataService.notifications.saveCustomNotification(
          boss,
          defaultTitle,
          defaultBody,
          customNotificationCompletesAt,
          AppNotificationItemType.monster,
          note: defaultNote,
        );
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.custom))
          ..add(const NotificationEvent.itemTypeChanged(newValue: AppNotificationItemType.artifact));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateCustom():
            checkState(state, AppNotificationType.custom, checkKey: false);
            checkNotDirtyFields(state);
            expect(state.itemType, AppNotificationItemType.artifact, reason: 'itemTypeChanged(artifact) on the edited notification should set itemType to artifact');
          default:
            throw InvalidStateError();
        }
      },
    );
  });

  group('Value changed - daily check in specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: defaultTitle, defaultBody: defaultBody))
        ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.dailyCheckIn)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateDailyCheckIn():
            checkState(state, AppNotificationType.dailyCheckIn, checkKey: false);
            checkNotDirtyFields(state, shouldBeDirty: false);
          default:
            throw InvalidStateError();
        }
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => buildBloc(),
      setUp: () async {
        await dataService.notifications.saveDailyCheckInNotification(primogemKey, defaultTitle, defaultBody, note: defaultNote);
      },
      tearDown: () async {
        await dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = dataService.notifications.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.dailyCheckIn));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case NotificationStateDailyCheckIn():
            checkState(state, AppNotificationType.dailyCheckIn, checkKey: false);
            checkNotDirtyFields(state);
          default:
            throw InvalidStateError();
        }
      },
    );
  });
}
