import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const _dbFolder = 'shiori_weapon_bloc_tests';

void main() {
  late final TelemetryService telemetryService;
  late final GenshinService genshinService;
  late final DataService dataService;
  late final ResourceService resourceService;
  late final String dbPath;

  const key = 'aquila-favonia';

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    telemetryService = MockTelemetryService();
    final settingsService = SettingsServiceImpl(MockLoggingService());
    final localeService = LocaleServiceImpl(settingsService);
    resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);
    dataService = DataServiceImpl(
      genshinService,
      CalculatorAscMaterialsServiceImpl(genshinService, resourceService),
      resourceService,
    );

    return Future(() async {
      await genshinService.init(AppLanguageType.english);
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
      WeaponBloc(genshinService, telemetryService, dataService, resourceService).state,
      const WeaponState.loading(),
      reason: 'Should match expected value (property=state)',
    ),
  );

  group('Load from key', () {
    void checkState(WeaponState state, bool isInInventory) {
      switch (state) {
        case WeaponStateLoading():
          throw InvalidStateError();
        case WeaponStateLoaded():
          expect(state.key, key, reason: 'Should match expected value (property=key)');
          expect(state.name, 'Aquila Favonia', reason: "Should match expected value (property=name, expected='Aquila Favonia')");
          checkAsset(state.fullImage);
          checkTranslation(state.description, canBeNull: false);
          expect(state.rarity, 5, reason: 'Should match expected value (property=rarity, expected=5)');
          expect(state.atk, 48, reason: 'Should match expected value (property=atk, expected=48)');
          expect(state.secondaryStatValue, 9, reason: 'Should match expected value (property=secondaryStatValue, expected=9)');
          expect(
            state.secondaryStat,
            StatType.physDmgBonus,
            reason: 'Should match expected value (property=secondaryStat, expected=StatType.physDmgBonus)',
          );
          expect(
            state.locationType,
            ItemLocationType.gacha,
            reason: 'Should match expected value (property=locationType, expected=ItemLocationType.gacha)',
          );
          expect(
            state.weaponType,
            WeaponType.sword,
            reason: 'Should match expected value (property=weaponType, expected=WeaponType.sword)',
          );
          expect(state.isInInventory, isInInventory, reason: 'Should match expected value (property=isInInventory)');
          expect(state.ascensionMaterials, isNotEmpty, reason: 'Should not be empty (property=ascensionMaterials)');
          expect(state.refinements, isNotEmpty, reason: 'Should not be empty (property=refinements)');
          expect(state.characters, isNotEmpty, reason: 'Should not be empty (property=characters)');
          expect(state.stats, isNotEmpty, reason: 'Should not be empty (property=stats)');
          expect(state.craftingMaterials, isEmpty, reason: 'Should be empty (property=craftingMaterials)');
      }
    }

    blocTest<WeaponBloc, WeaponState>(
      'keqing',
      build: () => WeaponBloc(genshinService, telemetryService, dataService, resourceService),
      act: (bloc) => bloc.add(const WeaponEvent.loadFromKey(key: key)),
      //we skip 1 because since the event is not _AddedToInventory the bloc will emit a loading
      skip: 1,
      verify: (bloc) => checkState(bloc.state, false),
    );

    blocTest<WeaponBloc, WeaponState>(
      'keqing is in inventory',
      build: () => WeaponBloc(genshinService, telemetryService, dataService, resourceService),
      setUp: () {
        dataService.inventory.addWeaponToInventory(key);
      },
      act: (bloc) => bloc.add(const WeaponEvent.loadFromKey(key: key)),
      //we skip 1 because since the event is not _AddedToInventory the bloc will emit a loading
      skip: 1,
      verify: (bloc) => checkState(bloc.state, true),
    );
  });
}
