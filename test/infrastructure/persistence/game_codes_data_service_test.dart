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
    expect(gotRewards.length, expectedRewards.length,
        reason: 'Game code should keep all rewards (expected=${expectedRewards.length}, got=${gotRewards.length})');
    for (int i = 0; i < gotRewards.length; i++) {
      final got = gotRewards[i];
      final expected = expectedRewards[i];
      expect(got.key, expected.key, reason: 'Reward #$i key mismatch (expected=${expected.key}, got=${got.key})');
      expect(got.requiredQuantity, expected.requiredQuantity,
          reason: 'Reward ${expected.key} quantity mismatch (expected=${expected.requiredQuantity})');
    }
  }

  void checkGameCode(GameCodeModel got, GameCodeModel expected) {
    expect(got.code, expected.code,
        reason: 'Persisted game code value mismatch (expected=${expected.code}, got=${got.code})');
    expect(got.isExpired, expected.isExpired,
        reason: 'Game code ${expected.code} isExpired mismatch (expected=${expected.isExpired}, got=${got.isExpired})');
    expect(got.expiredOn, expected.expiredOn,
        reason: 'Game code ${expected.code} expiredOn mismatch (expected=${expected.expiredOn}, got=${got.expiredOn})');
    expect(got.discoveredOn, expected.discoveredOn,
        reason: 'Game code ${expected.code} discoveredOn mismatch (expected=${expected.discoveredOn})');
    expect(got.isUsed, expected.isUsed,
        reason: 'Game code ${expected.code} isUsed mismatch (expected=${expected.isUsed}, got=${got.isUsed})');
    expect(got.region, expected.region,
        reason: 'Game code ${expected.code} region mismatch (expected=${expected.region}, got=${got.region})');
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
      expect(codes.isEmpty, isTrue, reason: 'getAllGameCodes should return empty when no codes were saved');
    });

    test('data exists', () async {
      await dataService.gameCodes.saveGameCodes(gameCodes);
      final codes = dataService.gameCodes.getAllGameCodes();
      expect(codes.length, gameCodes.length,
          reason: 'All saved codes should be returned (expected=${gameCodes.length}, got=${codes.length})');
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
      expect(dataService.gameCodes.saveGameCodes([]), completes,
          reason: 'Saving an empty game-code list should complete without error');
    });

    test('no previous game codes exist', () async {
      await dataService.gameCodes.saveGameCodes(gameCodes);
      final allGameCodes = dataService.gameCodes.getAllGameCodes();
      expect(allGameCodes.length, gameCodes.length,
          reason: 'Saving into an empty store should persist all codes (expected=${gameCodes.length})');
      for (int i = 0; i < gameCodes.length; i++) {
        final got = allGameCodes[i];
        final expected = gameCodes[i];
        checkGameCode(got, expected);
      }
    });

    test('previous game codes existed and they get deleted', () async {
      await dataService.gameCodes.saveGameCodes(gameCodes);
      final updated = gameCodes.first.copyWith(expiredOn: DateTime.now(), isExpired: true);
      await dataService.gameCodes.saveGameCodes([updated]);
      final allGameCodes = dataService.gameCodes.getAllGameCodes();
      expect(allGameCodes.length, 1,
          reason: 'saveGameCodes should replace prior codes, leaving only the single saved code');
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
      expect(dataService.gameCodes.markCodeAsUsed(''), throwsArgumentError,
          reason: 'Marking an empty code as used must throw ArgumentError');
    });

    test('code does not exist', () {
      expect(dataService.gameCodes.markCodeAsUsed('QWERTY'), throwsA(isA<NotFoundError>()),
          reason: 'Marking a non-existent code (QWERTY) as used must throw NotFoundError');
    });

    test('code exists and it is marked as used', () async {
      await dataService.gameCodes.saveGameCodes(gameCodes);
      await dataService.gameCodes.markCodeAsUsed(gameCodes.first.code);
      final updatedCodes = dataService.gameCodes.getAllGameCodes();
      expect(updatedCodes.first.isUsed, isTrue,
          reason: 'markCodeAsUsed should set isUsed=true for code ${gameCodes.first.code}');
    });

    test('code exists, it was used and it is marked as unused', () async {
      await dataService.gameCodes.saveGameCodes(gameCodes);
      await dataService.gameCodes.markCodeAsUsed(gameCodes.first.code);
      await dataService.gameCodes.markCodeAsUsed(gameCodes.first.code, wasUsed: false);
      final updatedCodes = dataService.gameCodes.getAllGameCodes();
      expect(updatedCodes.first.isUsed, isFalse,
          reason: 'markCodeAsUsed(wasUsed:false) should reset isUsed to false for code ${gameCodes.first.code}');
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
      expect(bk.isEmpty, isTrue, reason: 'Backup of game codes should be empty when none were saved');
    });

    test('data exists', () async {
      await dataService.gameCodes.saveGameCodes(gameCodes);
      final bk = dataService.gameCodes.getDataForBackup();
      expect(bk.length, gameCodes.length,
          reason: 'Backup should contain every saved code (expected=${gameCodes.length}, got=${bk.length})');
      for (int i = 0; i < gameCodes.length; i++) {
        final got = bk[i];
        final expected = gameCodes[i];
        expect(got.code, expected.code,
            reason: 'Backup code #$i mismatch (expected=${expected.code}, got=${got.code})');
        expect(got.discoveredOn, expected.discoveredOn,
            reason: 'Backup ${expected.code} discoveredOn mismatch (expected=${expected.discoveredOn})');
        expect(got.expiredOn, expected.expiredOn,
            reason: 'Backup ${expected.code} expiredOn mismatch (expected=${expected.expiredOn})');
        expect(got.isExpired, expected.isExpired,
            reason: 'Backup ${expected.code} isExpired mismatch (expected=${expected.isExpired})');
        expect(got.region, expected.region?.index,
            reason: 'Backup ${expected.code} region should be stored as enum index (got=${got.region})');
        expect(got.rewards.length, expected.rewards.length,
            reason: 'Backup ${expected.code} reward count mismatch (expected=${expected.rewards.length})');
        for (int i = 0; i < got.rewards.length; i++) {
          final gotReward = got.rewards[i];
          final expectedReward = expected.rewards[i];
          expect(gotReward.itemKey, expectedReward.key,
              reason: 'Backup reward #$i itemKey mismatch (expected=${expectedReward.key}, got=${gotReward.itemKey})');
          expect(gotReward.quantity, expectedReward.requiredQuantity,
              reason: 'Backup reward ${expectedReward.key} quantity mismatch (got=${gotReward.quantity})');
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
      expect(dataService.gameCodes.restoreFromBackup([]), completes,
          reason: 'Restoring an empty backup with no existing data should complete without error');
    });

    test('empty backup and data exists thus it gets deleted', () async {
      await dataService.gameCodes.saveGameCodes(gameCodes);
      await dataService.gameCodes.restoreFromBackup([]);
      final allGameCodes = dataService.gameCodes.getAllGameCodes();
      expect(allGameCodes.isEmpty, isTrue,
          reason: 'Restoring an empty backup should delete all previously saved game codes');
    });

    test('data gets restored', () async {
      await dataService.gameCodes.saveGameCodes(gameCodes);
      final bk = dataService.gameCodes.getDataForBackup().map((e) => e.copyWith(code: '${e.code}-bk')).toList();
      await dataService.gameCodes.restoreFromBackup(bk);
      final allGameCodes = dataService.gameCodes.getAllGameCodes();
      expect(allGameCodes.isNotEmpty, isTrue,
          reason: 'Restoring a non-empty backup should populate the game codes store');
      for (int i = 0; i < gameCodes.length; i++) {
        final got = bk[i];
        final expected = bk[i];
        expect(got.code, expected.code, reason: 'Restored backup code #$i mismatch (expected=${expected.code})');
        expect(got.discoveredOn, expected.discoveredOn,
            reason: 'Restored backup ${expected.code} discoveredOn mismatch (expected=${expected.discoveredOn})');
        expect(got.expiredOn, expected.expiredOn,
            reason: 'Restored backup ${expected.code} expiredOn mismatch (expected=${expected.expiredOn})');
        expect(got.isExpired, expected.isExpired,
            reason: 'Restored backup ${expected.code} isExpired mismatch (expected=${expected.isExpired})');
        expect(got.region, expected.region,
            reason: 'Restored backup ${expected.code} region mismatch (expected=${expected.region})');
        expect(got.rewards.length, expected.rewards.length,
            reason: 'Restored backup ${expected.code} reward count mismatch (expected=${expected.rewards.length})');
        for (int i = 0; i < got.rewards.length; i++) {
          final gotReward = got.rewards[i];
          final expectedReward = expected.rewards[i];
          expect(gotReward.itemKey, expectedReward.itemKey,
              reason: 'Restored backup reward #$i itemKey mismatch (expected=${expectedReward.itemKey})');
          expect(gotReward.quantity, expectedReward.quantity,
              reason: 'Restored backup reward ${expectedReward.itemKey} quantity mismatch (got=${gotReward.quantity})');
        }
      }
    });
  });
}
