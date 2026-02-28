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
    expect(got.key, expected.key, reason: 'Should match expected value (property=key)');
    expect(got.itemKey, itemKey ?? expected.itemKey, reason: 'Should match expected value (property=itemKey)');
    expect(got.title, title ?? expected.title, reason: 'Should match expected value (property=title)');
    expect(got.body, body ?? expected.body, reason: 'Should match expected value (property=body)');
    expect(got.createdAt, expected.createdAt, reason: 'Should match expected value (property=createdAt)');
    expect(got.scheduledDate, expected.scheduledDate, reason: 'Should match expected value (property=scheduledDate)');
    if (checkCompletesAt) {
      expect(got.completesAt, expected.completesAt, reason: 'Should match expected value (property=completesAt)');
    }
    expect(got.type, expected.type, reason: 'Should match expected value (property=type)');
    expect(got.note, note ?? expected.note, reason: 'Should match expected value (property=note)');
    expect(got.showNotification, showNotification ?? expected.showNotification, reason: 'Should match expected value (property=showNotification)');
    if (!checkSpecifics) {
      return;
    }

    expect(
      got.currentResinValue,
      got.type != AppNotificationType.resin ? 0 : expected.currentResinValue, reason: 'Should match expected value (property=currentResinValue)');

    expect(
      got.expeditionTimeType,
      got.type != AppNotificationType.expedition ? null : expected.expeditionTimeType, reason: 'Should match expected value (property=expeditionTimeType)');
    expect(
      got.withTimeReduction,
      got.type != AppNotificationType.expedition ? false : expected.withTimeReduction, reason: 'Should match expected value (property=withTimeReduction)');

    expect(
      got.notificationItemType,
      got.type != AppNotificationType.custom && got.type != AppNotificationType.dailyCheckIn
          ? null
          : expected.notificationItemType, reason: 'Should match expected value (property=notificationItemType)');

    expect(
      got.artifactFarmingTimeType,
      got.type != AppNotificationType.farmingArtifacts ? null : expected.artifactFarmingTimeType, reason: 'Should match expected value (property=artifactFarmingTimeType)');

    expect(
      got.furnitureCraftingTimeType,
      got.type != AppNotificationType.furniture ? null : expected.furnitureCraftingTimeType, reason: 'Should match expected value (property=furnitureCraftingTimeType)');

    expect(
      got.realmTrustRank,
      got.type != AppNotificationType.realmCurrency ? null : expected.realmTrustRank, reason: 'Should match expected value (property=realmTrustRank)');
    expect(
      got.realmRankType,
      got.type != AppNotificationType.realmCurrency ? null : expected.realmRankType, reason: 'Should match expected value (property=realmRankType)');
    expect(
      got.realmCurrency,
      got.type != AppNotificationType.realmCurrency ? null : expected.realmCurrency, reason: 'Should match expected value (property=realmCurrency)');
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
    expect(got.type, expected.type.index, reason: 'Should match expected value (property=type)');
    expect(got.itemKey, expected.itemKey, reason: 'Should match expected value (property=itemKey)');
    expect(got.completesAt.difference(expected.completesAt).inSeconds <= 1, isTrue, reason: 'Should be true (property=inSeconds <= 1, isTrue)');
    expect(got.showNotification, expected.showNotification, reason: 'Should match expected value (property=showNotification)');
    expect(got.note, expected.note, reason: 'Should match expected value (property=note)');
    expect(got.title, expected.title, reason: 'Should match expected value (property=title)');
    expect(got.body, expected.body, reason: 'Should match expected value (property=body)');
  }

  void checkBackup(BackupNotificationsModel bk, List<NotificationItem> notifications) {
    expect(bk.custom.length, 2, reason: 'Should match expected value (property=custom, expected=2)');
    for (final custom in bk.custom) {
      final expectedCustom = notifications.firstWhere((el) => el.type.index == custom.type);
      checkBackupCommon(custom, expectedCustom);
      expect(custom.notificationItemType, expectedCustom.notificationItemType!.index, reason: 'Should match expected value (property=notificationItemType)');
    }

    expect(bk.expeditions.length, 1, reason: 'Should match expected value (property=expeditions, expected=1)');
    final gotExpedition = bk.expeditions.first;
    final expectedExpedition = notifications.firstWhere((el) => el.type.index == gotExpedition.type);
    checkBackupCommon(gotExpedition, expectedExpedition);
    expect(gotExpedition.expeditionTimeType, expectedExpedition.expeditionTimeType!.index, reason: 'Should match expected value (property=expeditionTimeType)');
    expect(gotExpedition.withTimeReduction, expectedExpedition.withTimeReduction, reason: 'Should match expected value (property=withTimeReduction)');

    expect(bk.farmingArtifact.length, 1, reason: 'Should match expected value (property=farmingArtifact, expected=1)');
    final gotFarmingArtifact = bk.farmingArtifact.first;
    final expectedFarmingArtifact = notifications.firstWhere((el) => el.type.index == gotFarmingArtifact.type);
    checkBackupCommon(gotFarmingArtifact, expectedFarmingArtifact);
    expect(gotFarmingArtifact.artifactFarmingTimeType, expectedFarmingArtifact.artifactFarmingTimeType!.index, reason: 'Should match expected value (property=artifactFarmingTimeType)');

    expect(bk.farmingMaterial.length, 1, reason: 'Should match expected value (property=farmingMaterial, expected=1)');
    final gotFarmingMaterial = bk.farmingMaterial.first;
    final expectedFarmingMaterial = notifications.firstWhere((el) => el.type.index == gotFarmingMaterial.type);
    checkBackupCommon(gotFarmingMaterial, expectedFarmingMaterial);

    expect(bk.furniture.length, 1, reason: 'Should match expected value (property=furniture, expected=1)');
    final gotFurniture = bk.furniture.first;
    final expectedFurniture = notifications.firstWhere((el) => el.type.index == gotFurniture.type);
    checkBackupCommon(gotFurniture, expectedFurniture);
    expect(gotFurniture.furnitureCraftingTimeType, expectedFurniture.furnitureCraftingTimeType!.index, reason: 'Should match expected value (property=furnitureCraftingTimeType)');

    expect(bk.gadgets.length, 1, reason: 'Should match expected value (property=gadgets, expected=1)');
    final gotGadget = bk.gadgets.first;
    final expectedGadget = notifications.firstWhere((el) => el.type.index == gotGadget.type);
    checkBackupCommon(gotGadget, expectedGadget);

    expect(bk.realmCurrency.length, 1, reason: 'Should match expected value (property=realmCurrency, expected=1)');
    final gotRealmCurrency = bk.realmCurrency.first;
    final expectedRealmCurrency = notifications.firstWhere((el) => el.type.index == gotRealmCurrency.type);
    checkBackupCommon(gotRealmCurrency, expectedRealmCurrency);
    expect(gotRealmCurrency.realmTrustRank, expectedRealmCurrency.realmTrustRank, reason: 'Should match expected value (property=realmTrustRank)');
    expect(gotRealmCurrency.realmRankType, expectedRealmCurrency.realmRankType!.index, reason: 'Should match expected value (property=realmRankType)');
    expect(gotRealmCurrency.realmCurrency, expectedRealmCurrency.realmCurrency, reason: 'Should match expected value (property=realmCurrency)');

    expect(bk.resin.length, 1, reason: 'Should match expected value (property=resin, expected=1)');
    final gotResin = bk.resin.first;
    final expectedResin = notifications.firstWhere((el) => el.type.index == gotResin.type);
    checkBackupCommon(gotResin, expectedResin);
    expect(gotResin.currentResinValue, expectedResin.currentResinValue, reason: 'Should match expected value (property=currentResinValue)');

    expect(bk.weeklyBosses.length, 1, reason: 'Should match expected value (property=weeklyBosses, expected=1)');
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
      expect(notifications.isEmpty, isTrue, reason: 'Should be true');
    });

    test('data exists', () async {
      final expected = await dataService.notifications.saveDailyCheckInNotification('primogem', 'Resin', '4u');
      final notifications = dataService.notifications.getAllNotifications();
      expect(notifications.length, 1, reason: 'Should match expected value (expected=1)');
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
        expect(() => dataService.notifications.getNotification(-1, type), throwsArgumentError, reason: 'Should throw expected exception');
      });

      test('for type = ${type.name} which does not exist', () {
        expect(() => dataService.notifications.getNotification(666, type), throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
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
      expect(dataService.notifications.saveResinNotification('', 'title', 'body', 0, note: 'Note'), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.saveResinNotification(getValidItemKey(type), '', 'body', 0, note: 'Note'),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.saveResinNotification(getValidItemKey(type), 'title', '', 0, note: 'Note'),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid resin value', () {
      expect(
        dataService.notifications.saveResinNotification(getValidItemKey(type), 'title', 'body', -1, note: 'Note'),
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
      expect(dataService.notifications.saveGadgetNotification('', 'title', 'body', note: 'Note'), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.saveGadgetNotification(getValidItemKey(type), '', 'body', note: 'Note'),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.saveGadgetNotification(getValidItemKey(type), 'title', '', note: 'Note'),
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
      expect(dataService.notifications.saveFarmingMaterialNotification('', 'title', 'body', note: 'Note'), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.saveFarmingMaterialNotification(getValidItemKey(type), '', 'body', note: 'Note'),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.saveFarmingMaterialNotification(getValidItemKey(type), 'title', '', note: 'Note'),
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
      expect(dataService.notifications.saveDailyCheckInNotification('', 'title', 'body', note: 'Note'), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.saveDailyCheckInNotification(getValidItemKey(type), '', 'body', note: 'Note'),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.saveDailyCheckInNotification(getValidItemKey(type), 'title', '', note: 'Note'),
        throwsArgumentError, reason: 'Should throw expected exception');
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
        expect(dataService.notifications.deleteNotification(-1, type), throwsArgumentError, reason: 'Should throw expected exception');
      });

      test('of type = ${type.name} which does not exist', () {
        expect(dataService.notifications.deleteNotification(666, type), completes, reason: 'Should match expected value (property=deleteNotification(666, type))');
      });

      test('of type = ${type.name} which exists', () async {
        final notification = await saveNotification(type, dataService);
        await dataService.notifications.deleteNotification(notification.key, type);
        expect(() => dataService.notifications.getNotification(notification.key, type), throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
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
        expect(dataService.notifications.resetNotification(-1, type, AppServerResetTimeType.asia), throwsArgumentError, reason: 'Should throw expected exception');
      });

      test('of type = ${type.name} which does not exist', () {
        expect(
          dataService.notifications.resetNotification(666, type, AppServerResetTimeType.europe),
          throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
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
            expect(updatedNotification.completesAt, notification.completesAt, reason: 'Should match expected value (property=completesAt)');
          case AppNotificationType.weeklyBoss:
            final Duration diff = notification.completesAt.difference(updatedNotification.completesAt);
            expect(diff.inSeconds <= 1, isTrue, reason: 'Should be true (property=inSeconds <= 1, isTrue)');
          default:
            expect(updatedNotification.completesAt.isAfter(notification.completesAt), isTrue, reason: 'Should be true (property=completesAt))');
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
        expect(dataService.notifications.stopNotification(-1, type), throwsArgumentError, reason: 'Should throw expected exception');
      });

      test('for type ${type.name} which does not exist', () {
        expect(dataService.notifications.stopNotification(666, type), throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
      });

      test('for type ${type.name} which exists', () async {
        final notification = await saveNotification(type, dataService);
        final updatedNotification = await dataService.notifications.stopNotification(notification.key, type);
        expect(updatedNotification.completesAt.isBeforeInclusive(DateTime.now()), isTrue, reason: 'Should be true (property=now()))');
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
      expect(dataService.notifications.updateResinNotification(-1, 'title', 'body', 0, true, note: 'Note'), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateResinNotification(1, '', 'body', 0, true, note: 'Note'),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateResinNotification(1, 'title', '', 0, true, note: 'Note'),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid resin value', () {
      expect(
        dataService.notifications.updateResinNotification(1, 'title', 'body', -1, true, note: 'Note'),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('which does not exist', () {
      expect(
        dataService.notifications.updateResinNotification(666, 'title', 'body', 0, true),
        throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
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
      expect(updated.completesAt.isAfter(notification.completesAt), isTrue, reason: 'Should be true (property=completesAt))');
      expect(updated.currentResinValue, notification.currentResinValue ~/ 2, reason: 'Should match expected value (property=currentResinValue)');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
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
        isTrue, reason: 'Should be true (property=completesAt))');
      expect(updated.withTimeReduction, !notification.withTimeReduction, reason: 'Should match expected value (property=withTimeReduction)');
      expect(updated.expeditionTimeType, expeditionTime, reason: 'Should match expected value (property=expeditionTimeType)');
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
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.updateFarmingMaterialNotification(1, '', 'title', 'body', true),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateFarmingMaterialNotification(1, validItemKey, '', 'body', true),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateFarmingMaterialNotification(1, validItemKey, 'title', '', true),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('which does not exist', () {
      expect(
        dataService.notifications.updateFarmingMaterialNotification(666, validItemKey, 'title', 'body', true),
        throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
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
      expect(updated.completesAt.isAfter(notification.completesAt), isTrue, reason: 'Should be true (property=completesAt))');
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
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateFarmingArtifactNotification(1, ArtifactFarmingTimeType.twelveHours, '', 'body', true),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateFarmingArtifactNotification(1, ArtifactFarmingTimeType.twelveHours, 'title', '', true),
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
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
        isTrue, reason: 'Should be true (property=completesAt))');
      expect(updated.artifactFarmingTimeType, farmingTime, reason: 'Should match expected value (property=artifactFarmingTimeType)');
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
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.updateGadgetNotification(1, '', 'title', 'body', true),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateGadgetNotification(1, 'itemKey', '', 'body', true),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateGadgetNotification(1, 'itemKey', 'title', '', true),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('which does not exist', () {
      expect(
        dataService.notifications.updateGadgetNotification(666, 'itemKey', 'title', 'body', true),
        throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
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
      expect(updated.completesAt.isAfter(notification.completesAt), isTrue, reason: 'Should be true (property=completesAt))');
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
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateFurnitureNotification(1, FurnitureCraftingTimeType.twelveHours, '', 'body', true),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateFurnitureNotification(1, FurnitureCraftingTimeType.twelveHours, 'title', '', true),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('which does not exist', () {
      expect(
        dataService.notifications.updateFurnitureNotification(666, FurnitureCraftingTimeType.twelveHours, 'title', 'body', true),
        throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
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
        isTrue, reason: 'Should be true (property=completesAt))');
      expect(updated.furnitureCraftingTimeType, craftingTime, reason: 'Should match expected value (property=furnitureCraftingTimeType)');
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
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid trust rank level', () {
      expect(
        dataService.notifications.updateRealmCurrencyNotification(1, RealmRankType.cozy, 0, 1, 'title', 'body', true),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid realm currency', () {
      expect(
        dataService.notifications.updateRealmCurrencyNotification(1, RealmRankType.cozy, 1, -1, 'title', 'body', true),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateRealmCurrencyNotification(1, RealmRankType.cozy, 1, 1, '', 'body', true),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateRealmCurrencyNotification(1, RealmRankType.cozy, 1, 1, 'title', '', true),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('which does not exist', () {
      expect(
        dataService.notifications.updateRealmCurrencyNotification(666, RealmRankType.cozy, 1, 1, 'title', 'body', true),
        throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
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
        isTrue, reason: 'Should be true (property=completesAt))');
      expect(updated.realmRankType, rankType, reason: 'Should match expected value (property=realmRankType)');
      expect(updated.realmTrustRank, realmTrustRank.keys.last, reason: 'Should match expected value (property=realmTrustRank)');
      expect(updated.realmCurrency, notification.realmCurrency! * 2, reason: 'Should match expected value (property=realmCurrency)');
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
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid item key', () {
      expect(
        dataService.notifications.updateWeeklyBossNotification(-1, AppServerResetTimeType.europe, '', 'title', 'body', true),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid title', () {
      expect(
        dataService.notifications.updateWeeklyBossNotification(1, AppServerResetTimeType.europe, 'itemKey', '', 'body', true),
        throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid body', () {
      expect(
        dataService.notifications.updateWeeklyBossNotification(1, AppServerResetTimeType.europe, 'itemKey', 'title', '', true),
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
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
      expect(updated.completesAt, notification.completesAt, reason: 'Should match expected value (property=completesAt)');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsArgumentError, reason: 'Should throw expected exception');
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
        throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
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
      expect(updated.completesAt, completesAt, reason: 'Should match expected value (property=completesAt)');
      expect(updated.notificationItemType, notificationType, reason: 'Should match expected value (property=notificationItemType)');
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
      expect(dataService.notifications.updateDailyCheckInNotification(-1, 'title', 'body', true), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid title', () {
      expect(dataService.notifications.updateDailyCheckInNotification(1, '', 'body', true), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('invalid body', () {
      expect(dataService.notifications.updateDailyCheckInNotification(1, 'title', '', true), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('which does not exist', () {
      expect(dataService.notifications.updateDailyCheckInNotification(666, 'title', 'body', true), throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
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
      expect(updated.completesAt.difference(notification.completesAt).inSeconds <= 1, isTrue, reason: 'Should be true (property=inSeconds <= 1, isTrue)');
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
        expect(dataService.notifications.reduceNotificationHours(-1, type, 1), throwsArgumentError, reason: 'Should throw expected exception');
      });

      test('invalid hours for type ${type.name}', () {
        expect(dataService.notifications.reduceNotificationHours(1, type, 0), throwsArgumentError, reason: 'Should throw expected exception');
      });

      if (notSupportedTypes.contains(type)) {
        test('not supported type ${type.name}', () {
          expect(dataService.notifications.reduceNotificationHours(1, type, 1), throwsArgumentError, reason: 'Should throw expected exception');
        });
      } else {
        test('valid call for type ${type.name}', () async {
          const int hours = 1;
          final notification = await saveNotification(type, dataService);
          final updatedNotification = await dataService.notifications.reduceNotificationHours(notification.key, type, hours);
          expect(updatedNotification.completesAt.isBefore(notification.completesAt), isTrue, reason: 'Should be true (property=completesAt))');
          expect(updatedNotification.completesAt.difference(notification.completesAt).inHours.abs(), hours, reason: 'Should match expected value (property=abs())');
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
      expect(bk.custom, isEmpty, reason: 'Should be empty (property=custom)');
      expect(bk.expeditions, isEmpty, reason: 'Should be empty (property=expeditions)');
      expect(bk.farmingArtifact, isEmpty, reason: 'Should be empty (property=farmingArtifact)');
      expect(bk.farmingMaterial, isEmpty, reason: 'Should be empty (property=farmingMaterial)');
      expect(bk.furniture, isEmpty, reason: 'Should be empty (property=furniture)');
      expect(bk.gadgets, isEmpty, reason: 'Should be empty (property=gadgets)');
      expect(bk.realmCurrency, isEmpty, reason: 'Should be empty (property=realmCurrency)');
      expect(bk.resin, isEmpty, reason: 'Should be empty (property=resin)');
      expect(bk.weeklyBosses, isEmpty, reason: 'Should be empty (property=weeklyBosses)');
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
      expect(bk.custom, isEmpty, reason: 'Should be empty (property=custom)');
      expect(bk.expeditions, isEmpty, reason: 'Should be empty (property=expeditions)');
      expect(bk.farmingArtifact, isEmpty, reason: 'Should be empty (property=farmingArtifact)');
      expect(bk.farmingMaterial, isEmpty, reason: 'Should be empty (property=farmingMaterial)');
      expect(bk.furniture, isEmpty, reason: 'Should be empty (property=furniture)');
      expect(bk.gadgets, isEmpty, reason: 'Should be empty (property=gadgets)');
      expect(bk.realmCurrency, isEmpty, reason: 'Should be empty (property=realmCurrency)');
      expect(bk.resin, isEmpty, reason: 'Should be empty (property=resin)');
      expect(bk.weeklyBosses, isEmpty, reason: 'Should be empty (property=weeklyBosses)');
    });

    test('no data to restore and previous data exist', () async {
      for (final type in AppNotificationType.values) {
        await saveNotification(type, dataService);
      }

      await dataService.notifications.restoreFromBackup(emptyBk, AppServerResetTimeType.northAmerica);
      final bk = dataService.notifications.getDataForBackup();
      expect(bk.custom, isEmpty, reason: 'Should be empty (property=custom)');
      expect(bk.expeditions, isEmpty, reason: 'Should be empty (property=expeditions)');
      expect(bk.farmingArtifact, isEmpty, reason: 'Should be empty (property=farmingArtifact)');
      expect(bk.farmingMaterial, isEmpty, reason: 'Should be empty (property=farmingMaterial)');
      expect(bk.furniture, isEmpty, reason: 'Should be empty (property=furniture)');
      expect(bk.gadgets, isEmpty, reason: 'Should be empty (property=gadgets)');
      expect(bk.realmCurrency, isEmpty, reason: 'Should be empty (property=realmCurrency)');
      expect(bk.resin, isEmpty, reason: 'Should be empty (property=resin)');
      expect(bk.weeklyBosses, isEmpty, reason: 'Should be empty (property=weeklyBosses)');
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
