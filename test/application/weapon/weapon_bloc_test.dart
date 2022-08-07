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
  late final TelemetryService _telemetryService;
  late final GenshinService _genshinService;
  late final DataService _dataService;
  late final ResourceService _resourceService;
  late final String _dbPath;

  const _key = 'aquila-favonia';

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _telemetryService = MockTelemetryService();
    final settingsService = SettingsServiceImpl(MockLoggingService());
    final localeService = LocaleServiceImpl(settingsService);
    _resourceService = getResourceService(settingsService);
    _genshinService = GenshinServiceImpl(_resourceService, localeService);
    _dataService = DataServiceImpl(_genshinService, CalculatorServiceImpl(_genshinService, _resourceService), _resourceService);

    return Future(() async {
      await _genshinService.init(AppLanguageType.english);
      _dbPath = await getDbPath(_dbFolder);
      await _dataService.initForTests(_dbPath);
    });
  });

  tearDownAll(() {
    return Future(() async {
      await _dataService.closeThemAll();
      await deleteDbFolder(_dbPath);
    });
  });

  test(
    'Initial state',
    () => expect(WeaponBloc(_genshinService, _telemetryService, _dataService, _resourceService).state, const WeaponState.loading()),
  );

  group('Load from key', () {
    void _checkState(WeaponState state, bool isInInventory) {
      state.map(
        loading: (_) => throw Exception('Invalid state'),
        loaded: (state) {
          expect(state.key, _key);
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
      build: () => WeaponBloc(_genshinService, _telemetryService, _dataService, _resourceService),
      act: (bloc) => bloc.add(const WeaponEvent.loadFromKey(key: _key)),
      //we skip 1 because since the event is not _AddedToInventory the bloc will emit a loading
      skip: 1,
      verify: (bloc) => _checkState(bloc.state, false),
    );

    blocTest<WeaponBloc, WeaponState>(
      'keqing is in inventory',
      build: () => WeaponBloc(_genshinService, _telemetryService, _dataService, _resourceService),
      setUp: () {
        _dataService.inventory.addItemToInventory(_key, ItemType.weapon, 1);
      },
      act: (bloc) => bloc.add(const WeaponEvent.loadFromKey(key: _key)),
      //we skip 1 because since the event is not _AddedToInventory the bloc will emit a loading
      skip: 1,
      verify: (bloc) => _checkState(bloc.state, true),
    );
  });
}
