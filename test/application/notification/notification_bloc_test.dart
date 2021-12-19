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
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const _dbFolder = 'shiori_notification_bloc_tests';

void main() {
  late final TelemetryService _telemetryService;
  late final LoggingService _loggingService;
  late final NotificationService _notificationService;
  late final SettingsService _settingsService;
  late final LocaleService _localeService;
  late final GenshinService _genshinService;
  late final DataService _dataService;
  late final NotificationsBloc _notificationsBloc;

  const _defaultTitle = 'Notification title';
  const _defaultBody = 'Notification body';
  const _defaultNote = 'Notification note';
  const _fragileResinKey = 'fragile-resin';
  const _realmCurrency = 'realm-currency';
  const _keqingKey = 'keqing';
  const _primogemKey = 'primogem';

  final _customNotificationCompletesAt = DateTime.now().add(const Duration(days: 1));

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _loggingService = MockLoggingService();
    _telemetryService = MockTelemetryService();
    _notificationService = MockNotificationService();
    _settingsService = MockSettingsService();
    when(_settingsService.language).thenReturn(AppLanguageType.english);
    when(_settingsService.useTwentyFourHoursFormat).thenReturn(true);
    when(_settingsService.serverResetTime).thenReturn(AppServerResetTimeType.northAmerica);
    _localeService = LocaleServiceImpl(_settingsService);
    _genshinService = GenshinServiceImpl(_localeService);
    _dataService = DataServiceImpl(_genshinService, CalculatorServiceImpl(_genshinService));
    _notificationsBloc = NotificationsBloc(_dataService, _notificationService, _settingsService, _telemetryService);

    return Future(() async {
      await _genshinService.init(_settingsService.language);
      await _dataService.init(dir: _dbFolder);
    });
  });

  tearDownAll(() {
    return Future(() async {
      await _dataService.closeThemAll();
      await deleteDbFolder(_dbFolder);
    });
  });

  void _checkState(
    NotificationState state,
    AppNotificationType type, {
    String title = _defaultTitle,
    String body = _defaultBody,
    String note = _defaultNote,
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

  void _checkNotDirtyFields(NotificationState state, {bool shouldBeDirty = true}) {
    expect(state.isTitleDirty, shouldBeDirty);
    expect(state.isNoteDirty, shouldBeDirty);
    expect(state.isBodyDirty, shouldBeDirty);
  }

  NotificationBloc _buildBloc() {
    return NotificationBloc(
      _dataService,
      _notificationService,
      _genshinService,
      _localeService,
      _loggingService,
      _telemetryService,
      _settingsService,
      _notificationsBloc,
    );
  }

  test(
    'Initial state',
    () => expect(
      _buildBloc().state,
      const NotificationState.resin(currentResin: 0),
    ),
  );

  blocTest<NotificationBloc, NotificationState>(
    'Add should generated a default resin state',
    build: () => _buildBloc(),
    act: (bloc) => bloc.add(const NotificationEvent.add(defaultTitle: _defaultTitle, defaultBody: _defaultBody)),
    verify: (bloc) => bloc.state.maybeMap(
      resin: (state) {
        _checkState(state, AppNotificationType.resin, checkKey: false);
        _checkNotDirtyFields(state, shouldBeDirty: false);
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
        await _dataService.saveResinNotification(_fragileResinKey, _defaultTitle, _defaultBody, 60, note: _defaultNote);
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      build: () => _buildBloc(),
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.resin));
      },
      verify: (bloc) => bloc.state.maybeMap(
        resin: (state) {
          _checkState(state, AppNotificationType.resin, checkNote: true);
          _checkNotDirtyFields(state);
          expect(state.currentResin, 60);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'an expedition notification',
      setUp: () async {
        final material = _genshinService.getAllMaterialsThatCanBeObtainedFromAnExpedition().first;
        await _dataService.saveExpeditionNotification(
          material.key,
          _defaultTitle,
          _defaultBody,
          ExpeditionTimeType.twelveHours,
          note: _defaultNote,
          withTimeReduction: true,
        );
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      build: () => _buildBloc(),
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.expedition));
      },
      verify: (bloc) => bloc.state.maybeMap(
        expedition: (state) {
          _checkState(state, AppNotificationType.expedition, checkNote: true);
          _checkNotDirtyFields(state);
          expect(state.withTimeReduction, true);
          expect(state.expeditionTimeType, ExpeditionTimeType.twelveHours);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'a farming artifact notification',
      setUp: () async {
        final artifact = _genshinService.getArtifactsForCard().first;
        await _dataService.saveFarmingArtifactNotification(
          artifact.key,
          ArtifactFarmingTimeType.twelveHours,
          _defaultTitle,
          _defaultBody,
          note: _defaultNote,
        );
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      build: () => _buildBloc(),
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.farmingArtifacts));
      },
      verify: (bloc) => bloc.state.maybeMap(
        farmingArtifact: (state) {
          _checkState(state, AppNotificationType.farmingArtifacts, checkNote: true);
          _checkNotDirtyFields(state);
          expect(state.artifactFarmingTimeType, ArtifactFarmingTimeType.twelveHours);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'a farming material notification',
      setUp: () async {
        final material = _genshinService.getAllMaterialsThatHaveAFarmingRespawnDuration().first;
        await _dataService.saveFarmingMaterialNotification(material.key, _defaultTitle, _defaultBody, note: _defaultNote);
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      build: () => _buildBloc(),
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.farmingMaterials));
      },
      verify: (bloc) => bloc.state.maybeMap(
        farmingMaterial: (state) {
          _checkState(state, AppNotificationType.farmingMaterials, checkNote: true);
          _checkNotDirtyFields(state);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'a gadget notification',
      setUp: () async {
        final gadget = _genshinService.getAllGadgetsForNotifications().first;
        await _dataService.saveGadgetNotification(gadget.key, _defaultTitle, _defaultBody, note: _defaultNote);
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      build: () => _buildBloc(),
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.gadget));
      },
      verify: (bloc) => bloc.state.maybeMap(
        gadget: (state) {
          _checkState(state, AppNotificationType.gadget, checkNote: true);
          _checkNotDirtyFields(state);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'a furniture notification',
      setUp: () async {
        final furniture = _genshinService.getDefaultFurnitureForNotifications();
        await _dataService.saveFurnitureNotification(
          furniture.key,
          FurnitureCraftingTimeType.fourteenHours,
          _defaultTitle,
          _defaultBody,
          note: _defaultNote,
        );
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      build: () => _buildBloc(),
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.furniture));
      },
      verify: (bloc) => bloc.state.maybeMap(
        furniture: (state) {
          _checkState(state, AppNotificationType.furniture, checkNote: true);
          _checkNotDirtyFields(state);
          expect(state.timeType, FurnitureCraftingTimeType.fourteenHours);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'a realm currency notification',
      setUp: () async {
        await _dataService.saveRealmCurrencyNotification(
          _realmCurrency,
          RealmRankType.luxury,
          7,
          100,
          _defaultTitle,
          _defaultBody,
          note: _defaultNote,
        );
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      build: () => _buildBloc(),
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.realmCurrency));
      },
      verify: (bloc) => bloc.state.maybeMap(
        realmCurrency: (state) {
          _checkState(state, AppNotificationType.realmCurrency, checkNote: true);
          _checkNotDirtyFields(state);
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
        final boss = _genshinService.getAllMonstersForCard().where((el) => el.type == MonsterType.boss).first;
        await _dataService.saveWeeklyBossNotification(
          boss.key,
          _settingsService.serverResetTime,
          _defaultTitle,
          _defaultBody,
          note: _defaultNote,
        );
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      build: () => _buildBloc(),
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.weeklyBoss));
      },
      verify: (bloc) => bloc.state.maybeMap(
        weeklyBoss: (state) {
          _checkState(state, AppNotificationType.weeklyBoss, checkNote: true);
          _checkNotDirtyFields(state);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'a daily check in notification',
      setUp: () async {
        await _dataService.saveDailyCheckInNotification(_primogemKey, _defaultTitle, _defaultBody, note: _defaultNote);
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      build: () => _buildBloc(),
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.dailyCheckIn));
      },
      verify: (bloc) => bloc.state.maybeMap(
        dailyCheckIn: (state) {
          _checkState(state, AppNotificationType.dailyCheckIn, checkNote: true);
          _checkNotDirtyFields(state);
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
              key = _keqingKey;
              break;
            case AppNotificationItemType.weapon:
              key = _genshinService.getWeaponsForCard().firstWhere((el) => el.rarity == 1).key;
              break;
            case AppNotificationItemType.artifact:
              key = _genshinService.getArtifactsForCard().first.key;
              break;
            case AppNotificationItemType.monster:
              key = _genshinService.getAllMonstersForCard().firstWhere((el) => el.type == MonsterType.abyssOrder).key;
              break;
            case AppNotificationItemType.material:
              key = _fragileResinKey;
              break;
            default:
              throw Exception('Not mapped type');
          }
          await _dataService.saveCustomNotification(key, _defaultTitle, _defaultBody, _customNotificationCompletesAt, type, note: _defaultNote);
        },
        tearDown: () async {
          await _dataService.deleteThemAll();
        },
        build: () => _buildBloc(),
        act: (bloc) {
          final notification = _dataService.getAllNotifications().first;
          return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.custom));
        },
        verify: (bloc) => bloc.state.maybeMap(
          custom: (state) {
            _checkState(state, AppNotificationType.custom, checkNote: true);
            _checkNotDirtyFields(state);
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
      build: () => _buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: _defaultTitle, defaultBody: _defaultBody))
        ..add(const NotificationEvent.titleChanged(newValue: 'Title'))
        ..add(const NotificationEvent.bodyChanged(newValue: 'Body'))
        ..add(const NotificationEvent.noteChanged(newValue: 'Note'))
        ..add(const NotificationEvent.showNotificationChanged(show: false)),
      verify: (bloc) => bloc.state.maybeMap(
        resin: (state) {
          _checkState(state, AppNotificationType.resin, title: 'Title', body: 'Body', note: 'Note', showNotification: false, checkKey: false);
          _checkNotDirtyFields(state);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => _buildBloc(),
      setUp: () async {
        await _dataService.saveResinNotification(_fragileResinKey, _defaultTitle, _defaultBody, 60, note: _defaultNote);
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.resin))
          ..add(const NotificationEvent.titleChanged(newValue: 'Title'))
          ..add(const NotificationEvent.bodyChanged(newValue: 'Body'))
          ..add(const NotificationEvent.noteChanged(newValue: 'Note'))
          ..add(const NotificationEvent.showNotificationChanged(show: false));
      },
      verify: (bloc) => bloc.state.maybeMap(
        resin: (state) {
          _checkState(state, AppNotificationType.resin, title: 'Title', body: 'Body', note: 'Note', showNotification: false, checkKey: false);
          _checkNotDirtyFields(state);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );
  });

  group('Value changed - resin specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => _buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: _defaultTitle, defaultBody: _defaultBody))
        ..add(const NotificationEvent.resinChanged(newValue: 100)),
      verify: (bloc) => bloc.state.maybeMap(
        resin: (state) {
          _checkState(state, AppNotificationType.resin, checkKey: false);
          _checkNotDirtyFields(state, shouldBeDirty: false);
          expect(state.currentResin, 100);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => _buildBloc(),
      setUp: () async {
        await _dataService.saveResinNotification(_fragileResinKey, _defaultTitle, _defaultBody, 60, note: _defaultNote);
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.resin))
          ..add(const NotificationEvent.resinChanged(newValue: 100));
      },
      verify: (bloc) => bloc.state.maybeMap(
        resin: (state) {
          _checkState(state, AppNotificationType.resin);
          _checkNotDirtyFields(state);
          expect(state.currentResin, 100);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );
  });

  group('Value changed - expedition specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => _buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: _defaultTitle, defaultBody: _defaultBody))
        ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.expedition))
        ..add(const NotificationEvent.expeditionTimeTypeChanged(newValue: ExpeditionTimeType.fourHours))
        ..add(const NotificationEvent.timeReductionChanged(withTimeReduction: true)),
      verify: (bloc) => bloc.state.maybeMap(
        expedition: (state) {
          _checkState(state, AppNotificationType.expedition, checkKey: false);
          _checkNotDirtyFields(state, shouldBeDirty: false);
          expect(state.expeditionTimeType, ExpeditionTimeType.fourHours);
          expect(state.withTimeReduction, true);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => _buildBloc(),
      setUp: () async {
        await _dataService.saveExpeditionNotification(
          'mora',
          _defaultTitle,
          _defaultBody,
          ExpeditionTimeType.fourHours,
          note: _defaultNote,
          withTimeReduction: true,
        );
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.expedition))
          ..add(const NotificationEvent.expeditionTimeTypeChanged(newValue: ExpeditionTimeType.eightHours))
          ..add(const NotificationEvent.timeReductionChanged(withTimeReduction: false));
      },
      verify: (bloc) => bloc.state.maybeMap(
        expedition: (state) {
          _checkState(state, AppNotificationType.expedition, checkKey: false);
          _checkNotDirtyFields(state);
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
      build: () => _buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: _defaultTitle, defaultBody: _defaultBody))
        ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.farmingArtifacts))
        ..add(const NotificationEvent.artifactFarmingTimeTypeChanged(newValue: ArtifactFarmingTimeType.twelveHours)),
      verify: (bloc) => bloc.state.maybeMap(
        farmingArtifact: (state) {
          _checkState(state, AppNotificationType.farmingArtifacts, checkKey: false);
          _checkNotDirtyFields(state, shouldBeDirty: false);
          expect(state.artifactFarmingTimeType, ArtifactFarmingTimeType.twelveHours);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => _buildBloc(),
      setUp: () async {
        final artifact = _genshinService.getArtifactsForCard().first;
        await _dataService.saveFarmingArtifactNotification(
          artifact.key,
          ArtifactFarmingTimeType.twelveHours,
          _defaultTitle,
          _defaultBody,
          note: _defaultNote,
        );
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.farmingArtifacts))
          ..add(const NotificationEvent.artifactFarmingTimeTypeChanged(newValue: ArtifactFarmingTimeType.twentyFourHours));
      },
      verify: (bloc) => bloc.state.maybeMap(
        farmingArtifact: (state) {
          _checkState(state, AppNotificationType.farmingArtifacts, checkKey: false);
          _checkNotDirtyFields(state);
          expect(state.artifactFarmingTimeType, ArtifactFarmingTimeType.twentyFourHours);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );
  });

  group('Value changed - farming materials specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => _buildBloc(),
      act: (bloc) {
        final newMaterial = _genshinService.getAllMaterialsThatHaveAFarmingRespawnDuration().last;
        return bloc
          ..add(const NotificationEvent.add(defaultTitle: _defaultTitle, defaultBody: _defaultBody))
          ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.farmingMaterials))
          ..add(NotificationEvent.imageChanged(newValue: newMaterial.fullImagePath));
      },
      verify: (bloc) => bloc.state.maybeMap(
        farmingMaterial: (state) {
          _checkState(state, AppNotificationType.farmingMaterials, checkKey: false);
          _checkNotDirtyFields(state, shouldBeDirty: false);
          final newMaterial = _genshinService.getAllMaterialsThatHaveAFarmingRespawnDuration().last;
          expect(state.images.any((el) => el.isSelected && el.image == newMaterial.fullImagePath), isTrue);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => _buildBloc(),
      setUp: () async {
        final material = _genshinService.getAllMaterialsThatHaveAFarmingRespawnDuration().first;
        await _dataService.saveFarmingMaterialNotification(material.key, _defaultTitle, _defaultBody, note: _defaultNote);
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        final newMaterial = _genshinService.getAllMaterialsThatHaveAFarmingRespawnDuration().last;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.farmingMaterials))
          ..add(NotificationEvent.imageChanged(newValue: newMaterial.fullImagePath));
      },
      verify: (bloc) => bloc.state.maybeMap(
        farmingMaterial: (state) {
          _checkState(state, AppNotificationType.farmingMaterials, checkKey: false);
          _checkNotDirtyFields(state);
          final newMaterial = _genshinService.getAllMaterialsThatHaveAFarmingRespawnDuration().last;
          expect(state.images.any((el) => el.isSelected && el.image == newMaterial.fullImagePath), isTrue);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );
  });

  group('Value changed - gadgets specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => _buildBloc(),
      act: (bloc) {
        final gadget = _genshinService.getAllGadgetsForNotifications().last;
        return bloc
          ..add(const NotificationEvent.add(defaultTitle: _defaultTitle, defaultBody: _defaultBody))
          ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.gadget))
          ..add(NotificationEvent.imageChanged(newValue: gadget.fullImagePath));
      },
      verify: (bloc) => bloc.state.maybeMap(
        gadget: (state) {
          _checkState(state, AppNotificationType.gadget, checkKey: false);
          _checkNotDirtyFields(state, shouldBeDirty: false);
          final gadget = _genshinService.getAllGadgetsForNotifications().last;
          expect(state.images.any((el) => el.isSelected && el.image == gadget.fullImagePath), isTrue);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => _buildBloc(),
      setUp: () async {
        final gadget = _genshinService.getAllGadgetsForNotifications().first;
        await _dataService.saveGadgetNotification(gadget.key, _defaultTitle, _defaultBody, note: _defaultNote);
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        final gadget = _genshinService.getAllGadgetsForNotifications().last;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.gadget))
          ..add(NotificationEvent.imageChanged(newValue: gadget.fullImagePath));
      },
      verify: (bloc) => bloc.state.maybeMap(
        gadget: (state) {
          _checkState(state, AppNotificationType.gadget, checkKey: false);
          _checkNotDirtyFields(state);
          final gadget = _genshinService.getAllGadgetsForNotifications().last;
          expect(state.images.any((el) => el.isSelected && el.image == gadget.fullImagePath), isTrue);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );
  });

  group('Value changed - furniture specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => _buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: _defaultTitle, defaultBody: _defaultBody))
        ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.furniture))
        ..add(const NotificationEvent.furnitureCraftingTimeTypeChanged(newValue: FurnitureCraftingTimeType.fourteenHours)),
      verify: (bloc) => bloc.state.maybeMap(
        furniture: (state) {
          _checkState(state, AppNotificationType.furniture, checkKey: false);
          _checkNotDirtyFields(state, shouldBeDirty: false);
          expect(state.timeType, FurnitureCraftingTimeType.fourteenHours);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => _buildBloc(),
      setUp: () async {
        final furniture = _genshinService.getDefaultFurnitureForNotifications();
        await _dataService.saveFurnitureNotification(
          furniture.key,
          FurnitureCraftingTimeType.sixteenHours,
          _defaultTitle,
          _defaultBody,
          note: _defaultNote,
        );
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.furniture))
          ..add(const NotificationEvent.furnitureCraftingTimeTypeChanged(newValue: FurnitureCraftingTimeType.sixteenHours));
      },
      verify: (bloc) => bloc.state.maybeMap(
        furniture: (state) {
          _checkState(state, AppNotificationType.furniture, checkKey: false);
          _checkNotDirtyFields(state);
          expect(state.timeType, FurnitureCraftingTimeType.sixteenHours);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );
  });

  group('Value changed - realm currency specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => _buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: _defaultTitle, defaultBody: _defaultBody))
        ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.realmCurrency))
        ..add(const NotificationEvent.realmCurrencyChanged(newValue: 100))
        ..add(const NotificationEvent.realmTrustRankLevelChanged(newValue: 10))
        ..add(const NotificationEvent.realmRankTypeChanged(newValue: RealmRankType.luxury)),
      verify: (bloc) => bloc.state.maybeMap(
        realmCurrency: (state) {
          _checkState(state, AppNotificationType.realmCurrency, checkKey: false);
          _checkNotDirtyFields(state, shouldBeDirty: false);
          expect(state.currentRealmCurrency, 100);
          expect(state.currentTrustRank, 10);
          expect(state.currentRealmRankType, RealmRankType.luxury);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => _buildBloc(),
      setUp: () async {
        await _dataService.saveRealmCurrencyNotification(
          _realmCurrency,
          RealmRankType.luxury,
          10,
          100,
          _defaultTitle,
          _defaultBody,
          note: _defaultNote,
        );
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.realmCurrency))
          ..add(const NotificationEvent.realmCurrencyChanged(newValue: 1000))
          ..add(const NotificationEvent.realmTrustRankLevelChanged(newValue: 9))
          ..add(const NotificationEvent.realmRankTypeChanged(newValue: RealmRankType.luxury));
      },
      verify: (bloc) => bloc.state.maybeMap(
        realmCurrency: (state) {
          _checkState(state, AppNotificationType.realmCurrency, checkKey: false);
          _checkNotDirtyFields(state);
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
      build: () => _buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: _defaultTitle, defaultBody: _defaultBody))
        ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.weeklyBoss)),
      verify: (bloc) => bloc.state.maybeMap(
        weeklyBoss: (state) {
          _checkState(state, AppNotificationType.weeklyBoss, checkKey: false);
          _checkNotDirtyFields(state, shouldBeDirty: false);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => _buildBloc(),
      setUp: () async {
        final boss = _genshinService.getAllMonstersForCard().firstWhere((el) => el.type == MonsterType.boss).key;
        await _dataService.saveWeeklyBossNotification(
          boss,
          AppServerResetTimeType.northAmerica,
          _defaultTitle,
          _defaultBody,
          note: _defaultNote,
        );
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      act: (bloc) {
        final boss = _genshinService.getAllMonstersForCard().lastWhere((el) => el.type == MonsterType.boss);
        final notification = _dataService.getAllNotifications().first;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.weeklyBoss))
          ..add(NotificationEvent.imageChanged(newValue: boss.image));
      },
      verify: (bloc) => bloc.state.maybeMap(
        weeklyBoss: (state) {
          _checkState(state, AppNotificationType.weeklyBoss, checkKey: false);
          _checkNotDirtyFields(state);
          final boss = _genshinService.getAllMonstersForCard().lastWhere((el) => el.type == MonsterType.boss);
          expect(state.images.any((el) => el.isSelected && el.image == boss.image), isTrue);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );
  });

  group('Value changed - custom specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => _buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: _defaultTitle, defaultBody: _defaultBody))
        ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.custom))
        ..add(const NotificationEvent.itemTypeChanged(newValue: AppNotificationItemType.character)),
      verify: (bloc) => bloc.state.maybeMap(
        custom: (state) {
          _checkState(state, AppNotificationType.custom, checkKey: false);
          _checkNotDirtyFields(state, shouldBeDirty: false);
          expect(state.itemType, AppNotificationItemType.character);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => _buildBloc(),
      setUp: () async {
        final boss = _genshinService.getAllMonstersForCard().firstWhere((el) => el.type == MonsterType.boss).key;
        await _dataService.saveCustomNotification(
          boss,
          _defaultTitle,
          _defaultBody,
          _customNotificationCompletesAt,
          AppNotificationItemType.monster,
          note: _defaultNote,
        );
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc
          ..add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.custom))
          ..add(const NotificationEvent.itemTypeChanged(newValue: AppNotificationItemType.artifact));
      },
      verify: (bloc) => bloc.state.maybeMap(
        custom: (state) {
          _checkState(state, AppNotificationType.custom, checkKey: false);
          _checkNotDirtyFields(state);
          expect(state.itemType, AppNotificationItemType.artifact);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );
  });

  group('Value changed - daily check in specific', () {
    blocTest<NotificationBloc, NotificationState>(
      'on a not saved notification',
      build: () => _buildBloc(),
      act: (bloc) => bloc
        ..add(const NotificationEvent.add(defaultTitle: _defaultTitle, defaultBody: _defaultBody))
        ..add(const NotificationEvent.typeChanged(newValue: AppNotificationType.dailyCheckIn)),
      verify: (bloc) => bloc.state.maybeMap(
        dailyCheckIn: (state) {
          _checkState(state, AppNotificationType.dailyCheckIn, checkKey: false);
          _checkNotDirtyFields(state, shouldBeDirty: false);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    blocTest<NotificationBloc, NotificationState>(
      'on an existing notification',
      build: () => _buildBloc(),
      setUp: () async {
        await _dataService.saveDailyCheckInNotification(_primogemKey, _defaultTitle, _defaultBody, note: _defaultNote);
      },
      tearDown: () async {
        await _dataService.deleteThemAll();
      },
      act: (bloc) {
        final notification = _dataService.getAllNotifications().first;
        return bloc.add(NotificationEvent.edit(key: notification.key, type: AppNotificationType.dailyCheckIn));
      },
      verify: (bloc) => bloc.state.maybeMap(
        dailyCheckIn: (state) {
          _checkState(state, AppNotificationType.dailyCheckIn, checkKey: false);
          _checkNotDirtyFields(state);
        },
        orElse: () => throw Exception('Invalid state'),
      ),
    );
  });
}
