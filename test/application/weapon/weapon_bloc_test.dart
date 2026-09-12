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
      reason: 'A fresh WeaponBloc should start in loading state',
    ),
  );

  group('Load from key', () {
    void checkState(WeaponState state, bool isInInventory) {
      switch (state) {
        case WeaponStateLoading():
          throw InvalidStateError();
        case WeaponStateLoaded():
          expect(state.key, key, reason: 'Loaded weapon should carry key aquila-favonia, got ${state.key}');
          expect(state.name, 'Aquila Favonia', reason: 'aquila-favonia name should be Aquila Favonia, got ${state.name}');
          checkAsset(state.fullImage);
          checkTranslation(state.description, canBeNull: false);
          expect(state.rarity, 5, reason: 'aquila-favonia rarity should be 5, got ${state.rarity}');
          expect(state.atk, 48, reason: 'aquila-favonia base atk should be 48, got ${state.atk}');
          expect(state.secondaryStatValue, 9, reason: 'aquila-favonia secondary stat value should be 9, got ${state.secondaryStatValue}');
          expect(
            state.secondaryStat,
            StatType.physDmgBonus,
            reason: 'aquila-favonia secondary stat should be physDmgBonus, got ${state.secondaryStat}',
          );
          expect(
            state.locationType,
            ItemLocationType.gacha,
            reason: 'aquila-favonia location should be gacha, got ${state.locationType}',
          );
          expect(
            state.weaponType,
            WeaponType.sword,
            reason: 'aquila-favonia weapon type should be sword, got ${state.weaponType}',
          );
          expect(state.isInInventory, isInInventory, reason: 'aquila-favonia isInInventory should match the seeded inventory state ($isInInventory)');
          expect(state.ascensionMaterials, isNotEmpty, reason: 'aquila-favonia should list ascension materials');
          expect(state.refinements, isNotEmpty, reason: 'aquila-favonia should list refinements');
          expect(state.characters, isNotEmpty, reason: 'aquila-favonia should list characters that use it');
          expect(state.stats, isNotEmpty, reason: 'aquila-favonia should list stats');
          expect(state.craftingMaterials, isEmpty, reason: 'aquila-favonia is not craftable so craftingMaterials should be empty');
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
