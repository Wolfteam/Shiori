import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
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
    final settingsService = SettingsServiceImpl();
    final localeService = LocaleServiceImpl(settingsService);
    resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);
    dataService = DataServiceImpl(genshinService, CalculatorAscMaterialsServiceImpl(genshinService, resourceService), resourceService);

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
    () => expect(WeaponBloc(genshinService, telemetryService, dataService, resourceService).state, const WeaponState.loading()),
  );

  group('Load from key', () {
    void checkState(WeaponState state, bool isInInventory) {
      state.map(
        loading: (_) => throw Exception('Invalid state'),
        loaded: (state) {
          expect(state.key, key);
          expect(state.name, 'Aquila Favonia');
          checkAsset(state.fullImage);
          checkTranslation(state.description, canBeNull: false);
          expect(state.rarity, 5);
          expect(state.atk, 48);
          expect(state.secondaryStatValue, 9);
          expect(state.secondaryStat, StatType.physDmgBonus);
          expect(state.locationType, ItemLocationType.gacha);
          expect(state.weaponType, WeaponType.sword);
          expect(state.isInInventory, isInInventory);
          expect(state.ascensionMaterials, isNotEmpty);
          expect(state.refinements, isNotEmpty);
          expect(state.characters, isNotEmpty);
          expect(state.stats, isNotEmpty);
          expect(state.craftingMaterials, isEmpty);
        },
      );
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
