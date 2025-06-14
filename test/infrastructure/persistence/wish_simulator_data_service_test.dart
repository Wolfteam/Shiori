import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/datetime_extensions.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_asc_materials_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const String _baseDbFolder = 'shiori_wish_simulator_data_service';

void main() {
  late final ResourceService resourceService;
  late final GenshinService genshinService;
  late final CalculatorAscMaterialsService calculatorService;

  const List<ItemType> validItemTypes = [ItemType.character, ItemType.weapon];
  const Map<int, int> defaultXStarCount = {
    5: 0,
    4: 0,
    3: 0,
  };
  const String charKey = 'keqing';
  const String weaponKey = 'aquila-favonia';

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

  group('Get banner pull history', () {
    const dbFolder = '${_baseDbFolder}_get_banner_pull_history_tests';
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

    for (final type in BannerItemType.values) {
      test('history does not exist for type = ${type.name} thus it gets created', () async {
        final history = await dataService.wishSimulator.getBannerPullHistory(type, defaultXStarCount: defaultXStarCount);
        expect(history.type, type.index);
        expect(history.currentXStarCount, defaultXStarCount);
        expect(history.fiftyFiftyXStarGuaranteed.length, defaultXStarCount.length);
        final List<int> rarities = defaultXStarCount.keys.toList();
        for (final kvp in history.fiftyFiftyXStarGuaranteed.entries) {
          expect(kvp.key, isIn(rarities));
          expect(kvp.value, isFalse);
        }
      });
    }
  });

  group('Save banner item pull history', () {
    const dbFolder = '${_baseDbFolder}_save_item_banner_pull_history_tests';
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

    test('item key is not valid', () {
      expect(
        () => dataService.wishSimulator.saveBannerItemPullHistory(BannerItemType.character, '', ItemType.character),
        throwsArgumentError,
      );
    });

    test('item type is not valid', () {
      expect(
        () => dataService.wishSimulator.saveBannerItemPullHistory(BannerItemType.character, 'mora', ItemType.material),
        throwsArgumentError,
      );
    });

    for (final BannerItemType bannerType in BannerItemType.values) {
      for (final ItemType itemType in validItemTypes) {
        test('on banner ${bannerType.name} for item type = ${itemType.name}', () async {
          final now = DateTime.now().subtract(const Duration(seconds: 1)).toUtc();
          final String key = itemType == ItemType.character ? charKey : weaponKey;
          await dataService.wishSimulator.saveBannerItemPullHistory(bannerType, key, itemType);
          final pullHistory = dataService.wishSimulator.getBannerItemsPullHistoryPerType(bannerType);
          expect(pullHistory.length, 1);

          final history = pullHistory.first;
          expect(history.bannerType, bannerType.index);
          expect(history.itemType, itemType.index);
          expect(history.itemKey, key);
          expect(history.pulledOnDate.isAfterInclusive(now), isTrue);
        });
      }
    }
  });

  group('Clear banner item pull history', () {
    const dbFolder = '${_baseDbFolder}_clear_banner_item_pull_history_tests';
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

    for (final type in BannerItemType.values) {
      test('no data exist for type ${type.name}', () async {
        await dataService.wishSimulator.clearBannerItemPullHistory(type);
        final count = dataService.wishSimulator.getBannerItemsPullHistoryPerType(type).length;
        expect(count, isZero);
      });

      test('data exists for type ${type.name}', () async {
        await dataService.wishSimulator.saveBannerItemPullHistory(type, charKey, ItemType.character);
        await dataService.wishSimulator.clearBannerItemPullHistory(type);
        final count = dataService.wishSimulator.getBannerItemsPullHistoryPerType(type).length;
        expect(count, isZero);
      });
    }
  });

  group('Clear all banner item pull history', () {
    const dbFolder = '${_baseDbFolder}_clear_all_banner_item_pull_history_tests';
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

    test('no data exist', () async {
      await dataService.wishSimulator.clearAllBannerItemPullHistory();

      for (final type in BannerItemType.values) {
        final count = dataService.wishSimulator.getBannerItemsPullHistoryPerType(type).length;
        expect(count, isZero);
      }
    });

    test('data exists', () async {
      for (final type in BannerItemType.values) {
        await dataService.wishSimulator.saveBannerItemPullHistory(type, charKey, ItemType.character);
        await dataService.wishSimulator.saveBannerItemPullHistory(type, weaponKey, ItemType.weapon);
      }

      await dataService.wishSimulator.clearAllBannerItemPullHistory();

      for (final type in BannerItemType.values) {
        final count = dataService.wishSimulator.getBannerItemsPullHistoryPerType(type).length;
        expect(count, isZero);
      }
    });
  });

  group('Get banner items pull history per type', () {
    const dbFolder = '${_baseDbFolder}_get_banner_items_pull_history_per_type_tests';
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

    for (final type in BannerItemType.values) {
      test('no data exist for type ${type.name}', () {
        final count = dataService.wishSimulator.getBannerItemsPullHistoryPerType(type).length;
        expect(count, isZero);
      });

      test('data exists for type ${type.name}', () async {
        final now = DateTime.now().subtract(const Duration(seconds: 1)).toUtc();
        await dataService.wishSimulator.saveBannerItemPullHistory(type, charKey, ItemType.character);
        await dataService.wishSimulator.saveBannerItemPullHistory(type, charKey, ItemType.character);

        final pullHistory = dataService.wishSimulator.getBannerItemsPullHistoryPerType(type);
        expect(pullHistory.length, 2);

        for (int i = 0; i < pullHistory.length; i++) {
          final history = pullHistory[i];
          expect(history.itemKey, charKey);
          expect(history.bannerType, type.index);
          expect(history.itemType, ItemType.character.index);
          expect(history.pulledOnDate.isAfterInclusive(now), isTrue);
        }
      });
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

    test('no data exist', () async {
      final bk = await dataService.wishSimulator.getDataForBackup();
      expect(bk.pullHistory.length, BannerItemType.values.length);
      expect(bk.pullHistory.every((el) => el.currentXStarCount.isEmpty && el.fiftyFiftyXStarGuaranteed.isEmpty), isTrue);
      expect(bk.itemPullHistory.isEmpty, isTrue);
    });

    test('data exists', () async {
      final now = DateTime.now().subtract(const Duration(seconds: 1)).toUtc();
      for (final type in BannerItemType.values) {
        final history = await dataService.wishSimulator.getBannerPullHistory(type, defaultXStarCount: defaultXStarCount);

        await history.pull(5, false);
        await dataService.wishSimulator.saveBannerItemPullHistory(type, charKey, ItemType.character);

        await history.pull(5, true);
        await dataService.wishSimulator.saveBannerItemPullHistory(type, weaponKey, ItemType.weapon);
      }
      final bk = await dataService.wishSimulator.getDataForBackup();
      expect(bk.pullHistory.length, BannerItemType.values.length);
      for (int i = 0; i < bk.pullHistory.length; i++) {
        final got = bk.pullHistory[i];
        final expectedType = BannerItemType.values[i];
        expect(got.type, expectedType);
      }

      expect(bk.itemPullHistory.length, BannerItemType.values.length * 2);
      for (final history in bk.itemPullHistory) {
        expect(history.itemType, isIn(validItemTypes));
        expect(history.itemKey, isIn([charKey, weaponKey]));
        expect(history.bannerType, isIn(BannerItemType.values));
        expect(history.pulledOn.isAfterInclusive(now), isTrue);
      }
    });
  });

  group('Restore from backup', () {
    const dbFolder = '${_baseDbFolder}_restore_from_backup_tests';
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
      await dataService.wishSimulator.restoreFromBackup(const BackupWishSimulatorModel(pullHistory: [], itemPullHistory: []));
      final bk = await dataService.wishSimulator.getDataForBackup();
      expect(bk.pullHistory.length, BannerItemType.values.length);
      expect(bk.pullHistory.every((el) => el.currentXStarCount.isEmpty && el.fiftyFiftyXStarGuaranteed.isEmpty), isTrue);
      expect(bk.itemPullHistory, isEmpty);
    });

    test('no data to restore and previous data exist', () async {
      for (final type in BannerItemType.values) {
        final history = await dataService.wishSimulator.getBannerPullHistory(type, defaultXStarCount: defaultXStarCount);

        await history.pull(5, false);
        await dataService.wishSimulator.saveBannerItemPullHistory(type, charKey, ItemType.character);

        await history.pull(5, true);
        await dataService.wishSimulator.saveBannerItemPullHistory(type, weaponKey, ItemType.weapon);
      }

      await dataService.wishSimulator.restoreFromBackup(const BackupWishSimulatorModel(pullHistory: [], itemPullHistory: []));
      final bk = await dataService.wishSimulator.getDataForBackup();
      expect(bk.pullHistory.length, BannerItemType.values.length);
      expect(bk.pullHistory.every((el) => el.currentXStarCount.isEmpty && el.fiftyFiftyXStarGuaranteed.isEmpty), isTrue);
      expect(bk.itemPullHistory, isEmpty);
    });

    test('there is data to restore and previous data exist', () async {
      for (final type in BannerItemType.values) {
        final history = await dataService.wishSimulator.getBannerPullHistory(type, defaultXStarCount: defaultXStarCount);

        await history.pull(5, null);
        await history.pull(5, false);
        await history.pull(5, true);
        await dataService.wishSimulator.saveBannerItemPullHistory(type, charKey, ItemType.character);
        await dataService.wishSimulator.saveBannerItemPullHistory(type, charKey, ItemType.character);
        await dataService.wishSimulator.saveBannerItemPullHistory(type, charKey, ItemType.character);

        await history.pull(5, null);
        await history.pull(5, false);
        await history.pull(5, true);
        await dataService.wishSimulator.saveBannerItemPullHistory(type, weaponKey, ItemType.weapon);
        await dataService.wishSimulator.saveBannerItemPullHistory(type, charKey, ItemType.character);
        await dataService.wishSimulator.saveBannerItemPullHistory(type, charKey, ItemType.character);
      }

      final pulledOnMin = DateTime.now().subtract(const Duration(days: 3));
      final pulledOnMax = DateTime.now().subtract(const Duration(days: 3));
      final bk = BackupWishSimulatorModel(
        pullHistory: BannerItemType.values
            .map((e) => BackupWishSimulatorBannerPullHistory(type: e, currentXStarCount: {}, fiftyFiftyXStarGuaranteed: {}))
            .toList(),
        itemPullHistory: BannerItemType.values
            .mapIndex(
              (e, i) => BackupWishSimulatorBannerItemPullHistory(
                bannerType: e,
                itemKey: 'item-$i',
                itemType: i.isOdd ? ItemType.character : ItemType.weapon,
                pulledOn: i.isOdd ? pulledOnMin : pulledOnMax,
              ),
            )
            .toList(),
      );
      await dataService.wishSimulator.restoreFromBackup(bk);

      for (final type in BannerItemType.values) {
        final history = await dataService.wishSimulator.getBannerPullHistory(type);
        expect(history.type, type.index);
        expect(history.currentXStarCount, isEmpty);
        expect(history.fiftyFiftyXStarGuaranteed, isEmpty);

        final itemPullHistory = dataService.wishSimulator.getBannerItemsPullHistoryPerType(type);
        expect(itemPullHistory.length, 1);

        final item = itemPullHistory.first;
        expect(item.bannerType, type.index);
        expect(item.itemKey, startsWith('item-'));
        expect(item.itemType, isIn(validItemTypes.map((e) => e.index)));
        expect(item.pulledOnDate, isIn([pulledOnMin, pulledOnMax]));
      }
    });
  });
}
