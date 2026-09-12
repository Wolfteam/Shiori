import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/extensions/datetime_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_asc_materials_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const String _baseDbFolder = 'shiori_notifications_data_service';

void main() {
  late final ResourceService resourceService;
  late final GenshinService genshinService;
  late final CalculatorAscMaterialsService calculatorService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settings = MockSettingsService();
    when(settings.language).thenReturn(AppLanguageType.english);
    final localeService = LocaleServiceImpl(settings);

    resourceService = getResourceService(settings);
    genshinService = GenshinServiceImpl(resourceService, localeService);
    calculatorService = CalculatorAscMaterialsServiceImpl(genshinService, resourceService);
    DataServiceImpl(genshinService, calculatorService, resourceService).registerAdapters();

    return Future(() async {
      await genshinService.init(AppLanguageType.english);
    });
  });

  void checkNotification(
    NotificationItem got,
    NotificationItem expected, {
    String? itemKey,
    String? title,
    String? body,
    String? note,
    bool? showNotification,
    bool checkCompletesAt = true,
    bool checkSpecifics = true,
  }) {
    expect(got.key, expected.key, reason: 'Persisted notification key must round-trip on read (expected=${expected.key})');
    expect(
      got.itemKey,
      itemKey ?? expected.itemKey,
      reason: 'Notification itemKey must round-trip (key=${got.key}, expected=${itemKey ?? expected.itemKey})',
    );
    expect(
      got.title,
      title ?? expected.title,
      reason: 'Notification title must round-trip (key=${got.key})',
    );
    expect(got.body, body ?? expected.body, reason: 'Notification body must round-trip (key=${got.key})');
    expect(got.createdAt, expected.createdAt, reason: 'Notification createdAt must round-trip (key=${got.key})');
    expect(got.scheduledDate, expected.scheduledDate, reason: 'Notification scheduledDate must round-trip (key=${got.key})');
    if (checkCompletesAt) {
      expect(got.completesAt, expected.completesAt, reason: 'Notification completesAt must round-trip (key=${got.key})');
    }
    expect(got.type, expected.type, reason: 'Notification type must round-trip (key=${got.key}, expected=${expected.type})');
    expect(got.note, note ?? expected.note, reason: 'Notification note must round-trip (key=${got.key})');
    expect(
      got.showNotification,
      showNotification ?? expected.showNotification,
      reason: 'Notification showNotification flag must round-trip (key=${got.key})',
    );
    if (!checkSpecifics) {
      return;
    }

    expect(
      got.currentResinValue,
      got.type != AppNotificationType.resin ? 0 : expected.currentResinValue,
      reason: 'currentResinValue must be 0 for non-resin notifications, else the saved value (key=${got.key}, type=${got.type})');

    expect(
      got.expeditionTimeType,
      got.type != AppNotificationType.expedition ? null : expected.expeditionTimeType,
      reason: 'expeditionTimeType must be null unless type is expedition (key=${got.key}, type=${got.type})');
    expect(
      got.withTimeReduction,
      got.type != AppNotificationType.expedition ? false : expected.withTimeReduction,
      reason: 'withTimeReduction must be false unless type is expedition (key=${got.key}, type=${got.type})');

    expect(
      got.notificationItemType,
      got.type != AppNotificationType.custom && got.type != AppNotificationType.dailyCheckIn
          ? null
          : expected.notificationItemType,
      reason: 'notificationItemType must be null unless type is custom or dailyCheckIn (key=${got.key}, type=${got.type})');

    expect(
      got.artifactFarmingTimeType,
      got.type != AppNotificationType.farmingArtifacts ? null : expected.artifactFarmingTimeType,
      reason: 'artifactFarmingTimeType must be null unless type is farmingArtifacts (key=${got.key}, type=${got.type})');

    expect(
      got.furnitureCraftingTimeType,
      got.type != AppNotificationType.furniture ? null : expected.furnitureCraftingTimeType,
      reason: 'furnitureCraftingTimeType must be null unless type is furniture (key=${got.key}, type=${got.type})');

    expect(
      got.realmTrustRank,
      got.type != AppNotificationType.realmCurrency ? null : expected.realmTrustRank,
      reason: 'realmTrustRank must be null unless type is realmCurrency (key=${got.key}, type=${got.type})');
    expect(
      got.realmRankType,
      got.type != AppNotificationType.realmCurrency ? null : expected.realmRankType,
      reason: 'realmRankType must be null unless type is realmCurrency (key=${got.key}, type=${got.type})');
    expect(
      got.realmCurrency,
      got.type != AppNotificationType.realmCurrency ? null : expected.realmCurrency,
      reason: 'realmCurrency must be null unless type is realmCurrency (key=${got.key}, type=${got.type})');
  }

  void checkUpdatedNotification(
    NotificationItem got,
    NotificationItem expected,
    String title,
    String body,
    String note,
    bool showNotification, {
    String? itemKey,
  }) {
    checkNotification(
      got,
      expected,
      title: title,
      body: body,
      note: note,
      itemKey: itemKey,
      showNotification: showNotification,
      checkCompletesAt: false,
      checkSpecifics: false,
    );
  }

  String getValidItemKey(AppNotificationType type) {
    return switch (type) {
      AppNotificationType.resin => genshinService.materials.getFragileResinMaterial().key,
      AppNotificationType.expedition => 'mora',
      AppNotificationType.farmingMaterials => 'valberry',
      AppNotificationType.farmingArtifacts => 'adventurer',
      AppNotificationType.gadget => genshinService.gadgets.getAllGadgetsForNotifications().first.key,
      AppNotificationType.furniture => genshinService.furniture.getDefaultFurnitureForNotifications().key,
      AppNotificationType.realmCurrency => genshinService.materials.getRealmCurrencyMaterial().key,
      AppNotificationType.weeklyBoss => 'childe',
      AppNotificationType.custom => 'keqing',
      AppNotificationType.dailyCheckIn => 'primogem',
    };
  }

  Future<NotificationItem> saveNotification(AppNotificationType type, DataService dataService) {
    final String itemKey = getValidItemKey(type);
    final String title = 'The title for type $type';
    final String body = 'The body for type $type';
    final String note = 'The note for type $type';

    return switch (type) {
      AppNotificationType.resin => dataService.notifications.saveResinNotification(
        itemKey,
        title,
        body,
        100,
        note: note,
      ),
      AppNotificationType.expedition => dataService.notifications.saveExpeditionNotification(
        itemKey,
        title,
        body,
        ExpeditionTimeType.fourHours,
        note: note,
      ),
      AppNotificationType.farmingMaterials => dataService.notifications.saveFarmingMaterialNotification(
        itemKey,
        title,
        body,
        note: note,
      ),
      AppNotificationType.farmingArtifacts => dataService.notifications.saveFarmingArtifactNotification(
        itemKey,
        ArtifactFarmingTimeType.twentyFourHours,
        title,
        body,
        note: note,
      ),
      AppNotificationType.gadget => dataService.notifications.saveGadgetNotification(
        genshinService.gadgets.getAllGadgetsForNotifications().first.key,
        title,
        body,
        note: note,
      ),
      AppNotificationType.furniture => dataService.notifications.saveFurnitureNotification(
        genshinService.furniture.getDefaultFurnitureForNotifications().key,
        FurnitureCraftingTimeType.sixteenHours,
        title,
        body,
        note: note,
      ),
      AppNotificationType.realmCurrency => dataService.notifications.saveRealmCurrencyNotification(
        itemKey,
        RealmRankType.exquisite,
        realmTrustRank.keys.first,
        10,
        title,
        body,
        note: note,
      ),
      AppNotificationType.weeklyBoss => dataService.notifications.saveWeeklyBossNotification(
        itemKey,
        AppServerResetTimeType.northAmerica,
        title,
        body,
        note: note,
      ),
      AppNotificationType.custom => dataService.notifications.saveCustomNotification(
        itemKey,
        title,
        body,
        DateTime.now().add(const Duration(days: 10)),
        AppNotificationItemType.character,
        note: note,
      ),
      AppNotificationType.dailyCheckIn => dataService.notifications.saveDailyCheckInNotification(
        itemKey,
        title,
        body,
        note: note,
      ),
    };
  }

  void checkBackupCommon(BaseBackupNotificationModel got, NotificationItem expected) {
    expect(
      got.type,
      expected.type.index,
      reason: 'Backup entry type index must match source notification (itemKey=${expected.itemKey}, expected=${expected.type.index})',
    );
    expect(got.itemKey, expected.itemKey, reason: 'Backup entry itemKey must match source (expected=${expected.itemKey})');
    expect(
      got.completesAt.difference(expected.completesAt).inSeconds <= 1,
      isTrue,
      reason: 'Backup completesAt must match source within 1s (itemKey=${expected.itemKey})',
    );
    expect(
      got.showNotification,
      expected.showNotification,
      reason: 'Backup showNotification must match source (itemKey=${expected.itemKey})',
    );
    expect(got.note, expected.note, reason: 'Backup note must match source (itemKey=${expected.itemKey})');
    expect(got.title, expected.title, reason: 'Backup title must match source (itemKey=${expected.itemKey})');
    expect(got.body, expected.body, reason: 'Backup body must match source (itemKey=${expected.itemKey})');
  }

  void checkBackup(BackupNotificationsModel bk, List<NotificationItem> notifications) {
    expect(bk.custom.length, 2, reason: 'Backup custom box must hold both custom and dailyCheckIn entries (expected 2)');
    for (final custom in bk.custom) {
      final expectedCustom = notifications.firstWhere((el) => el.type.index == custom.type);
      checkBackupCommon(custom, expectedCustom);
      expect(
        custom.notificationItemType,
        expectedCustom.notificationItemType!.index,
        reason: 'Backup custom entry notificationItemType index must match source (type=${custom.type})',
      );
    }

    expect(bk.expeditions.length, 1, reason: 'Backup must contain exactly 1 expedition notification');
    final gotExpedition = bk.expeditions.first;
    final expectedExpedition = notifications.firstWhere((el) => el.type.index == gotExpedition.type);
    checkBackupCommon(gotExpedition, expectedExpedition);
    expect(
      gotExpedition.expeditionTimeType,
      expectedExpedition.expeditionTimeType!.index,
      reason: 'Backup expedition timeType index must match source',
    );
    expect(
      gotExpedition.withTimeReduction,
      expectedExpedition.withTimeReduction,
      reason: 'Backup expedition withTimeReduction must match source',
    );

    expect(bk.farmingArtifact.length, 1, reason: 'Backup must contain exactly 1 farming-artifact notification');
    final gotFarmingArtifact = bk.farmingArtifact.first;
    final expectedFarmingArtifact = notifications.firstWhere((el) => el.type.index == gotFarmingArtifact.type);
    checkBackupCommon(gotFarmingArtifact, expectedFarmingArtifact);
    expect(
      gotFarmingArtifact.artifactFarmingTimeType,
      expectedFarmingArtifact.artifactFarmingTimeType!.index,
      reason: 'Backup farming-artifact timeType index must match source',
    );

    expect(bk.farmingMaterial.length, 1, reason: 'Backup must contain exactly 1 farming-material notification');
    final gotFarmingMaterial = bk.farmingMaterial.first;
    final expectedFarmingMaterial = notifications.firstWhere((el) => el.type.index == gotFarmingMaterial.type);
    checkBackupCommon(gotFarmingMaterial, expectedFarmingMaterial);

    expect(bk.furniture.length, 1, reason: 'Backup must contain exactly 1 furniture notification');
    final gotFurniture = bk.furniture.first;
    final expectedFurniture = notifications.firstWhere((el) => el.type.index == gotFurniture.type);
    checkBackupCommon(gotFurniture, expectedFurniture);
    expect(
      gotFurniture.furnitureCraftingTimeType,
      expectedFurniture.furnitureCraftingTimeType!.index,
      reason: 'Backup furniture craftingTimeType index must match source',
    );

    expect(bk.gadgets.length, 1, reason: 'Backup must contain exactly 1 gadget notification');
    final gotGadget = bk.gadgets.first;
    final expectedGadget = notifications.firstWhere((el) => el.type.index == gotGadget.type);
    checkBackupCommon(gotGadget, expectedGadget);

    expect(bk.realmCurrency.length, 1, reason: 'Backup must contain exactly 1 realm-currency notification');
    final gotRealmCurrency = bk.realmCurrency.first;
    final expectedRealmCurrency = notifications.firstWhere((el) => el.type.index == gotRealmCurrency.type);
    checkBackupCommon(gotRealmCurrency, expectedRealmCurrency);
    expect(
      gotRealmCurrency.realmTrustRank,
      expectedRealmCurrency.realmTrustRank,
      reason: 'Backup realm-currency trustRank must match source',
    );
    expect(
      gotRealmCurrency.realmRankType,
      expectedRealmCurrency.realmRankType!.index,
      reason: 'Backup realm-currency rankType index must match source',
    );
    expect(
      gotRealmCurrency.realmCurrency,
      expectedRealmCurrency.realmCurrency,
      reason: 'Backup realm-currency amount must match source',
    );

    expect(bk.resin.length, 1, reason: 'Backup must contain exactly 1 resin notification');
    final gotResin = bk.resin.first;
    final expectedResin = notifications.firstWhere((el) => el.type.index == gotResin.type);
    checkBackupCommon(gotResin, expectedResin);
    expect(gotResin.currentResinValue, expectedResin.currentResinValue, reason: 'Backup resin currentResinValue must match source');

    expect(bk.weeklyBosses.length, 1, reason: 'Backup must contain exactly 1 weekly-boss notification');
    final gotWeeklyBoss = bk.weeklyBosses.first;
    final expectedWeeklyBoss = notifications.firstWhere((el) => el.type.index == gotWeeklyBoss.type);
    checkBackupCommon(gotWeeklyBoss, expectedWeeklyBoss);
  }

  group('Get all notifications', () {
    const dbFolder = '${_baseDbFolder}_get_all_notifications_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('no data exist', () {
      final notifications = dataService.notifications.getAllNotifications();
      expect(notifications.isEmpty, isTrue, reason: 'getAllNotifications must return empty when nothing has been saved');
    });

    test('data exists', () async {
      final expected = await dataService.notifications.saveDailyCheckInNotification('primogem', 'Resin', '4u');
      final notifications = dataService.notifications.getAllNotifications();
      expect(notifications.length, 1, reason: 'getAllNotifications must return the single saved notification');
      final got = notifications.first;
      checkNotification(got, expected);
    });
  });

  group('Get notification', () {
    const dbFolder = '${_baseDbFolder}_get_notification_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    for (final type in AppNotificationType.values) {
      test('key is not valid for type = ${type.name}', () {
        expect(
          () => dataService.notifications.getNotification(-1, type),
          throwsArgumentError,
          reason: 'getNotification with negative key must throw ArgumentError (type=${type.name})',
        );
      });

      test('for type = ${type.name} which does not exist', () {
        expect(
          () => dataService.notifications.getNotification(666, type),
          throwsA(isA<NotFoundError>()),
          reason: 'getNotification for a missing key must throw NotFoundError (key=666, type=${type.name})',
        );
      });

      test('for type = ${type.name} which exists', () async {
        final expected = await saveNotification(type, dataService);
        final got = dataService.notifications.getNotification(expected.key, type);
        checkNotification(got, expected);
      });
    }
  });

  group('Save resin notification', () {
    const dbFolder = '${_baseDbFolder}_save_resin_notification_tests';
    const type = AppNotificationType.resin;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.saveResinNotification('', 'title', 'body', 0, note: 'Note'),
        throwsArgumentError,
        reason: 'saveResinNotification with empty itemKey must throw ArgumentError',
      );
    });

    test('invalid title', () {
      expect(
        dataService.notifications.saveResinNotification(getValidItemKey(type), '', 'body', 0, note: 'Note'),
        throwsArgumentError,
        reason: 'saveResinNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.saveResinNotification(getValidItemKey(type), 'title', '', 0, note: 'Note'),
        throwsArgumentError,
        reason: 'saveResinNotification with empty body must throw ArgumentError');
    });

    test('invalid resin value', () {
      expect(
        dataService.notifications.saveResinNotification(getValidItemKey(type), 'title', 'body', -1, note: 'Note'),
        throwsArgumentError,
        reason: 'saveResinNotification with negative resin value must throw ArgumentError');
    });

    test('valid call', () async {
      final expected = await saveNotification(type, dataService);
      final got = dataService.notifications.getNotification(expected.key, type);
      checkNotification(got, expected);
    });
  });

  group('Save expedition notification', () {
    const dbFolder = '${_baseDbFolder}_save_expedition_notification_tests';
    const type = AppNotificationType.expedition;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.saveExpeditionNotification(
          '',
          'title',
          'body',
          ExpeditionTimeType.twelveHours,
          note: 'Note',
          withTimeReduction: true,
        ),
        throwsArgumentError,
        reason: 'saveExpeditionNotification with empty itemKey must throw ArgumentError');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.saveExpeditionNotification(
          getValidItemKey(type),
          '',
          'body',
          ExpeditionTimeType.twelveHours,
          note: 'Note',
          withTimeReduction: true,
        ),
        throwsArgumentError,
        reason: 'saveExpeditionNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.saveExpeditionNotification(
          getValidItemKey(type),
          'title',
          '',
          ExpeditionTimeType.twelveHours,
          note: 'Note',
          withTimeReduction: true,
        ),
        throwsArgumentError,
        reason: 'saveExpeditionNotification with empty body must throw ArgumentError');
    });

    test('valid call', () async {
      final expected = await saveNotification(type, dataService);
      final got = dataService.notifications.getNotification(expected.key, type);
      checkNotification(got, expected);
    });
  });

  group('Save gadget notification', () {
    const dbFolder = '${_baseDbFolder}_save_gadget_notification_tests';
    const type = AppNotificationType.gadget;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.saveGadgetNotification('', 'title', 'body', note: 'Note'),
        throwsArgumentError,
        reason: 'saveGadgetNotification with empty itemKey must throw ArgumentError',
      );
    });

    test('invalid title', () {
      expect(
        dataService.notifications.saveGadgetNotification(getValidItemKey(type), '', 'body', note: 'Note'),
        throwsArgumentError,
        reason: 'saveGadgetNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.saveGadgetNotification(getValidItemKey(type), 'title', '', note: 'Note'),
        throwsArgumentError,
        reason: 'saveGadgetNotification with empty body must throw ArgumentError');
    });

    test('valid call', () async {
      final expected = await saveNotification(type, dataService);
      final got = dataService.notifications.getNotification(expected.key, type);
      checkNotification(got, expected);
    });
  });

  group('Save furniture notification', () {
    const dbFolder = '${_baseDbFolder}_save_furniture_notification_tests';
    const type = AppNotificationType.furniture;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.saveFurnitureNotification(
          '',
          FurnitureCraftingTimeType.fourteenHours,
          'title',
          'body',
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'saveFurnitureNotification with empty itemKey must throw ArgumentError');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.saveFurnitureNotification(
          getValidItemKey(type),
          FurnitureCraftingTimeType.fourteenHours,
          '',
          'body',
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'saveFurnitureNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.saveFurnitureNotification(
          getValidItemKey(type),
          FurnitureCraftingTimeType.fourteenHours,
          'title',
          '',
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'saveFurnitureNotification with empty body must throw ArgumentError');
    });

    test('valid call', () async {
      final expected = await saveNotification(type, dataService);
      final got = dataService.notifications.getNotification(expected.key, type);
      checkNotification(got, expected);
    });
  });

  group('Save farming artifact notification', () {
    const dbFolder = '${_baseDbFolder}_save_farming_artifact_notification_tests';
    const type = AppNotificationType.farmingArtifacts;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.saveFarmingArtifactNotification(
          '',
          ArtifactFarmingTimeType.twentyFourHours,
          'title',
          'body',
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'saveFarmingArtifactNotification with empty itemKey must throw ArgumentError');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.saveFarmingArtifactNotification(
          getValidItemKey(type),
          ArtifactFarmingTimeType.twentyFourHours,
          '',
          'body',
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'saveFarmingArtifactNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.saveFarmingArtifactNotification(
          getValidItemKey(type),
          ArtifactFarmingTimeType.twentyFourHours,
          'title',
          '',
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'saveFarmingArtifactNotification with empty body must throw ArgumentError');
    });

    test('valid call', () async {
      final expected = await saveNotification(type, dataService);
      final got = dataService.notifications.getNotification(expected.key, type);
      checkNotification(got, expected);
    });
  });

  group('Save farming material notification', () {
    const dbFolder = '${_baseDbFolder}_save_farming_material_notification_tests';
    const type = AppNotificationType.farmingMaterials;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.saveFarmingMaterialNotification('', 'title', 'body', note: 'Note'),
        throwsArgumentError,
        reason: 'saveFarmingMaterialNotification with empty itemKey must throw ArgumentError',
      );
    });

    test('invalid title', () {
      expect(
        dataService.notifications.saveFarmingMaterialNotification(getValidItemKey(type), '', 'body', note: 'Note'),
        throwsArgumentError,
        reason: 'saveFarmingMaterialNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.saveFarmingMaterialNotification(getValidItemKey(type), 'title', '', note: 'Note'),
        throwsArgumentError,
        reason: 'saveFarmingMaterialNotification with empty body must throw ArgumentError');
    });

    test('valid call', () async {
      final expected = await saveNotification(type, dataService);
      final got = dataService.notifications.getNotification(expected.key, type);
      checkNotification(got, expected);
    });
  });

  group('Save realm currency notification', () {
    const dbFolder = '${_baseDbFolder}_save_realm_currency_notification_tests';
    const type = AppNotificationType.realmCurrency;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.saveRealmCurrencyNotification('', RealmRankType.cozy, 1, 100, 'title', 'body', note: 'Note'),
        throwsArgumentError,
        reason: 'saveRealmCurrencyNotification with empty itemKey must throw ArgumentError');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.saveRealmCurrencyNotification(
          getValidItemKey(type),
          RealmRankType.cozy,
          1,
          100,
          '',
          'body',
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'saveRealmCurrencyNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.saveRealmCurrencyNotification(
          getValidItemKey(type),
          RealmRankType.cozy,
          1,
          100,
          'title',
          '',
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'saveRealmCurrencyNotification with empty body must throw ArgumentError');
    });

    test('invalid rank level', () {
      expect(
        dataService.notifications.saveRealmCurrencyNotification(
          getValidItemKey(type),
          RealmRankType.cozy,
          0,
          100,
          'title',
          'body',
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'saveRealmCurrencyNotification with trust-rank level 0 must throw ArgumentError');
    });

    test('invalid realm currency', () {
      expect(
        dataService.notifications.saveRealmCurrencyNotification(
          getValidItemKey(type),
          RealmRankType.cozy,
          1,
          -1,
          'title',
          'body',
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'saveRealmCurrencyNotification with negative currency must throw ArgumentError');
    });

    test('valid call', () async {
      final expected = await saveNotification(type, dataService);
      final got = dataService.notifications.getNotification(expected.key, type);
      checkNotification(got, expected);
    });
  });

  group('Save weekly boss notification', () {
    const dbFolder = '${_baseDbFolder}_save_weekly_boss_notification_tests';
    const type = AppNotificationType.weeklyBoss;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.saveWeeklyBossNotification(
          '',
          AppServerResetTimeType.northAmerica,
          'title',
          'body',
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'saveWeeklyBossNotification with empty itemKey must throw ArgumentError');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.saveWeeklyBossNotification(
          getValidItemKey(type),
          AppServerResetTimeType.northAmerica,
          '',
          'body',
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'saveWeeklyBossNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.saveWeeklyBossNotification(
          getValidItemKey(type),
          AppServerResetTimeType.northAmerica,
          'title',
          '',
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'saveWeeklyBossNotification with empty body must throw ArgumentError');
    });

    test('valid call', () async {
      final expected = await saveNotification(type, dataService);
      final got = dataService.notifications.getNotification(expected.key, type);
      checkNotification(got, expected);
    });
  });

  group('Save custom notification', () {
    const dbFolder = '${_baseDbFolder}_save_custom_notification_tests';
    const type = AppNotificationType.custom;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.saveCustomNotification(
          '',
          'title',
          'body',
          DateTime.now(),
          AppNotificationItemType.character,
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'saveCustomNotification with empty itemKey must throw ArgumentError');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.saveCustomNotification(
          getValidItemKey(type),
          '',
          'body',
          DateTime.now(),
          AppNotificationItemType.character,
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'saveCustomNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.saveCustomNotification(
          getValidItemKey(type),
          'title',
          '',
          DateTime.now(),
          AppNotificationItemType.character,
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'saveCustomNotification with empty body must throw ArgumentError');
    });

    test('valid call', () async {
      final expected = await saveNotification(type, dataService);
      final got = dataService.notifications.getNotification(expected.key, type);
      checkNotification(got, expected);
    });
  });

  group('Save daily check in notification', () {
    const dbFolder = '${_baseDbFolder}_save_daily_check_in_notification_tests';
    const type = AppNotificationType.dailyCheckIn;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.saveDailyCheckInNotification('', 'title', 'body', note: 'Note'),
        throwsArgumentError,
        reason: 'saveDailyCheckInNotification with empty itemKey must throw ArgumentError',
      );
    });

    test('invalid title', () {
      expect(
        dataService.notifications.saveDailyCheckInNotification(getValidItemKey(type), '', 'body', note: 'Note'),
        throwsArgumentError,
        reason: 'saveDailyCheckInNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.saveDailyCheckInNotification(getValidItemKey(type), 'title', '', note: 'Note'),
        throwsArgumentError,
        reason: 'saveDailyCheckInNotification with empty body must throw ArgumentError');
    });

    test('valid call', () async {
      final expected = await saveNotification(type, dataService);
      final got = dataService.notifications.getNotification(expected.key, type);
      checkNotification(got, expected);
    });
  });

  group('Delete notification', () {
    const dbFolder = '${_baseDbFolder}_delete_notification_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    for (final type in AppNotificationType.values) {
      test('key is not valid for type = ${type.name}', () {
        expect(
          dataService.notifications.deleteNotification(-1, type),
          throwsArgumentError,
          reason: 'deleteNotification with negative key must throw ArgumentError (type=${type.name})',
        );
      });

      test('of type = ${type.name} which does not exist', () {
        expect(
          dataService.notifications.deleteNotification(666, type),
          completes,
          reason: 'deleteNotification for a missing key must be a no-op that completes (key=666, type=${type.name})',
        );
      });

      test('of type = ${type.name} which exists', () async {
        final notification = await saveNotification(type, dataService);
        await dataService.notifications.deleteNotification(notification.key, type);
        expect(
          () => dataService.notifications.getNotification(notification.key, type),
          throwsA(isA<NotFoundError>()),
          reason: 'Deleted notification must no longer be retrievable, getNotification should throw '
              'NotFoundError (key=${notification.key}, type=${type.name})',
        );
      });
    }
  });

  group('Reset notification', () {
    const dbFolder = '${_baseDbFolder}_reset_notification_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    for (final type in AppNotificationType.values) {
      test('key is not valid for type = ${type.name}', () {
        expect(
          dataService.notifications.resetNotification(-1, type, AppServerResetTimeType.asia),
          throwsArgumentError,
          reason: 'resetNotification with negative key must throw ArgumentError (type=${type.name})',
        );
      });

      test('of type = ${type.name} which does not exist', () {
        expect(
          dataService.notifications.resetNotification(666, type, AppServerResetTimeType.europe),
          throwsA(isA<NotFoundError>()),
          reason: 'resetNotification for a missing key must throw NotFoundError (key=666, type=${type.name})');
      });

      test('of type = ${type.name} which exists', () async {
        final notification = await saveNotification(type, dataService);
        final updatedNotification = await dataService.notifications.resetNotification(
          notification.key,
          type,
          AppServerResetTimeType.northAmerica,
        );

        switch (type) {
          case AppNotificationType.custom:
            expect(
              updatedNotification.completesAt,
              notification.completesAt,
              reason: 'Resetting a custom notification must leave its user-set completesAt unchanged (key=${notification.key})',
            );
          case AppNotificationType.weeklyBoss:
            final Duration diff = notification.completesAt.difference(updatedNotification.completesAt);
            expect(
              diff.inSeconds <= 1,
              isTrue,
              reason: 'Resetting a weekly-boss notification must keep completesAt within 1s of the original '
                  '(key=${notification.key})',
            );
          default:
            expect(
              updatedNotification.completesAt.isAfter(notification.completesAt),
              isTrue,
              reason: 'Resetting a ${type.name} notification must push completesAt into the future (key=${notification.key})',
            );
        }
      });
    }
  });

  group('Stop notification', () {
    const dbFolder = '${_baseDbFolder}_stop_notification_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    for (final type in AppNotificationType.values) {
      test('key is not valid for type ${type.name}', () {
        expect(
          dataService.notifications.stopNotification(-1, type),
          throwsArgumentError,
          reason: 'stopNotification with negative key must throw ArgumentError (type=${type.name})',
        );
      });

      test('for type ${type.name} which does not exist', () {
        expect(
          dataService.notifications.stopNotification(666, type),
          throwsA(isA<NotFoundError>()),
          reason: 'stopNotification for a missing key must throw NotFoundError (key=666, type=${type.name})',
        );
      });

      test('for type ${type.name} which exists', () async {
        final notification = await saveNotification(type, dataService);
        final updatedNotification = await dataService.notifications.stopNotification(notification.key, type);
        expect(
          updatedNotification.completesAt.isBeforeInclusive(DateTime.now()),
          isTrue,
          reason: 'Stopping a notification must set completesAt to now-or-earlier (key=${notification.key}, type=${type.name})',
        );
      });
    }
  });

  group('Update resin notification', () {
    const dbFolder = '${_baseDbFolder}_update_resin_notification_tests';
    const type = AppNotificationType.resin;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid key', () {
      expect(
        dataService.notifications.updateResinNotification(-1, 'title', 'body', 0, true, note: 'Note'),
        throwsArgumentError,
        reason: 'updateResinNotification with negative key must throw ArgumentError',
      );
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateResinNotification(1, '', 'body', 0, true, note: 'Note'),
        throwsArgumentError,
        reason: 'updateResinNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateResinNotification(1, 'title', '', 0, true, note: 'Note'),
        throwsArgumentError,
        reason: 'updateResinNotification with empty body must throw ArgumentError');
    });

    test('invalid resin value', () {
      expect(
        dataService.notifications.updateResinNotification(1, 'title', 'body', -1, true, note: 'Note'),
        throwsArgumentError,
        reason: 'updateResinNotification with negative resin value must throw ArgumentError');
    });

    test('which does not exist', () {
      expect(
        dataService.notifications.updateResinNotification(666, 'title', 'body', 0, true),
        throwsA(isA<NotFoundError>()),
        reason: 'updateResinNotification for a missing key must throw NotFoundError (key=666)');
    });

    test('valid call', () async {
      const String title = 'Updated title';
      const String body = 'Updated body';
      const String note = 'Updated note';
      final notification = await saveNotification(type, dataService);
      final updated = await dataService.notifications.updateResinNotification(
        notification.key,
        title,
        body,
        notification.currentResinValue ~/ 2,
        !notification.showNotification,
        note: note,
      );
      checkUpdatedNotification(updated, notification, title, body, note, !notification.showNotification);
      expect(
        updated.completesAt.isAfter(notification.completesAt),
        isTrue,
        reason: 'Updating a resin notification must push completesAt into the future (key=${notification.key})',
      );
      expect(
        updated.currentResinValue,
        notification.currentResinValue ~/ 2,
        reason: 'Updated resin value must equal the halved input (key=${notification.key}, '
            'expected=${notification.currentResinValue ~/ 2})',
      );
    });
  });

  group('Update expedition notification', () {
    const dbFolder = '${_baseDbFolder}_update_expedition_notification_tests';
    const type = AppNotificationType.expedition;
    late DataService dataService;
    late String dbPath;
    final String validItemKey = getValidItemKey(type);

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid key', () {
      expect(
        dataService.notifications.updateExpeditionNotification(
          -1,
          validItemKey,
          ExpeditionTimeType.eightHours,
          'title',
          'body',
          true,
          true,
        ),
        throwsArgumentError,
        reason: 'updateExpeditionNotification with negative key must throw ArgumentError');
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.updateExpeditionNotification(
          1,
          '',
          ExpeditionTimeType.eightHours,
          'title',
          'body',
          true,
          true,
          note: 'Note',
        ),
        throwsArgumentError,
        reason: 'updateExpeditionNotification with empty itemKey must throw ArgumentError');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateExpeditionNotification(
          1,
          validItemKey,
          ExpeditionTimeType.eightHours,
          '',
          'body',
          true,
          true,
        ),
        throwsArgumentError,
        reason: 'updateExpeditionNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateExpeditionNotification(
          1,
          validItemKey,
          ExpeditionTimeType.eightHours,
          'title',
          '',
          true,
          true,
        ),
        throwsArgumentError,
        reason: 'updateExpeditionNotification with empty body must throw ArgumentError');
    });

    test('which does not exist', () {
      expect(
        dataService.notifications.updateExpeditionNotification(
          666,
          validItemKey,
          ExpeditionTimeType.eightHours,
          'title',
          'body',
          true,
          true,
        ),
        throwsA(isA<NotFoundError>()),
        reason: 'updateExpeditionNotification for a missing key must throw NotFoundError (key=666)');
    });

    test('valid call', () async {
      const String itemKey = 'carrot';
      const String title = 'Updated title';
      const String body = 'Updated body';
      const String note = 'Updated note';
      const expeditionTime = ExpeditionTimeType.twentyHours;
      final notification = await saveNotification(type, dataService);
      final updated = await dataService.notifications.updateExpeditionNotification(
        notification.key,
        itemKey,
        expeditionTime,
        title,
        body,
        !notification.showNotification,
        !notification.withTimeReduction,
        note: note,
      );
      checkUpdatedNotification(updated, notification, title, body, note, !notification.showNotification, itemKey: itemKey);
      expect(
        updated.completesAt.isAfter(notification.completesAt) || updated.completesAt.isBefore(notification.completesAt),
        isTrue,
        reason: 'Updating an expedition notification must recompute completesAt (key=${notification.key})');
      expect(
        updated.withTimeReduction,
        !notification.withTimeReduction,
        reason: 'Updated expedition withTimeReduction must reflect the toggled input (key=${notification.key})',
      );
      expect(
        updated.expeditionTimeType,
        expeditionTime,
        reason: 'Updated expedition timeType must equal the input (key=${notification.key}, expected=$expeditionTime)',
      );
    });
  });

  group('Update farming material notification', () {
    const dbFolder = '${_baseDbFolder}_farming_material_notification_tests';
    const type = AppNotificationType.farmingMaterials;
    late DataService dataService;
    late String dbPath;
    final String validItemKey = getValidItemKey(type);

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid key', () {
      expect(
        dataService.notifications.updateFarmingMaterialNotification(-1, validItemKey, 'title', 'body', true),
        throwsArgumentError,
        reason: 'updateFarmingMaterialNotification with negative key must throw ArgumentError');
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.updateFarmingMaterialNotification(1, '', 'title', 'body', true),
        throwsArgumentError,
        reason: 'updateFarmingMaterialNotification with empty itemKey must throw ArgumentError');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateFarmingMaterialNotification(1, validItemKey, '', 'body', true),
        throwsArgumentError,
        reason: 'updateFarmingMaterialNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateFarmingMaterialNotification(1, validItemKey, 'title', '', true),
        throwsArgumentError,
        reason: 'updateFarmingMaterialNotification with empty body must throw ArgumentError');
    });

    test('which does not exist', () {
      expect(
        dataService.notifications.updateFarmingMaterialNotification(666, validItemKey, 'title', 'body', true),
        throwsA(isA<NotFoundError>()),
        reason: 'updateFarmingMaterialNotification for a missing key must throw NotFoundError (key=666)');
    });

    test('valid call', () async {
      const String itemKey = 'wolfhook';
      const String title = 'Updated title';
      const String body = 'Updated body';
      const String note = 'Updated note';
      final notification = await saveNotification(type, dataService);
      final updated = await dataService.notifications.updateFarmingMaterialNotification(
        notification.key,
        itemKey,
        title,
        body,
        !notification.showNotification,
        note: note,
      );
      checkUpdatedNotification(updated, notification, title, body, note, !notification.showNotification, itemKey: itemKey);
      expect(
        updated.completesAt.isAfter(notification.completesAt),
        isTrue,
        reason: 'Updating a farming-material notification must push completesAt into the future (key=${notification.key})',
      );
    });
  });

  group('Update farming artifact notification', () {
    const dbFolder = '${_baseDbFolder}_farming_artifact_notification_tests';
    const type = AppNotificationType.farmingArtifacts;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid key', () {
      expect(
        dataService.notifications.updateFarmingArtifactNotification(
          -1,
          ArtifactFarmingTimeType.twelveHours,
          'title',
          'body',
          true,
        ),
        throwsArgumentError,
        reason: 'updateFarmingArtifactNotification with negative key must throw ArgumentError');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateFarmingArtifactNotification(1, ArtifactFarmingTimeType.twelveHours, '', 'body', true),
        throwsArgumentError,
        reason: 'updateFarmingArtifactNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateFarmingArtifactNotification(1, ArtifactFarmingTimeType.twelveHours, 'title', '', true),
        throwsArgumentError,
        reason: 'updateFarmingArtifactNotification with empty body must throw ArgumentError');
    });

    test('which does not exist', () {
      expect(
        dataService.notifications.updateFarmingArtifactNotification(
          666,
          ArtifactFarmingTimeType.twelveHours,
          'title',
          'body',
          true,
        ),
        throwsA(isA<NotFoundError>()),
        reason: 'updateFarmingArtifactNotification for a missing key must throw NotFoundError (key=666)');
    });

    test('valid call', () async {
      const String title = 'Updated title';
      const String body = 'Updated body';
      const String note = 'Updated note';
      const farmingTime = ArtifactFarmingTimeType.twelveHours;
      final notification = await saveNotification(type, dataService);
      final updated = await dataService.notifications.updateFarmingArtifactNotification(
        notification.key,
        farmingTime,
        title,
        body,
        !notification.showNotification,
        note: note,
      );
      checkUpdatedNotification(updated, notification, title, body, note, !notification.showNotification);
      expect(
        updated.completesAt.isAfter(notification.completesAt) || updated.completesAt.isBefore(notification.completesAt),
        isTrue,
        reason: 'Updating a farming-artifact notification must recompute completesAt (key=${notification.key})');
      expect(
        updated.artifactFarmingTimeType,
        farmingTime,
        reason: 'Updated artifact farmingTime must equal the input (key=${notification.key}, expected=$farmingTime)',
      );
    });
  });

  group('Update gadget notification', () {
    const dbFolder = '${_baseDbFolder}_gadget_notification_tests';
    const type = AppNotificationType.gadget;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid key', () {
      expect(
        dataService.notifications.updateGadgetNotification(-1, 'itemKey', 'title', 'body', true),
        throwsArgumentError,
        reason: 'updateGadgetNotification with negative key must throw ArgumentError');
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.updateGadgetNotification(1, '', 'title', 'body', true),
        throwsArgumentError,
        reason: 'updateGadgetNotification with empty itemKey must throw ArgumentError');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateGadgetNotification(1, 'itemKey', '', 'body', true),
        throwsArgumentError,
        reason: 'updateGadgetNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateGadgetNotification(1, 'itemKey', 'title', '', true),
        throwsArgumentError,
        reason: 'updateGadgetNotification with empty body must throw ArgumentError');
    });

    test('which does not exist', () {
      expect(
        dataService.notifications.updateGadgetNotification(666, 'itemKey', 'title', 'body', true),
        throwsA(isA<NotFoundError>()),
        reason: 'updateGadgetNotification for a missing key must throw NotFoundError (key=666)');
    });

    test('valid call', () async {
      const String itemKey = 'portable-waypoint';
      const String title = 'Updated title';
      const String body = 'Updated body';
      const String note = 'Updated note';
      final notification = await saveNotification(type, dataService);
      final updated = await dataService.notifications.updateGadgetNotification(
        notification.key,
        itemKey,
        title,
        body,
        !notification.showNotification,
        note: note,
      );
      checkUpdatedNotification(updated, notification, title, body, note, !notification.showNotification, itemKey: itemKey);
      expect(
        updated.completesAt.isAfter(notification.completesAt),
        isTrue,
        reason: 'Updating a gadget notification must push completesAt into the future (key=${notification.key})',
      );
    });
  });

  group('Update furniture notification', () {
    const dbFolder = '${_baseDbFolder}_furniture_notification_tests';
    const type = AppNotificationType.furniture;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid key', () {
      expect(
        dataService.notifications.updateFurnitureNotification(-1, FurnitureCraftingTimeType.twelveHours, 'title', 'body', true),
        throwsArgumentError,
        reason: 'updateFurnitureNotification with negative key must throw ArgumentError');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateFurnitureNotification(1, FurnitureCraftingTimeType.twelveHours, '', 'body', true),
        throwsArgumentError,
        reason: 'updateFurnitureNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateFurnitureNotification(1, FurnitureCraftingTimeType.twelveHours, 'title', '', true),
        throwsArgumentError,
        reason: 'updateFurnitureNotification with empty body must throw ArgumentError');
    });

    test('which does not exist', () {
      expect(
        dataService.notifications.updateFurnitureNotification(666, FurnitureCraftingTimeType.twelveHours, 'title', 'body', true),
        throwsA(isA<NotFoundError>()),
        reason: 'updateFurnitureNotification for a missing key must throw NotFoundError (key=666)');
    });

    test('valid call', () async {
      const String title = 'Updated title';
      const String body = 'Updated body';
      const String note = 'Updated note';
      const craftingTime = FurnitureCraftingTimeType.twelveHours;
      final notification = await saveNotification(type, dataService);
      final updated = await dataService.notifications.updateFurnitureNotification(
        notification.key,
        craftingTime,
        title,
        body,
        !notification.showNotification,
        note: note,
      );
      checkUpdatedNotification(updated, notification, title, body, note, !notification.showNotification);
      expect(
        updated.completesAt.isAfter(notification.completesAt) || updated.completesAt.isBefore(notification.completesAt),
        isTrue,
        reason: 'Updating a furniture notification must recompute completesAt (key=${notification.key})');
      expect(
        updated.furnitureCraftingTimeType,
        craftingTime,
        reason: 'Updated furniture craftingTime must equal the input (key=${notification.key}, expected=$craftingTime)',
      );
    });
  });

  group('Update realm currency notification', () {
    const dbFolder = '${_baseDbFolder}_realm_currency_notification_tests';
    const type = AppNotificationType.realmCurrency;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid key', () {
      expect(
        dataService.notifications.updateRealmCurrencyNotification(-1, RealmRankType.cozy, 1, 1, 'title', 'body', true),
        throwsArgumentError,
        reason: 'updateRealmCurrencyNotification with negative key must throw ArgumentError');
    });

    test('invalid trust rank level', () {
      expect(
        dataService.notifications.updateRealmCurrencyNotification(1, RealmRankType.cozy, 0, 1, 'title', 'body', true),
        throwsArgumentError,
        reason: 'updateRealmCurrencyNotification with trust-rank level 0 must throw ArgumentError');
    });

    test('invalid realm currency', () {
      expect(
        dataService.notifications.updateRealmCurrencyNotification(1, RealmRankType.cozy, 1, -1, 'title', 'body', true),
        throwsArgumentError,
        reason: 'updateRealmCurrencyNotification with negative currency must throw ArgumentError');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateRealmCurrencyNotification(1, RealmRankType.cozy, 1, 1, '', 'body', true),
        throwsArgumentError,
        reason: 'updateRealmCurrencyNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateRealmCurrencyNotification(1, RealmRankType.cozy, 1, 1, 'title', '', true),
        throwsArgumentError,
        reason: 'updateRealmCurrencyNotification with empty body must throw ArgumentError');
    });

    test('which does not exist', () {
      expect(
        dataService.notifications.updateRealmCurrencyNotification(666, RealmRankType.cozy, 1, 1, 'title', 'body', true),
        throwsA(isA<NotFoundError>()),
        reason: 'updateRealmCurrencyNotification for a missing key must throw NotFoundError (key=666)');
    });

    test('valid call', () async {
      const String title = 'Updated title';
      const String body = 'Updated body';
      const String note = 'Updated note';
      const rankType = RealmRankType.fitForAKing;
      final notification = await saveNotification(type, dataService);
      final updated = await dataService.notifications.updateRealmCurrencyNotification(
        notification.key,
        rankType,
        realmTrustRank.keys.last,
        notification.realmCurrency! * 2,
        title,
        body,
        !notification.showNotification,
        note: note,
      );
      checkUpdatedNotification(updated, notification, title, body, note, !notification.showNotification);
      expect(
        updated.completesAt.isAfter(notification.completesAt) || updated.completesAt.isBefore(notification.completesAt),
        isTrue,
        reason: 'Updating a realm-currency notification must recompute completesAt (key=${notification.key})');
      expect(
        updated.realmRankType,
        rankType,
        reason: 'Updated realm rankType must equal the input (key=${notification.key}, expected=$rankType)',
      );
      expect(
        updated.realmTrustRank,
        realmTrustRank.keys.last,
        reason: 'Updated realm trustRank must equal the input (key=${notification.key})',
      );
      expect(
        updated.realmCurrency,
        notification.realmCurrency! * 2,
        reason: 'Updated realm currency must equal doubled input (key=${notification.key}, '
            'expected=${notification.realmCurrency! * 2})',
      );
    });
  });

  group('Update weekly boss notification', () {
    const dbFolder = '${_baseDbFolder}_weekly_boss_notification_tests';
    const type = AppNotificationType.weeklyBoss;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid key', () {
      expect(
        dataService.notifications.updateWeeklyBossNotification(
          -1,
          AppServerResetTimeType.europe,
          'itemKey',
          'title',
          'body',
          true,
        ),
        throwsArgumentError,
        reason: 'updateWeeklyBossNotification with negative key must throw ArgumentError');
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.updateWeeklyBossNotification(-1, AppServerResetTimeType.europe, '', 'title', 'body', true),
        throwsArgumentError,
        reason: 'updateWeeklyBossNotification with empty itemKey must throw ArgumentError');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateWeeklyBossNotification(1, AppServerResetTimeType.europe, 'itemKey', '', 'body', true),
        throwsArgumentError,
        reason: 'updateWeeklyBossNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateWeeklyBossNotification(1, AppServerResetTimeType.europe, 'itemKey', 'title', '', true),
        throwsArgumentError,
        reason: 'updateWeeklyBossNotification with empty body must throw ArgumentError');
    });

    test('which does not exist', () {
      expect(
        dataService.notifications.updateWeeklyBossNotification(
          666,
          AppServerResetTimeType.europe,
          'itemKey',
          'title',
          'body',
          true,
        ),
        throwsA(isA<NotFoundError>()),
        reason: 'updateWeeklyBossNotification for a missing key must throw NotFoundError (key=666)');
    });

    test('valid call', () async {
      const String itemKey = 'azhdaha';
      const String title = 'Updated title';
      const String body = 'Updated body';
      const String note = 'Updated note';
      final notification = await saveNotification(type, dataService);
      final updated = await dataService.notifications.updateWeeklyBossNotification(
        notification.key,
        AppServerResetTimeType.asia,
        itemKey,
        title,
        body,
        !notification.showNotification,
        note: note,
      );
      checkUpdatedNotification(updated, notification, title, body, note, !notification.showNotification, itemKey: itemKey);
      expect(
        updated.completesAt,
        notification.completesAt,
        reason: 'Updating a weekly-boss notification must keep its reset-based completesAt (key=${notification.key})',
      );
    });
  });

  group('Update custom notification', () {
    const dbFolder = '${_baseDbFolder}_custom_notification_tests';
    const type = AppNotificationType.custom;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid key', () {
      expect(
        dataService.notifications.updateCustomNotification(
          -1,
          'itemKey',
          'title',
          'body',
          DateTime.now(),
          true,
          AppNotificationItemType.character,
        ),
        throwsArgumentError,
        reason: 'updateCustomNotification with negative key must throw ArgumentError');
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.updateCustomNotification(
          -1,
          '',
          'title',
          'body',
          DateTime.now(),
          true,
          AppNotificationItemType.character,
        ),
        throwsArgumentError,
        reason: 'updateCustomNotification with empty itemKey must throw ArgumentError');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateCustomNotification(
          1,
          'itemKey',
          '',
          'body',
          DateTime.now(),
          true,
          AppNotificationItemType.character,
        ),
        throwsArgumentError,
        reason: 'updateCustomNotification with empty title must throw ArgumentError');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateCustomNotification(
          1,
          'itemKey',
          'title',
          '',
          DateTime.now(),
          true,
          AppNotificationItemType.character,
        ),
        throwsArgumentError,
        reason: 'updateCustomNotification with empty body must throw ArgumentError');
    });

    test('which does not exist', () {
      expect(
        dataService.notifications.updateCustomNotification(
          666,
          'itemKey',
          'title',
          'body',
          DateTime.now(),
          true,
          AppNotificationItemType.character,
        ),
        throwsA(isA<NotFoundError>()),
        reason: 'updateCustomNotification for a missing key must throw NotFoundError (key=666)');
    });

    test('valid call', () async {
      const String itemKey = 'aquila-favonia';
      const String title = 'Updated title';
      const String body = 'Updated body';
      const String note = 'Updated note';
      final completesAt = DateTime.now().add(const Duration(days: 10));
      const notificationType = AppNotificationItemType.weapon;
      final notification = await saveNotification(type, dataService);
      final updated = await dataService.notifications.updateCustomNotification(
        notification.key,
        itemKey,
        title,
        body,
        completesAt,
        !notification.showNotification,
        notificationType,
        note: note,
      );
      checkUpdatedNotification(updated, notification, title, body, note, !notification.showNotification, itemKey: itemKey);
      expect(
        updated.completesAt,
        completesAt,
        reason: 'Updated custom notification completesAt must equal the user-set date (key=${notification.key})',
      );
      expect(
        updated.notificationItemType,
        notificationType,
        reason: 'Updated custom notificationItemType must equal the input (key=${notification.key}, expected=$notificationType)',
      );
    });
  });

  group('Update daily check in notification', () {
    const dbFolder = '${_baseDbFolder}_daily_check_in_notification_tests';
    const type = AppNotificationType.dailyCheckIn;
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid key', () {
      expect(
        dataService.notifications.updateDailyCheckInNotification(-1, 'title', 'body', true),
        throwsArgumentError,
        reason: 'updateDailyCheckInNotification with negative key must throw ArgumentError',
      );
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateDailyCheckInNotification(1, '', 'body', true),
        throwsArgumentError,
        reason: 'updateDailyCheckInNotification with empty title must throw ArgumentError',
      );
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateDailyCheckInNotification(1, 'title', '', true),
        throwsArgumentError,
        reason: 'updateDailyCheckInNotification with empty body must throw ArgumentError',
      );
    });

    test('which does not exist', () {
      expect(
        dataService.notifications.updateDailyCheckInNotification(666, 'title', 'body', true),
        throwsA(isA<NotFoundError>()),
        reason: 'updateDailyCheckInNotification for a missing key must throw NotFoundError (key=666)',
      );
    });

    test('valid call', () async {
      const String title = 'Updated title';
      const String body = 'Updated body';
      const String note = 'Updated note';
      final notification = await saveNotification(type, dataService);
      final updated = await dataService.notifications.updateDailyCheckInNotification(
        notification.key,
        title,
        body,
        !notification.showNotification,
        note: note,
      );
      checkUpdatedNotification(updated, notification, title, body, note, !notification.showNotification);
      expect(
        updated.completesAt.difference(notification.completesAt).inSeconds <= 1,
        isTrue,
        reason: 'Updating a daily-check-in notification must keep completesAt within 1s of the original '
            '(key=${notification.key})',
      );
    });
  });

  group('Reduce notification hours', () {
    const dbFolder = '${_baseDbFolder}_reduce_notification_hours_notification_tests';
    const notSupportedTypes = [AppNotificationType.realmCurrency, AppNotificationType.resin];
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    for (final type in AppNotificationType.values) {
      test('invalid key for type ${type.name}', () {
        expect(
          dataService.notifications.reduceNotificationHours(-1, type, 1),
          throwsArgumentError,
          reason: 'reduceNotificationHours with negative key must throw ArgumentError (type=${type.name})',
        );
      });

      test('invalid hours for type ${type.name}', () {
        expect(
          dataService.notifications.reduceNotificationHours(1, type, 0),
          throwsArgumentError,
          reason: 'reduceNotificationHours with 0 hours must throw ArgumentError (type=${type.name})',
        );
      });

      if (notSupportedTypes.contains(type)) {
        test('not supported type ${type.name}', () {
          expect(
            dataService.notifications.reduceNotificationHours(1, type, 1),
            throwsArgumentError,
            reason: 'reduceNotificationHours must throw ArgumentError for unsupported type ${type.name}',
          );
        });
      } else {
        test('valid call for type ${type.name}', () async {
          const int hours = 1;
          final notification = await saveNotification(type, dataService);
          final updatedNotification = await dataService.notifications.reduceNotificationHours(notification.key, type, hours);
          expect(
            updatedNotification.completesAt.isBefore(notification.completesAt),
            isTrue,
            reason: 'Reducing hours must move completesAt earlier (key=${notification.key}, type=${type.name})',
          );
          expect(
            updatedNotification.completesAt.difference(notification.completesAt).inHours.abs(),
            hours,
            reason: 'completesAt must move earlier by exactly $hours hour(s) (key=${notification.key}, type=${type.name})',
          );
        });
      }
    }
  });

  group('Get data for backup', () {
    const dbFolder = '${_baseDbFolder}_get_data_for_backup_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('no data exist', () {
      final bk = dataService.notifications.getDataForBackup();
      expect(bk.custom, isEmpty, reason: 'Backup custom list must be empty when no custom notifications are stored');
      expect(bk.expeditions, isEmpty, reason: 'Backup expeditions list must be empty when no expedition notifications are stored');
      expect(
        bk.farmingArtifact,
        isEmpty,
        reason: 'Backup farmingArtifact list must be empty when no such notifications are stored',
      );
      expect(
        bk.farmingMaterial,
        isEmpty,
        reason: 'Backup farmingMaterial list must be empty when no such notifications are stored',
      );
      expect(bk.furniture, isEmpty, reason: 'Backup furniture list must be empty when no furniture notifications are stored');
      expect(bk.gadgets, isEmpty, reason: 'Backup gadgets list must be empty when no gadget notifications are stored');
      expect(
        bk.realmCurrency,
        isEmpty,
        reason: 'Backup realmCurrency list must be empty when no realm-currency notifications are stored',
      );
      expect(bk.resin, isEmpty, reason: 'Backup resin list must be empty when no resin notifications are stored');
      expect(
        bk.weeklyBosses,
        isEmpty,
        reason: 'Backup weeklyBosses list must be empty when no weekly-boss notifications are stored',
      );
    });

    test('data exists', () async {
      final notifications = <NotificationItem>[];
      for (final type in AppNotificationType.values) {
        final notification = await saveNotification(type, dataService);
        notifications.add(notification);
      }

      final bk = dataService.notifications.getDataForBackup();

      checkBackup(bk, notifications);
    });
  });

  group('Restore from backup', () {
    const dbFolder = '${_baseDbFolder}_restore_from_backup_tests';
    const emptyBk = BackupNotificationsModel(
      custom: [],
      expeditions: [],
      farmingArtifact: [],
      farmingMaterial: [],
      furniture: [],
      gadgets: [],
      realmCurrency: [],
      resin: [],
      weeklyBosses: [],
    );
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('no data to restore and no previous data exist', () async {
      await dataService.notifications.restoreFromBackup(emptyBk, AppServerResetTimeType.europe);
      final bk = dataService.notifications.getDataForBackup();
      expect(bk.custom, isEmpty, reason: 'Backup custom list must be empty when no custom notifications are stored');
      expect(bk.expeditions, isEmpty, reason: 'Backup expeditions list must be empty when no expedition notifications are stored');
      expect(
        bk.farmingArtifact,
        isEmpty,
        reason: 'Backup farmingArtifact list must be empty when no such notifications are stored',
      );
      expect(
        bk.farmingMaterial,
        isEmpty,
        reason: 'Backup farmingMaterial list must be empty when no such notifications are stored',
      );
      expect(bk.furniture, isEmpty, reason: 'Backup furniture list must be empty when no furniture notifications are stored');
      expect(bk.gadgets, isEmpty, reason: 'Backup gadgets list must be empty when no gadget notifications are stored');
      expect(
        bk.realmCurrency,
        isEmpty,
        reason: 'Backup realmCurrency list must be empty when no realm-currency notifications are stored',
      );
      expect(bk.resin, isEmpty, reason: 'Backup resin list must be empty when no resin notifications are stored');
      expect(
        bk.weeklyBosses,
        isEmpty,
        reason: 'Backup weeklyBosses list must be empty when no weekly-boss notifications are stored',
      );
    });

    test('no data to restore and previous data exist', () async {
      for (final type in AppNotificationType.values) {
        await saveNotification(type, dataService);
      }

      await dataService.notifications.restoreFromBackup(emptyBk, AppServerResetTimeType.northAmerica);
      final bk = dataService.notifications.getDataForBackup();
      expect(bk.custom, isEmpty, reason: 'Backup custom list must be empty when no custom notifications are stored');
      expect(bk.expeditions, isEmpty, reason: 'Backup expeditions list must be empty when no expedition notifications are stored');
      expect(
        bk.farmingArtifact,
        isEmpty,
        reason: 'Backup farmingArtifact list must be empty when no such notifications are stored',
      );
      expect(
        bk.farmingMaterial,
        isEmpty,
        reason: 'Backup farmingMaterial list must be empty when no such notifications are stored',
      );
      expect(bk.furniture, isEmpty, reason: 'Backup furniture list must be empty when no furniture notifications are stored');
      expect(bk.gadgets, isEmpty, reason: 'Backup gadgets list must be empty when no gadget notifications are stored');
      expect(
        bk.realmCurrency,
        isEmpty,
        reason: 'Backup realmCurrency list must be empty when no realm-currency notifications are stored',
      );
      expect(bk.resin, isEmpty, reason: 'Backup resin list must be empty when no resin notifications are stored');
      expect(
        bk.weeklyBosses,
        isEmpty,
        reason: 'Backup weeklyBosses list must be empty when no weekly-boss notifications are stored',
      );
    });

    T updateBackupItem<T extends BackupNotificationModel>(T item) {
      return item.copyWith(title: 'Updated', body: 'Body', note: 'Note', showNotification: !item.showNotification) as T;
    }

    test('there is data to restore and previous data exist', () async {
      for (final type in AppNotificationType.values) {
        await saveNotification(type, dataService);
      }
      final originalBk = dataService.notifications.getDataForBackup();
      final bk = BackupNotificationsModel(
        custom: originalBk.custom.map((e) => updateBackupItem(e)).toList(),
        expeditions: originalBk.expeditions.map((e) => updateBackupItem(e)).toList(),
        farmingArtifact: originalBk.farmingArtifact.map((e) => updateBackupItem(e)).toList(),
        farmingMaterial: originalBk.farmingMaterial.map((e) => updateBackupItem(e)).toList(),
        furniture: originalBk.furniture.map((e) => updateBackupItem(e)).toList(),
        gadgets: originalBk.gadgets.map((e) => updateBackupItem(e)).toList(),
        realmCurrency: originalBk.realmCurrency.map((e) => updateBackupItem(e)).toList(),
        resin: originalBk.resin.map((e) => updateBackupItem(e)).toList(),
        weeklyBosses: originalBk.weeklyBosses.map((e) => updateBackupItem(e)).toList(),
      );

      await dataService.notifications.restoreFromBackup(bk, AppServerResetTimeType.northAmerica);

      final notifications = dataService.notifications.getAllNotifications();
      checkBackup(bk, notifications);
    });
  });
}
