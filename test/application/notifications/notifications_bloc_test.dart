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
      const NotificationsState.initial(notifications: []), reason: 'A freshly constructed NotificationsBloc should start in NotificationsState.initial with no notifications'),
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
      expect(bloc.state.notifications.length, 1, reason: 'After init, bloc should surface the single saved notification');
      expect(bloc.state.useTwentyFourHoursFormat, settingsService.useTwentyFourHoursFormat, reason: 'Init should propagate settings.useTwentyFourHoursFormat into state');

      final notif = bloc.state.notifications.first;
      expect(notif.key, 0, reason: 'First saved notification should get key 0');
      expect(notif.itemKey, keqingKey, reason: 'Loaded notification should keep its item key (expected=$keqingKey)');
      expect(notif.title, defaultTitle, reason: 'Loaded notification should keep its saved title');
      expect(notif.body, defaultBody, reason: 'Loaded notification should keep its saved body');
      expect(notif.note, defaultNote, reason: 'Loaded notification should keep its saved note');
      checkAsset(notif.image);
      expect(notif.completesAt, customNotificationCompletesAt, reason: 'Loaded notification should keep its saved completesAt');
      expect(notif.type, AppNotificationType.custom, reason: 'Loaded notification type should be custom');
      expect(notif.notificationItemType, AppNotificationItemType.character, reason: 'Loaded custom notification item type should be character');
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
      expect(bloc.state.notifications, isEmpty, reason: 'After delete, the notifications list should be empty');
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
      expect(bloc.state.notifications.length, 1, reason: 'After reset, the resin notification should remain in the list');

      final notif = bloc.state.notifications.first;
      expect(notif.key, 0, reason: 'Reset notification should keep key 0');
      expect(notif.itemKey, fragileResinKey, reason: 'Reset notification should keep its item key (expected=$fragileResinKey)');
      expect(notif.title, defaultTitle, reason: 'Reset notification should keep its saved title');
      expect(notif.body, defaultBody, reason: 'Reset notification should keep its saved body');
      expect(notif.note, defaultNote, reason: 'Reset notification should keep its saved note');
      checkAsset(notif.image);
      expect(notif.type, AppNotificationType.resin, reason: 'Reset notification type should stay resin');
      expect(notif.currentResinValue, 0, reason: 'Reset should set resin back to 0, got ${notif.currentResinValue}');
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
      expect(bloc.state.notifications.length, 1, reason: 'After stop, the resin notification should remain in the list');

      final notif = bloc.state.notifications.first;
      expect(notif.key, 0, reason: 'Stopped notification should keep key 0');
      expect(notif.itemKey, fragileResinKey, reason: 'Stopped notification should keep its item key (expected=$fragileResinKey)');
      expect(notif.title, defaultTitle, reason: 'Stopped notification should keep its saved title');
      expect(notif.body, defaultBody, reason: 'Stopped notification should keep its saved body');
      expect(notif.note, defaultNote, reason: 'Stopped notification should keep its saved note');
      checkAsset(notif.image);
      expect(notif.type, AppNotificationType.resin, reason: 'Stopped notification type should stay resin');
      expect(notif.currentResinValue, 100, reason: 'Stop should preserve current resin at 100, got ${notif.currentResinValue}');
      expect(notif.completesAt.difference(DateTime.now()).inSeconds, lessThanOrEqualTo(10), reason: 'Stop should mark the notification as completing now (within 10s)');
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
      expect(bloc.state.notifications.length, 1, reason: 'After reduceHours, the custom notification should remain in the list');
      verify(notificationService.cancelNotification(0, AppNotificationType.custom)).called(1);
      verify(notificationService.scheduleNotification(any, any, any, any, any)).called(1);

      final notif = bloc.state.notifications.first;
      expect(notif.key, 0, reason: 'Reduced notification should keep key 0');
      expect(notif.itemKey, keqingKey, reason: 'Reduced notification should keep its item key (expected=$keqingKey)');
      expect(notif.title, defaultTitle, reason: 'Reduced notification should keep its saved title');
      expect(notif.body, defaultBody, reason: 'Reduced notification should keep its saved body');
      expect(notif.note, defaultNote, reason: 'Reduced notification should keep its saved note');
      checkAsset(notif.image);
      expect(notif.type, AppNotificationType.custom, reason: 'Reduced notification type should stay custom');
      expect(notif.notificationItemType, AppNotificationItemType.character, reason: 'Reduced custom notification item type should stay character');
      expect(notif.completesAt, lessThanOrEqualTo(now.add(const Duration(hours: 1))), reason: 'Reducing 3h notification by 2h should push completesAt to <= now+1h');
    },
  );
}
