import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
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
      expect(state.key, 0);
    }
    expect(state.title, title);
    expect(state.body, body);
    if (checkNote) {
      expect(state.note, note);
    }
    expect(state.isTitleValid, true);
    expect(state.isBodyValid, true);
    expect(state.showNotification, showNotification);
    expect(state.type, type);
    expect(state.images, isNotEmpty);
    expect(state.images.any((el) => el.isSelected), true);
    for (final item in state.images) {
      checkItemKeyAndImage(item.itemKey, item.image);
    }
  }

  void checkNotDirtyFields(NotificationState state, {bool shouldBeDirty = true}) {
    expect(state.isTitleDirty, shouldBeDirty);
    expect(state.isNoteDirty, shouldBeDirty);
    expect(state.isBodyDirty, shouldBeDirty);
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
      const NotificationState.resin(currentResin: 0),
    ),
  );

  blocTest<NotificationBloc, NotificationState>(
    'Add should generated a default resin state',
    build: () => buildBloc(),
    act: (bloc) => bloc.add(const NotificationEvent.add(defaultTitle: defaultTitle, defaultBody: defaultBody)),
    verify: (bloc) => bloc.state.maybeMap(
      resin: (state) {
        checkState(state, AppNotificationType.resin, checkKey: false);
        checkNotDirtyFields(state, shouldBeDirty: false);
        expect(state.showOtherImages, false);
        expect(state.currentResin, 0);
      },
      orElse: () => throw Exception('Invalid state'),
    ),
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
      verify: (bloc) => bloc.state.maybeMap(
        resin: (state) {
          checkState(state, AppNotificationType.resin, checkNote: true);
          checkNotDirtyFields(state);
          expect(state.currentResin, 60);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        expedition: (state) {
          checkState(state, AppNotificationType.expedition, checkNote: true);
          checkNotDirtyFields(state);
          expect(state.withTimeReduction, true);
          expect(state.expeditionTimeType, ExpeditionTimeType.twelveHours);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        farmingArtifact: (state) {
          checkState(state, AppNotificationType.farmingArtifacts, checkNote: true);
          checkNotDirtyFields(state);
          expect(state.artifactFarmingTimeType, ArtifactFarmingTimeType.twelveHours);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        farmingMaterial: (state) {
          checkState(state, AppNotificationType.farmingMaterials, checkNote: true);
          checkNotDirtyFields(state);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        gadget: (state) {
          checkState(state, AppNotificationType.gadget, checkNote: true);
          checkNotDirtyFields(state);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        furniture: (state) {
          checkState(state, AppNotificationType.furniture, checkNote: true);
          checkNotDirtyFields(state);
          expect(state.timeType, FurnitureCraftingTimeType.fourteenHours);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        realmCurrency: (state) {
          checkState(state, AppNotificationType.realmCurrency, checkNote: true);
          checkNotDirtyFields(state);
          expect(state.currentRealmRankType, RealmRankType.luxury);
          expect(state.currentTrustRank, 7);
          expect(state.currentRealmCurrency, 100);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        weeklyBoss: (state) {
          checkState(state, AppNotificationType.weeklyBoss, checkNote: true);
          checkNotDirtyFields(state);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        dailyCheckIn: (state) {
          checkState(state, AppNotificationType.dailyCheckIn, checkNote: true);
          checkNotDirtyFields(state);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
        verify: (bloc) => bloc.state.maybeMap(
          custom: (state) {
            checkState(state, AppNotificationType.custom, checkNote: true);
            checkNotDirtyFields(state);
            expect(state.itemType, type);
          },
          orElse: () => throw Exception('Invalid state'),
        ),
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
      verify: (bloc) => bloc.state.maybeMap(
        resin: (state) {
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
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        resin: (state) {
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
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );
  });

  group('Value changed - resin specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: defaultTitle, defaultBody: defaultBody))
        ..add(const NotificationEvent.resinChanged(newValue: 100)),
      verify: (bloc) => bloc.state.maybeMap(
        resin: (state) {
          checkState(state, AppNotificationType.resin, checkKey: false);
          checkNotDirtyFields(state, shouldBeDirty: false);
          expect(state.currentResin, 100);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        resin: (state) {
          checkState(state, AppNotificationType.resin);
          checkNotDirtyFields(state);
          expect(state.currentResin, 100);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        expedition: (state) {
          checkState(state, AppNotificationType.expedition, checkKey: false);
          checkNotDirtyFields(state, shouldBeDirty: false);
          expect(state.expeditionTimeType, ExpeditionTimeType.fourHours);
          expect(state.withTimeReduction, true);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        expedition: (state) {
          checkState(state, AppNotificationType.expedition, checkKey: false);
          checkNotDirtyFields(state);
          expect(state.expeditionTimeType, ExpeditionTimeType.eightHours);
          expect(state.withTimeReduction, false);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        farmingArtifact: (state) {
          checkState(state, AppNotificationType.farmingArtifacts, checkKey: false);
          checkNotDirtyFields(state, shouldBeDirty: false);
          expect(state.artifactFarmingTimeType, ArtifactFarmingTimeType.twelveHours);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        farmingArtifact: (state) {
          checkState(state, AppNotificationType.farmingArtifacts, checkKey: false);
          checkNotDirtyFields(state);
          expect(state.artifactFarmingTimeType, ArtifactFarmingTimeType.twentyFourHours);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        farmingMaterial: (state) {
          checkState(state, AppNotificationType.farmingMaterials, checkKey: false);
          checkNotDirtyFields(state, shouldBeDirty: false);
          final newMaterial = genshinService.materials.getAllMaterialsThatHaveAFarmingRespawnDuration().last;
          final imgPath = resourceService.getMaterialImagePath(newMaterial.image, newMaterial.type);
          expect(state.images.any((el) => el.isSelected && el.image == imgPath), isTrue);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        farmingMaterial: (state) {
          checkState(state, AppNotificationType.farmingMaterials, checkKey: false);
          checkNotDirtyFields(state);
          final newMaterial = genshinService.materials.getAllMaterialsThatHaveAFarmingRespawnDuration().last;
          final imgPath = resourceService.getMaterialImagePath(newMaterial.image, newMaterial.type);
          expect(state.images.any((el) => el.isSelected && el.image == imgPath), isTrue);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        gadget: (state) {
          checkState(state, AppNotificationType.gadget, checkKey: false);
          checkNotDirtyFields(state, shouldBeDirty: false);
          final gadget = genshinService.gadgets.getAllGadgetsForNotifications().last;
          final imgPath = resourceService.getGadgetImagePath(gadget.image);
          expect(state.images.any((el) => el.isSelected && el.image == imgPath), isTrue);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        gadget: (state) {
          checkState(state, AppNotificationType.gadget, checkKey: false);
          checkNotDirtyFields(state);
          final gadget = genshinService.gadgets.getAllGadgetsForNotifications().last;
          final imgPath = resourceService.getGadgetImagePath(gadget.image);
          expect(state.images.any((el) => el.isSelected && el.image == imgPath), isTrue);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        furniture: (state) {
          checkState(state, AppNotificationType.furniture, checkKey: false);
          checkNotDirtyFields(state, shouldBeDirty: false);
          expect(state.timeType, FurnitureCraftingTimeType.fourteenHours);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        furniture: (state) {
          checkState(state, AppNotificationType.furniture, checkKey: false);
          checkNotDirtyFields(state);
          expect(state.timeType, FurnitureCraftingTimeType.sixteenHours);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        realmCurrency: (state) {
          checkState(state, AppNotificationType.realmCurrency, checkKey: false);
          checkNotDirtyFields(state, shouldBeDirty: false);
          expect(state.currentRealmCurrency, 100);
          expect(state.currentTrustRank, 10);
          expect(state.currentRealmRankType, RealmRankType.luxury);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        realmCurrency: (state) {
          checkState(state, AppNotificationType.realmCurrency, checkKey: false);
          checkNotDirtyFields(state);
          expect(state.currentRealmCurrency, 1000);
          expect(state.currentTrustRank, 9);
          expect(state.currentRealmRankType, RealmRankType.luxury);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );
  });

  group('Value changed - weekly boss specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: defaultTitle, defaultBody: defaultBody))
        ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.weeklyBoss)),
      verify: (bloc) => bloc.state.maybeMap(
        weeklyBoss: (state) {
          checkState(state, AppNotificationType.weeklyBoss, checkKey: false);
          checkNotDirtyFields(state, shouldBeDirty: false);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        weeklyBoss: (state) {
          checkState(state, AppNotificationType.weeklyBoss, checkKey: false);
          checkNotDirtyFields(state);
          final boss = genshinService.monsters.getAllMonstersForCard().lastWhere((el) => el.type == MonsterType.boss);
          expect(state.images.any((el) => el.isSelected && el.image == boss.image), isTrue);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        custom: (state) {
          checkState(state, AppNotificationType.custom, checkKey: false);
          checkNotDirtyFields(state, shouldBeDirty: false);
          expect(state.itemType, AppNotificationItemType.character);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        custom: (state) {
          checkState(state, AppNotificationType.custom, checkKey: false);
          checkNotDirtyFields(state);
          expect(state.itemType, AppNotificationItemType.artifact);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );
  });

  group('Value changed - daily check in specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: defaultTitle, defaultBody: defaultBody))
        ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.dailyCheckIn)),
      verify: (bloc) => bloc.state.maybeMap(
        dailyCheckIn: (state) {
          checkState(state, AppNotificationType.dailyCheckIn, checkKey: false);
          checkNotDirtyFields(state, shouldBeDirty: false);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
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
      verify: (bloc) => bloc.state.maybeMap(
        dailyCheckIn: (state) {
          checkState(state, AppNotificationType.dailyCheckIn, checkKey: false);
          checkNotDirtyFields(state);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );
  });
}
