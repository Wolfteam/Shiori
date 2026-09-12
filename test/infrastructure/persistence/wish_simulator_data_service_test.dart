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
        expect(history.type, type.index,
            reason: 'Auto-created banner history must keep its type (expected=${type.index}, name=${type.name})');
        expect(history.currentXStarCount, defaultXStarCount,
            reason: 'New banner history should seed currentXStarCount from defaultXStarCount (type=${type.name})');
        expect(history.fiftyFiftyXStarGuaranteed.length, defaultXStarCount.length,
            reason: 'fiftyFiftyXStarGuaranteed should have one entry per rarity (type=${type.name})');
        final List<int> rarities = defaultXStarCount.keys.toList();
        for (final kvp in history.fiftyFiftyXStarGuaranteed.entries) {
          expect(kvp.key, isIn(rarities),
              reason: 'fiftyFiftyXStarGuaranteed rarity ${kvp.key} is not one of the seeded rarities $rarities');
          expect(kvp.value, isFalse,
              reason: 'New banner 50/50 must start not guaranteed for rarity ${kvp.key} (type=${type.name})');
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
        throwsArgumentError, reason: 'Saving a pull with an empty itemKey must throw ArgumentError');
    });

    test('item type is not valid', () {
      expect(
        () => dataService.wishSimulator.saveBannerItemPullHistory(BannerItemType.character, 'mora', ItemType.material),
        throwsArgumentError,
        reason: 'Saving a pull with unsupported itemType material must throw ArgumentError (only character/weapon)');
    });

    for (final BannerItemType bannerType in BannerItemType.values) {
      for (final ItemType itemType in validItemTypes) {
        test('on banner ${bannerType.name} for item type = ${itemType.name}', () async {
          final now = DateTime.now().subtract(const Duration(seconds: 1)).toUtc();
          final String key = itemType == ItemType.character ? charKey : weaponKey;
          await dataService.wishSimulator.saveBannerItemPullHistory(bannerType, key, itemType);
          final pullHistory = dataService.wishSimulator.getBannerItemsPullHistoryPerType(bannerType);
          expect(pullHistory.length, 1,
              reason: 'Exactly one pull should be persisted after a single save (banner=${bannerType.name})');

          final history = pullHistory.first;
          expect(history.bannerType, bannerType.index,
              reason: 'Persisted pull must keep banner type (expected=${bannerType.index}, name=${bannerType.name})');
          expect(history.itemType, itemType.index,
              reason: 'Persisted pull must record its item type (expected=${itemType.index}, name=${itemType.name})');
          expect(history.itemKey, key, reason: 'Persisted pull must record the pulled item key (expected=$key)');
          expect(history.pulledOnDate.isAfterInclusive(now), isTrue,
              reason: 'pulledOnDate ${history.pulledOnDate} should be at/after the save time $now');
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
        expect(count, isZero, reason: 'Clearing an already-empty banner should leave zero pulls (type=${type.name})');
      });

      test('data exists for type ${type.name}', () async {
        await dataService.wishSimulator.saveBannerItemPullHistory(type, charKey, ItemType.character);
        await dataService.wishSimulator.clearBannerItemPullHistory(type);
        final count = dataService.wishSimulator.getBannerItemsPullHistoryPerType(type).length;
        expect(count, isZero,
            reason: 'clearBannerItemPullHistory should remove all pulls for the banner (type=${type.name})');
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
        expect(count, isZero,
            reason: 'clearAll on empty store should leave zero pulls for every banner (type=${type.name})');
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
        expect(count, isZero,
            reason: 'clearAll should remove pulls across all banners, none left for type=${type.name}');
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
        expect(count, isZero,
            reason: 'Querying pulls for a banner with no saves should return empty (type=${type.name})');
      });

      test('data exists for type ${type.name}', () async {
        final now = DateTime.now().subtract(const Duration(seconds: 1)).toUtc();
        await dataService.wishSimulator.saveBannerItemPullHistory(type, charKey, ItemType.character);
        await dataService.wishSimulator.saveBannerItemPullHistory(type, charKey, ItemType.character);

        final pullHistory = dataService.wishSimulator.getBannerItemsPullHistoryPerType(type);
        expect(pullHistory.length, 2, reason: 'Two saves should yield two persisted pulls (type=${type.name})');

        for (int i = 0; i < pullHistory.length; i++) {
          final history = pullHistory[i];
          expect(history.itemKey, charKey,
              reason: 'Pull #$i must retain saved itemKey (expected=$charKey, type=${type.name})');
          expect(history.bannerType, type.index,
              reason: 'Pull #$i must retain its banner type (expected=${type.index}, name=${type.name})');
          expect(history.itemType, ItemType.character.index,
              reason: 'Pull #$i must retain character itemType (expected=${ItemType.character.index})');
          expect(history.pulledOnDate.isAfterInclusive(now), isTrue,
              reason: 'Pull #$i pulledOnDate ${history.pulledOnDate} should be at/after save time $now');
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
      expect(bk.pullHistory.length, BannerItemType.values.length,
          reason: 'Backup should contain one pullHistory entry per banner type even when empty');
      expect(bk.pullHistory.every((el) => el.currentXStarCount.isEmpty && el.fiftyFiftyXStarGuaranteed.isEmpty), isTrue,
          reason: 'With no pulls, every backup banner should have empty star counts and guarantees');
      expect(bk.itemPullHistory.isEmpty, isTrue,
          reason: 'Backup itemPullHistory should be empty when no items were pulled');
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
      expect(bk.pullHistory.length, BannerItemType.values.length,
          reason: 'Backup should contain one pullHistory entry per banner type');
      for (int i = 0; i < bk.pullHistory.length; i++) {
        final got = bk.pullHistory[i];
        final expectedType = BannerItemType.values[i];
        expect(got.type, expectedType,
            reason: 'Backup pullHistory[$i] banner type mismatch (expected=${expectedType.name})');
      }

      expect(bk.itemPullHistory.length, BannerItemType.values.length * 2,
          reason: 'Backup should hold two item pulls (char+weapon) per banner type');
      for (final history in bk.itemPullHistory) {
        expect(history.itemType, isIn(validItemTypes),
            reason: 'Backed-up item pull has unexpected itemType ${history.itemType}, not in $validItemTypes');
        expect(history.itemKey, isIn([charKey, weaponKey]),
            reason: 'Backed-up item pull has unexpected itemKey ${history.itemKey}');
        expect(history.bannerType, isIn(BannerItemType.values),
            reason: 'Backed-up item pull has unexpected bannerType ${history.bannerType}');
        expect(history.pulledOn.isAfterInclusive(now), isTrue,
            reason: 'Backed-up item pull pulledOn ${history.pulledOn} should be at/after $now');
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
      expect(bk.pullHistory.length, BannerItemType.values.length,
          reason: 'After restoring an empty backup, one default pullHistory entry per banner type should exist');
      expect(bk.pullHistory.every((el) => el.currentXStarCount.isEmpty && el.fiftyFiftyXStarGuaranteed.isEmpty), isTrue,
          reason: 'Restoring an empty backup should leave every banner with empty star counts and guarantees');
      expect(bk.itemPullHistory, isEmpty, reason: 'Restoring an empty backup should leave no item pull history');
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
      expect(bk.pullHistory.length, BannerItemType.values.length,
          reason: 'Restoring an empty backup must wipe prior data yet keep one default entry per banner type');
      expect(bk.pullHistory.every((el) => el.currentXStarCount.isEmpty && el.fiftyFiftyXStarGuaranteed.isEmpty), isTrue,
          reason: 'Restoring an empty backup should reset all previously-pulled star counts and guarantees to empty');
      expect(bk.itemPullHistory, isEmpty,
          reason: 'Restoring an empty backup should clear previously-saved item pull history');
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
        expect(history.type, type.index,
            reason: 'Restored banner history must keep its type (expected=${type.index}, name=${type.name})');
        expect(history.currentXStarCount, isEmpty,
            reason: 'Restored backup had empty star counts, so currentXStarCount should be empty (type=${type.name})');
        expect(history.fiftyFiftyXStarGuaranteed, isEmpty,
            reason: 'Restored backup had empty guarantees, so this should be empty (type=${type.name})');

        final itemPullHistory = dataService.wishSimulator.getBannerItemsPullHistoryPerType(type);
        expect(itemPullHistory.length, 1,
            reason: 'Restore should replace prior pulls with the single backed-up item pull (type=${type.name})');

        final item = itemPullHistory.first;
        expect(item.bannerType, type.index,
            reason: 'Restored item pull must record its banner type (expected=${type.index}, name=${type.name})');
        expect(item.itemKey, startsWith('item-'),
            reason: 'Restored item pull key should come from the backup (got ${item.itemKey}, expected item-* prefix)');
        expect(item.itemType, isIn(validItemTypes.map((e) => e.index)),
            reason: 'Restored item pull itemType ${item.itemType} must be a valid character/weapon index');
        expect(item.pulledOnDate, isIn([pulledOnMin, pulledOnMax]),
            reason: 'Restored item pull pulledOnDate ${item.pulledOnDate} should match a backed-up timestamp');
      }
    });
  });
}
