import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/calculator_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const _dbFolder = 'shiori_notifications_bloc_tests';

void main() {
  late final TelemetryService _telemetryService;
  late final SettingsService _settingsService;
  late final MockNotificationService _notificationService;
  late final DataService _dataService;

  const _defaultTitle = 'Notification title';
  const _defaultBody = 'Notification body';
  const _defaultNote = 'Notification note';
  const _fragileResinKey = 'fragile-resin';
  const _keqingKey = 'keqing';

  final _now = DateTime.now();
  final _customNotificationCompletesAt = _now.add(const Duration(days: 1));

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _telemetryService = MockTelemetryService();
    _settingsService = MockSettingsService();
    when(_settingsService.language).thenReturn(AppLanguageType.english);
    when(_settingsService.useTwentyFourHoursFormat).thenReturn(false);
    when(_settingsService.serverResetTime).thenReturn(AppServerResetTimeType.northAmerica);

    _notificationService = MockNotificationService();
    when(_notificationService.cancelNotification(any, any)).thenAnswer((_) => Future.value());
    when(_notificationService.scheduleNotification(any, any, any, any, any)).thenAnswer((_) => Future.value());
    final genshinService = GenshinServiceImpl(LocaleServiceImpl(_settingsService));
    _dataService = DataServiceImpl(genshinService, CalculatorServiceImpl(genshinService));

    return Future(() async {
      await genshinService.init(_settingsService.language);
      await _dataService.init(dir: _dbFolder);
    });
  });

  tearDownAll(() {
    return Future(() async {
      await _dataService.closeThemAll();
      await deleteDbFolder(_dbFolder);
    });
  });

  test(
    'Initial state',
    () => expect(NotificationsBloc(_dataService, _notificationService, _settingsService, _telemetryService).state,
        const NotificationsState.initial(notifications: [], ticks: 0)),
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'Init',
    build: () => NotificationsBloc(_dataService, _notificationService, _settingsService, _telemetryService),
    setUp: () async {
      await _dataService.saveCustomNotification(
        _keqingKey,
        _defaultTitle,
        _defaultBody,
        _customNotificationCompletesAt,
        AppNotificationItemType.character,
        note: _defaultNote,
      );
    },
    tearDown: () async {
      await _dataService.deleteThemAll();
    },
    act: (bloc) => bloc.add(const NotificationsEvent.init()),
    verify: (bloc) {
      expect(bloc.state.notifications.length, 1);
      expect(bloc.state.useTwentyFourHoursFormat, _settingsService.useTwentyFourHoursFormat);
      expect(bloc.state.ticks, 0);

      final notif = bloc.state.notifications.first;
      expect(notif.key, 0);
      expect(notif.itemKey, _keqingKey);
      expect(notif.title, _defaultTitle);
      expect(notif.body, _defaultBody);
      expect(notif.note, _defaultNote);
      checkAsset(notif.image);
      expect(notif.completesAt, _customNotificationCompletesAt);
      expect(notif.type, AppNotificationType.custom);
      expect(notif.notificationItemType, AppNotificationItemType.character);
    },
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'Delete',
    setUp: () async {
      await _dataService.saveCustomNotification(
        _keqingKey,
        _defaultTitle,
        _defaultBody,
        _customNotificationCompletesAt,
        AppNotificationItemType.character,
        note: _defaultNote,
      );
    },
    tearDown: () async {
      await _dataService.deleteThemAll();
    },
    build: () => NotificationsBloc(_dataService, _notificationService, _settingsService, _telemetryService),
    act: (bloc) => bloc.add(const NotificationsEvent.delete(id: 0, type: AppNotificationType.custom)),
    verify: (bloc) {
      verify(_notificationService.cancelNotification(0, AppNotificationType.custom)).called(1);
      expect(bloc.state.notifications, isEmpty);
    },
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'Reset',
    setUp: () async {
      await _dataService.saveResinNotification(_fragileResinKey, _defaultTitle, _defaultBody, 100, note: _defaultNote);
    },
    tearDown: () async {
      await _dataService.deleteThemAll();
    },
    build: () => NotificationsBloc(_dataService, _notificationService, _settingsService, _telemetryService),
    act: (bloc) => bloc..add(const NotificationsEvent.init())..add(const NotificationsEvent.reset(id: 0, type: AppNotificationType.resin)),
    verify: (bloc) {
      verify(_notificationService.cancelNotification(0, AppNotificationType.resin)).called(1);
      verify(_notificationService.scheduleNotification(any, any, any, any, any)).called(1);
      expect(bloc.state.notifications.length, 1);

      final notif = bloc.state.notifications.first;
      expect(notif.key, 0);
      expect(notif.itemKey, _fragileResinKey);
      expect(notif.title, _defaultTitle);
      expect(notif.body, _defaultBody);
      expect(notif.note, _defaultNote);
      checkAsset(notif.image);
      expect(notif.type, AppNotificationType.resin);
      expect(notif.currentResinValue, 0);
    },
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'Stop',
    setUp: () async {
      await _dataService.saveResinNotification(_fragileResinKey, _defaultTitle, _defaultBody, 100, note: _defaultNote);
    },
    tearDown: () async {
      await _dataService.deleteThemAll();
    },
    build: () => NotificationsBloc(_dataService, _notificationService, _settingsService, _telemetryService),
    act: (bloc) => bloc..add(const NotificationsEvent.init())..add(const NotificationsEvent.stop(id: 0, type: AppNotificationType.resin)),
    verify: (bloc) {
      verify(_notificationService.cancelNotification(0, AppNotificationType.resin)).called(1);
      expect(bloc.state.notifications.length, 1);

      final notif = bloc.state.notifications.first;
      expect(notif.key, 0);
      expect(notif.itemKey, _fragileResinKey);
      expect(notif.title, _defaultTitle);
      expect(notif.body, _defaultBody);
      expect(notif.note, _defaultNote);
      checkAsset(notif.image);
      expect(notif.type, AppNotificationType.resin);
      expect(notif.currentResinValue, 100);
      expect(notif.completesAt.difference(DateTime.now()).inSeconds, lessThanOrEqualTo(10));
    },
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'Refresh',
    setUp: () async {
      await _dataService.saveResinNotification(_fragileResinKey, _defaultTitle, _defaultBody, 100, note: _defaultNote);
    },
    tearDown: () async {
      await _dataService.deleteThemAll();
    },
    build: () => NotificationsBloc(_dataService, _notificationService, _settingsService, _telemetryService),
    act: (bloc) => bloc..add(const NotificationsEvent.init())..add(const NotificationsEvent.refresh(ticks: 5)),
    verify: (bloc) {
      expect(bloc.state.notifications.length, 1);
      expect(bloc.state.ticks, 5);

      final notif = bloc.state.notifications.first;
      expect(notif.key, 0);
      expect(notif.itemKey, _fragileResinKey);
      expect(notif.title, _defaultTitle);
      expect(notif.body, _defaultBody);
      expect(notif.note, _defaultNote);
      checkAsset(notif.image);
      expect(notif.type, AppNotificationType.resin);
      expect(notif.currentResinValue, 100);
    },
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'Reduce hours',
    setUp: () async {
      await _dataService.saveCustomNotification(
        _keqingKey,
        _defaultTitle,
        _defaultBody,
        _now.add(const Duration(hours: 3)),
        AppNotificationItemType.character,
        note: _defaultNote,
      );
    },
    tearDown: () async {
      await _dataService.deleteThemAll();
    },
    build: () => NotificationsBloc(_dataService, _notificationService, _settingsService, _telemetryService),
    act: (bloc) => bloc
      ..add(const NotificationsEvent.init())
      ..add(const NotificationsEvent.reduceHours(id: 0, type: AppNotificationType.custom, hoursToReduce: 2)),
    verify: (bloc) {
      expect(bloc.state.notifications.length, 1);
      verify(_notificationService.cancelNotification(0, AppNotificationType.custom)).called(1);
      verify(_notificationService.scheduleNotification(any, any, any, any, any)).called(1);

      final notif = bloc.state.notifications.first;
      expect(notif.key, 0);
      expect(notif.itemKey, _keqingKey);
      expect(notif.title, _defaultTitle);
      expect(notif.body, _defaultBody);
      expect(notif.note, _defaultNote);
      checkAsset(notif.image);
      expect(notif.type, AppNotificationType.custom);
      expect(notif.notificationItemType, AppNotificationItemType.character);
      expect(notif.completesAt, lessThanOrEqualTo(_now.add(const Duration(hours: 1))));
    },
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'Close',
    build: () => NotificationsBloc(_dataService, _notificationService, _settingsService, _telemetryService),
    act: (bloc) => bloc..add(const NotificationsEvent.init())..add(const NotificationsEvent.close()),
    expect: () => const [NotificationsState.initial(notifications: [], ticks: 0)],
  );
}
