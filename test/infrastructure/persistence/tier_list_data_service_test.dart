import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_asc_materials_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const String _baseDbFolder = 'shiori_tier_list_data_service';

void main() {
  late final ResourceService resourceService;
  late final GenshinService genshinService;
  late final CalculatorAscMaterialsService calculatorService;
  final List<TierListRowModel> defaultTierList = [];

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
      final colors = Iterable.generate(7, (i) => i + 1).toList();
      defaultTierList.addAll(genshinService.characters.getDefaultCharacterTierList(colors));
    });
  });

  void checkTierList(List<TierListRowModel> got, List<TierListRowModel> expected) {
    expect(got.length, expected.length,
        reason: 'Persisted tier list should keep every row (expected=${expected.length}, got=${got.length})');
    for (int i = 0; i < got.length; i++) {
      final gotRow = got[i];
      final expectedRow = expected[i];
      expect(gotRow.tierText, expectedRow.tierText,
          reason: 'Row #$i tierText mismatch (expected=${expectedRow.tierText}, got=${gotRow.tierText})');
      expect(gotRow.tierColor, expectedRow.tierColor,
          reason: 'Row ${expectedRow.tierText} tierColor mismatch (expected=${expectedRow.tierColor})');
      expect(gotRow.items.length, expectedRow.items.length,
          reason: 'Row ${expectedRow.tierText} item count mismatch (expected=${expectedRow.items.length})');
      for (int j = 0; j < gotRow.items.length; j++) {
        final gotItem = gotRow.items[j];
        final expectedItem = expectedRow.items[j];
        expect(gotItem.key, expectedItem.key,
            reason: 'Row ${expectedRow.tierText} item #$j key mismatch (expected=${expectedItem.key})');
      }
    }
  }

  group('Get tier list', () {
    const dbFolder = '${_baseDbFolder}_get_tier_list_tests';
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
      final list = dataService.tierList.getTierList();
      expect(list.isEmpty, isTrue, reason: 'getTierList should return empty when no tier list was saved');
    });

    test('data exists', () async {
      await dataService.tierList.saveTierList(defaultTierList);
      final list = dataService.tierList.getTierList();
      checkTierList(list, defaultTierList);
    });
  });

  group('Save tier list', () {
    const dbFolder = '${_baseDbFolder}_save_tier_list_tests';
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

    test('no data to save and no previous data exist', () async {
      await dataService.tierList.saveTierList([]);
      final int count = dataService.tierList.getTierList().length;
      expect(count, isZero, reason: 'Saving an empty tier list into an empty store should leave zero rows');
    });

    test('no data to save and previous data exist', () async {
      await dataService.tierList.saveTierList(defaultTierList);
      await dataService.tierList.saveTierList([]);
      final int count = dataService.tierList.getTierList().length;
      expect(count, isZero, reason: 'Saving an empty tier list should overwrite and clear the previously saved rows');
    });

    test('there is data to save and previous data exist', () async {
      final expected = defaultTierList.take(defaultTierList.length ~/ 2).toList();
      await dataService.tierList.saveTierList(defaultTierList);
      await dataService.tierList.saveTierList(expected);
      final list = dataService.tierList.getTierList();
      checkTierList(list, expected);
    });
  });

  group('Delete tier list', () {
    const dbFolder = '${_baseDbFolder}_delete_tier_list_tests';
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
      await dataService.tierList.deleteTierList();
      final int count = dataService.tierList.getTierList().length;
      expect(count, isZero, reason: 'Deleting an already-empty tier list should leave zero rows');
    });

    test('data exists', () async {
      await dataService.tierList.saveTierList(defaultTierList);
      await dataService.tierList.deleteTierList();
      final int count = dataService.tierList.getTierList().length;
      expect(count, isZero, reason: 'deleteTierList should remove all previously saved rows');
    });
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
      final bk = dataService.tierList.getDataForBackup();
      expect(bk.isEmpty, isTrue, reason: 'Backup of tier list should be empty when no rows were saved');
    });

    test('data exists', () async {
      await dataService.tierList.saveTierList(defaultTierList);
      final bk = dataService.tierList.getDataForBackup();
      expect(bk.length, defaultTierList.length,
          reason: 'Backup should contain every saved row (expected=${defaultTierList.length}, got=${bk.length})');
      for (int i = 0; i < bk.length; i++) {
        final got = bk[i];
        final expected = defaultTierList[i];
        expect(got.text, expected.tierText,
            reason: 'Backup row #$i text mismatch (expected=${expected.tierText}, got=${got.text})');
        expect(got.color, expected.tierColor,
            reason: 'Backup row ${expected.tierText} color mismatch (expected=${expected.tierColor})');
        expect(got.position, i,
            reason: 'Backup row ${expected.tierText} should keep list order as position (expected=$i)');
        expect(got.charKeys, expected.items.map((e) => e.key).toList(),
            reason: 'Backup row ${expected.tierText} charKeys mismatch with saved items');
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
      await dataService.tierList.restoreFromBackup([]);
      final count = dataService.tierList.getDataForBackup().length;
      expect(count, isZero, reason: 'Restoring an empty backup with no existing data should leave zero rows');
    });

    test('no data to restore and previous data exist', () async {
      await dataService.tierList.saveTierList(defaultTierList);
      await dataService.inventory.restoreFromBackup([]);
      final count = dataService.inventory.getDataForBackup().length;
      expect(count, isZero, reason: 'Restoring an empty inventory backup should clear previously saved inventory data');
    });

    test('there is data to restore and previous data exist', () async {
      await dataService.tierList.saveTierList(defaultTierList);
      final bk = defaultTierList
          .mapIndex(
            (e, i) => BackupTierListModel(
              text: '${e.tierText}-$i',
              position: i,
              color: e.tierColor * 3,
              charKeys: e.items.map((e) => e.key).toList(),
            ),
          )
          .toList();
      await dataService.tierList.restoreFromBackup(bk);

      final data = dataService.tierList.getDataForBackup();
      expect(data.length, bk.length,
          reason: 'Restored tier list should contain every backed-up row (expected=${bk.length}, got=${data.length})');
      for (int i = 0; i < bk.length; i++) {
        final got = data[i];
        final expected = bk[i];
        expect(got.text, expected.text,
            reason: 'Restored row #$i text mismatch (expected=${expected.text}, got=${got.text})');
        expect(got.color, expected.color,
            reason: 'Restored row ${expected.text} color mismatch (expected=${expected.color}, got=${got.color})');
        expect(got.position, expected.position,
            reason: 'Restored row ${expected.text} position mismatch (expected=${expected.position})');
        expect(got.charKeys, expected.charKeys,
            reason: 'Restored row ${expected.text} charKeys mismatch with backup');
      }
    });
  });
}
