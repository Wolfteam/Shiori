import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const _dbFolder = 'shiori_notifications_bloc_tests';

void main() {
  late final TelemetryService telemetryService;
  late final SettingsService settingsService;
  late final MockNotificationService notificationService;
  late final DataService dataService;
  late final String dbPath;

  const defaultTitle = 'Notification title';
  const defaultBody = 'Notification body';
  const defaultNote = 'Notification note';
  const fragileResinKey = 'fragile-resin';
  const keqingKey = 'keqing';

  final now = DateTime.now();
  final customNotificationCompletesAt = now.add(const Duration(days: 1));

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    telemetryService = MockTelemetryService();
    settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    when(settingsService.useTwentyFourHoursFormat).thenReturn(false);
    when(settingsService.serverResetTime).thenReturn(AppServerResetTimeType.northAmerica);

    notificationService = MockNotificationService();
    when(notificationService.cancelNotification(any, any)).thenAnswer((_) => Future.value());
    when(notificationService.scheduleNotification(any, any, any, any, any)).thenAnswer((_) => Future.value());
    final resourceService = getResourceService(settingsService);
    final genshinService = GenshinServiceImpl(resourceService, LocaleServiceImpl(settingsService));
    dataService = DataServiceImpl(genshinService, CalculatorAscMaterialsServiceImpl(genshinService, resourceService), resourceService);

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

  test(
    'Initial state',
    () => expect(
      NotificationsBloc(dataService, notificationService, settingsService, telemetryService).state,
      const NotificationsState.initial(notifications: []), reason: 'Should match expected value (property=state)'),
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'Init',
    build: () => NotificationsBloc(dataService, notificationService, settingsService, telemetryService),
    setUp: () async {
      await dataService.notifications.saveCustomNotification(
        keqingKey,
        defaultTitle,
        defaultBody,
        customNotificationCompletesAt,
        AppNotificationItemType.character,
        note: defaultNote,
      );
    },
    tearDown: () async {
      await dataService.deleteThemAll();
    },
    act: (bloc) => bloc.add(const NotificationsEvent.init()),
    verify: (bloc) {
      expect(bloc.state.notifications.length, 1, reason: 'Should match expected value (property=notifications, expected=1)');
      expect(bloc.state.useTwentyFourHoursFormat, settingsService.useTwentyFourHoursFormat, reason: 'Should match expected value (property=useTwentyFourHoursFormat)');

      final notif = bloc.state.notifications.first;
      expect(notif.key, 0, reason: 'Should match expected value (property=key, expected=0)');
      expect(notif.itemKey, keqingKey, reason: 'Should match expected value (property=itemKey)');
      expect(notif.title, defaultTitle, reason: 'Should match expected value (property=title)');
      expect(notif.body, defaultBody, reason: 'Should match expected value (property=body)');
      expect(notif.note, defaultNote, reason: 'Should match expected value (property=note)');
      checkAsset(notif.image);
      expect(notif.completesAt, customNotificationCompletesAt, reason: 'Should match expected value (property=completesAt)');
      expect(notif.type, AppNotificationType.custom, reason: 'Should match expected value (property=type, expected=AppNotificationType.custom)');
      expect(notif.notificationItemType, AppNotificationItemType.character, reason: 'Should match expected value (property=notificationItemType, expected=AppNotificationItemType.character)');
    },
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'Delete',
    setUp: () async {
      await dataService.notifications.saveCustomNotification(
        keqingKey,
        defaultTitle,
        defaultBody,
        customNotificationCompletesAt,
        AppNotificationItemType.character,
        note: defaultNote,
      );
    },
    tearDown: () async {
      await dataService.deleteThemAll();
    },
    build: () => NotificationsBloc(dataService, notificationService, settingsService, telemetryService),
    act: (bloc) => bloc.add(const NotificationsEvent.delete(id: 0, type: AppNotificationType.custom)),
    verify: (bloc) {
      verify(notificationService.cancelNotification(0, AppNotificationType.custom)).called(1);
      expect(bloc.state.notifications, isEmpty, reason: 'Should be empty (property=notifications)');
    },
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'Reset',
    setUp: () async {
      await dataService.notifications.saveResinNotification(fragileResinKey, defaultTitle, defaultBody, 100, note: defaultNote);
    },
    tearDown: () async {
      await dataService.deleteThemAll();
    },
    build: () => NotificationsBloc(dataService, notificationService, settingsService, telemetryService),
    act: (bloc) => bloc
      ..add(const NotificationsEvent.init())
      ..add(const NotificationsEvent.reset(id: 0, type: AppNotificationType.resin)),
    verify: (bloc) {
      verify(notificationService.cancelNotification(0, AppNotificationType.resin)).called(1);
      verify(notificationService.scheduleNotification(any, any, any, any, any)).called(1);
      expect(bloc.state.notifications.length, 1, reason: 'Should match expected value (property=notifications, expected=1)');

      final notif = bloc.state.notifications.first;
      expect(notif.key, 0, reason: 'Should match expected value (property=key, expected=0)');
      expect(notif.itemKey, fragileResinKey, reason: 'Should match expected value (property=itemKey)');
      expect(notif.title, defaultTitle, reason: 'Should match expected value (property=title)');
      expect(notif.body, defaultBody, reason: 'Should match expected value (property=body)');
      expect(notif.note, defaultNote, reason: 'Should match expected value (property=note)');
      checkAsset(notif.image);
      expect(notif.type, AppNotificationType.resin, reason: 'Should match expected value (property=type, expected=AppNotificationType.resin)');
      expect(notif.currentResinValue, 0, reason: 'Should match expected value (property=currentResinValue, expected=0)');
    },
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'Stop',
    setUp: () async {
      await dataService.notifications.saveResinNotification(fragileResinKey, defaultTitle, defaultBody, 100, note: defaultNote);
    },
    tearDown: () async {
      await dataService.deleteThemAll();
    },
    build: () => NotificationsBloc(dataService, notificationService, settingsService, telemetryService),
    act: (bloc) => bloc
      ..add(const NotificationsEvent.init())
      ..add(const NotificationsEvent.stop(id: 0, type: AppNotificationType.resin)),
    verify: (bloc) {
      verify(notificationService.cancelNotification(0, AppNotificationType.resin)).called(1);
      expect(bloc.state.notifications.length, 1, reason: 'Should match expected value (property=notifications, expected=1)');

      final notif = bloc.state.notifications.first;
      expect(notif.key, 0, reason: 'Should match expected value (property=key, expected=0)');
      expect(notif.itemKey, fragileResinKey, reason: 'Should match expected value (property=itemKey)');
      expect(notif.title, defaultTitle, reason: 'Should match expected value (property=title)');
      expect(notif.body, defaultBody, reason: 'Should match expected value (property=body)');
      expect(notif.note, defaultNote, reason: 'Should match expected value (property=note)');
      checkAsset(notif.image);
      expect(notif.type, AppNotificationType.resin, reason: 'Should match expected value (property=type, expected=AppNotificationType.resin)');
      expect(notif.currentResinValue, 100, reason: 'Should match expected value (property=currentResinValue, expected=100)');
      expect(notif.completesAt.difference(DateTime.now()).inSeconds, lessThanOrEqualTo(10), reason: 'Should be less than expected (property=inSeconds)');
    },
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'Reduce hours',
    setUp: () async {
      await dataService.notifications.saveCustomNotification(
        keqingKey,
        defaultTitle,
        defaultBody,
        now.add(const Duration(hours: 3)),
        AppNotificationItemType.character,
        note: defaultNote,
      );
    },
    tearDown: () async {
      await dataService.deleteThemAll();
    },
    build: () => NotificationsBloc(dataService, notificationService, settingsService, telemetryService),
    act: (bloc) => bloc
      ..add(const NotificationsEvent.init())
      ..add(const NotificationsEvent.reduceHours(id: 0, type: AppNotificationType.custom, hoursToReduce: 2)),
    verify: (bloc) {
      expect(bloc.state.notifications.length, 1, reason: 'Should match expected value (property=notifications, expected=1)');
      verify(notificationService.cancelNotification(0, AppNotificationType.custom)).called(1);
      verify(notificationService.scheduleNotification(any, any, any, any, any)).called(1);

      final notif = bloc.state.notifications.first;
      expect(notif.key, 0, reason: 'Should match expected value (property=key, expected=0)');
      expect(notif.itemKey, keqingKey, reason: 'Should match expected value (property=itemKey)');
      expect(notif.title, defaultTitle, reason: 'Should match expected value (property=title)');
      expect(notif.body, defaultBody, reason: 'Should match expected value (property=body)');
      expect(notif.note, defaultNote, reason: 'Should match expected value (property=note)');
      checkAsset(notif.image);
      expect(notif.type, AppNotificationType.custom, reason: 'Should match expected value (property=type, expected=AppNotificationType.custom)');
      expect(notif.notificationItemType, AppNotificationItemType.character, reason: 'Should match expected value (property=notificationItemType, expected=AppNotificationItemType.character)');
      expect(notif.completesAt, lessThanOrEqualTo(now.add(const Duration(hours: 1))), reason: 'Should be less than expected (property=completesAt)');
    },
  );
}
