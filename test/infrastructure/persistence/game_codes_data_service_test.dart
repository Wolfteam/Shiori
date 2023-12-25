import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_asc_materials_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const String _baseDbFolder = 'shiori_game_codes_data_service';

void main() {
  late final ResourceService resourceService;
  late final GenshinService genshinService;
  late final CalculatorAscMaterialsService calculatorService;

  final gameCodes = <GameCodeModel>[
    GameCodeModel(
      code: 'xxxx',
      discoveredOn: DateTime.now().subtract(const Duration(days: 10)),
      isExpired: false,
      rewards: const [
        ItemAscensionMaterialModel(
          key: 'mora',
          image: '',
          rarity: 0,
          type: MaterialType.currency,
          level: 0,
          position: 0,
          requiredQuantity: 10000,
          remainingQuantity: 0,
          hasSiblings: false,
          usedQuantity: 0,
        ),
        ItemAscensionMaterialModel(
          key: 'primogem',
          image: '',
          rarity: 0,
          type: MaterialType.currency,
          level: 0,
          position: 0,
          requiredQuantity: 100,
          remainingQuantity: 0,
          hasSiblings: false,
          usedQuantity: 0,
        ),
      ],
      isUsed: false,
      region: AppServerResetTimeType.europe,
    ),
    GameCodeModel(
      code: 'zzzz',
      discoveredOn: DateTime.now(),
      isExpired: false,
      rewards: const [
        ItemAscensionMaterialModel(
          key: 'primogem',
          image: '',
          rarity: 0,
          type: MaterialType.currency,
          level: 0,
          position: 0,
          requiredQuantity: 60,
          remainingQuantity: 0,
          hasSiblings: false,
          usedQuantity: 0,
        ),
      ],
      isUsed: false,
      expiredOn: DateTime.now().add(const Duration(days: 10)),
    ),
  ];

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

  void checkGameCodeRewards(List<ItemAscensionMaterialModel> gotRewards, List<ItemAscensionMaterialModel> expectedRewards) {
    expect(gotRewards.length, expectedRewards.length);
    for (int i = 0; i < gotRewards.length; i++) {
      final got = gotRewards[i];
      final expected = expectedRewards[i];
      expect(got.key, expected.key);
      expect(got.requiredQuantity, expected.requiredQuantity);
    }
  }

  void checkGameCode(GameCodeModel got, GameCodeModel expected) {
    expect(got.code, expected.code);
    expect(got.isExpired, expected.isExpired);
    expect(got.expiredOn, expected.expiredOn);
    expect(got.discoveredOn, expected.discoveredOn);
    expect(got.isUsed, expected.isUsed);
    expect(got.region, expected.region);
    checkGameCodeRewards(got.rewards, expected.rewards);
  }

  group('Get all game codes', () {
    const dbFolder = '${_baseDbFolder}_get_all_game_codes_tests';
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
      final codes = dataService.gameCodes.getAllGameCodes();
      expect(codes.isEmpty, isTrue);
    });

    test('data exists', () async {
      await dataService.gameCodes.saveGameCodes(gameCodes);
      final codes = dataService.gameCodes.getAllGameCodes();
      expect(codes.length, gameCodes.length);
      for (int i = 0; i < gameCodes.length; i++) {
        final got = codes[i];
        final expected = gameCodes[i];
        checkGameCode(got, expected);
      }
    });
  });

  group('Save game codes', () {
    const dbFolder = '${_baseDbFolder}_save_game_codes_tests';
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

    test('nothing to save thus completes normally', () {
      expect(dataService.gameCodes.saveGameCodes([]), completes);
    });

    test('no previous game codes exist', () async {
      await dataService.gameCodes.saveGameCodes(gameCodes);
      final allGameCodes = dataService.gameCodes.getAllGameCodes();
      expect(allGameCodes.length, gameCodes.length);
      for (int i = 0; i < gameCodes.length; i++) {
        final got = allGameCodes[i];
        final expected = gameCodes[i];
        checkGameCode(got, expected);
      }
    });

    test('game code already exists thus it gets updated', () async {
      await dataService.gameCodes.saveGameCodes(gameCodes);
      final updated = gameCodes.first.copyWith(expiredOn: DateTime.now(), isExpired: true);
      await dataService.gameCodes.saveGameCodes([updated]);
      final allGameCodes = dataService.gameCodes.getAllGameCodes();
      expect(allGameCodes.length, gameCodes.length);
      checkGameCode(allGameCodes.first, updated);
    });
  });

  group('Mark game code as used', () {
    const dbFolder = '${_baseDbFolder}_mark_game_code_as_used_tests';
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

    test('invalid code', () {
      expect(dataService.gameCodes.markCodeAsUsed(''), throwsArgumentError);
    });

    test('code does not exist', () {
      expect(dataService.gameCodes.markCodeAsUsed('QWERTY'), throwsA(isA<NotFoundError>()));
    });

    test('code exists and it is marked as used', () async {
      await dataService.gameCodes.saveGameCodes(gameCodes);
      await dataService.gameCodes.markCodeAsUsed(gameCodes.first.code);
      final updatedCodes = dataService.gameCodes.getAllGameCodes();
      expect(updatedCodes.first.isUsed, isTrue);
    });

    test('code exists, it was used and it is marked as unused', () async {
      await dataService.gameCodes.saveGameCodes(gameCodes);
      await dataService.gameCodes.markCodeAsUsed(gameCodes.first.code);
      await dataService.gameCodes.markCodeAsUsed(gameCodes.first.code, wasUsed: false);
      final updatedCodes = dataService.gameCodes.getAllGameCodes();
      expect(updatedCodes.first.isUsed, isFalse);
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
      final bk = dataService.gameCodes.getDataForBackup();
      expect(bk.isEmpty, isTrue);
    });

    test('data exists', () async {
      await dataService.gameCodes.saveGameCodes(gameCodes);
      final bk = dataService.gameCodes.getDataForBackup();
      expect(bk.length, gameCodes.length);
      for (int i = 0; i < gameCodes.length; i++) {
        final got = bk[i];
        final expected = gameCodes[i];
        expect(got.code, expected.code);
        expect(got.discoveredOn, expected.discoveredOn);
        expect(got.expiredOn, expected.expiredOn);
        expect(got.isExpired, expected.isExpired);
        expect(got.region, expected.region?.index);
        expect(got.rewards.length, expected.rewards.length);
        for (int i = 0; i < got.rewards.length; i++) {
          final gotReward = got.rewards[i];
          final expectedReward = expected.rewards[i];
          expect(gotReward.itemKey, expectedReward.key);
          expect(gotReward.quantity, expectedReward.requiredQuantity);
        }
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

    test('empty backup and no data exist', () {
      expect(dataService.gameCodes.restoreFromBackup([]), completes);
    });

    test('empty backup and data exists thus it gets deleted', () async {
      await dataService.gameCodes.saveGameCodes(gameCodes);
      await dataService.gameCodes.restoreFromBackup([]);
      final allGameCodes = dataService.gameCodes.getAllGameCodes();
      expect(allGameCodes.isEmpty, isTrue);
    });

    test('data gets restored', () async {
      await dataService.gameCodes.saveGameCodes(gameCodes);
      final bk = dataService.gameCodes.getDataForBackup().map((e) => e.copyWith(code: '${e.code}-bk')).toList();
      await dataService.gameCodes.restoreFromBackup(bk);
      final allGameCodes = dataService.gameCodes.getAllGameCodes();
      expect(allGameCodes.isNotEmpty, isTrue);
      for (int i = 0; i < gameCodes.length; i++) {
        final got = bk[i];
        final expected = bk[i];
        expect(got.code, expected.code);
        expect(got.discoveredOn, expected.discoveredOn);
        expect(got.expiredOn, expected.expiredOn);
        expect(got.isExpired, expected.isExpired);
        expect(got.region, expected.region);
        expect(got.rewards.length, expected.rewards.length);
        for (int i = 0; i < got.rewards.length; i++) {
          final gotReward = got.rewards[i];
          final expectedReward = expected.rewards[i];
          expect(gotReward.itemKey, expectedReward.itemKey);
          expect(gotReward.quantity, expectedReward.quantity);
        }
      }
    });
  });
}
