import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const _dbFolder = 'shiori_inventory_bloc_tests';

void main() {
  late final TelemetryService _telemetryService;
  late final SettingsService _settingsService;
  late final LocaleService _localeService;
  late final GenshinService _genshinService;
  late final DataService _dataService;

  const _keqingKey = 'keqing';
  const _aquilaFavoniaKey = 'aquila-favonia';
  const _moraKey = 'mora';

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _telemetryService = MockTelemetryService();
    _settingsService = MockSettingsService();
    when(_settingsService.language).thenReturn(AppLanguageType.english);
    _localeService = LocaleServiceImpl(_settingsService);
    _genshinService = GenshinServiceImpl(_localeService);
    _dataService = DataServiceImpl(_genshinService, CalculatorServiceImpl(_genshinService));
    return Future(() async {
      await _genshinService.init(_settingsService.language);
      await _dataService.init(dir: _dbFolder);
    });
  });

  tearDownAll(() {
    return Future(() async {
      await _dataService.closeThemAll();
      await deleteDbFolder(_dbFolder);
    });
  });

  test(
    'Initial state',
    () => expect(
      InventoryBloc(_genshinService, _dataService, _telemetryService).state,
      const InventoryState.loaded(characters: [], weapons: [], materials: []),
    ),
  );

  blocTest<InventoryBloc, InventoryState>(
    'On init I should have 1 character, 1 weapon and 20k of mora',
    setUp: () async {
      await _dataService.deleteThemAll();
    },
    build: () => InventoryBloc(_genshinService, _dataService, _telemetryService),
    act: (bloc) => bloc
      ..add(const InventoryEvent.addCharacter(key: _keqingKey))
      ..add(const InventoryEvent.addWeapon(key: _aquilaFavoniaKey))
      ..add(const InventoryEvent.updateMaterial(key: _moraKey, quantity: 20000))
      ..add(const InventoryEvent.init()),
    //here I skip only 2 cause the init event does not make an state change
    skip: 2,
    expect: () {
      final character = _genshinService.characters.getCharacterForCard(_keqingKey);
      final weapon = _genshinService.weapons.getWeaponForCard(_aquilaFavoniaKey);
      final materials = _dataService.inventory.getAllMaterialsInInventory();
      final material = materials.firstWhere((el) => el.key == _moraKey);
      expect(material.quantity, 20000);
      return [
        InventoryState.loaded(
          characters: [character],
          weapons: [weapon],
          materials: materials,
        )
      ];
    },
  );

  group('Add', () {
    blocTest<InventoryBloc, InventoryState>(
      'character = $_keqingKey',
      setUp: () async {
        await _dataService.deleteThemAll();
      },
      build: () => InventoryBloc(_genshinService, _dataService, _telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.init())
        ..add(const InventoryEvent.addCharacter(key: _keqingKey)),
      skip: 1,
      expect: () {
        final character = _genshinService.characters.getCharacterForCard(_keqingKey);
        final materials = _dataService.inventory.getAllMaterialsInInventory();
        return [
          InventoryState.loaded(
            characters: [character],
            weapons: [],
            materials: materials,
          )
        ];
      },
    );

    blocTest<InventoryBloc, InventoryState>(
      'weapon = $_aquilaFavoniaKey',
      setUp: () async {
        await _dataService.deleteThemAll();
      },
      build: () => InventoryBloc(_genshinService, _dataService, _telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.init())
        ..add(const InventoryEvent.addWeapon(key: _aquilaFavoniaKey)),
      skip: 1,
      expect: () {
        final weapon = _genshinService.weapons.getWeaponForCard(_aquilaFavoniaKey);
        final materials = _dataService.inventory.getAllMaterialsInInventory();
        return [
          InventoryState.loaded(
            characters: [],
            weapons: [weapon],
            materials: materials,
          )
        ];
      },
    );

    blocTest<InventoryBloc, InventoryState>(
      'material = $_moraKey',
      setUp: () async {
        await _dataService.deleteThemAll();
      },
      build: () => InventoryBloc(_genshinService, _dataService, _telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.init())
        ..add(const InventoryEvent.updateMaterial(key: _moraKey, quantity: 100000)),
      skip: 1,
      expect: () {
        final materials = _dataService.inventory.getAllMaterialsInInventory();
        final material = materials.firstWhere((el) => el.key == _moraKey);
        expect(material.quantity, 100000);
        return [
          InventoryState.loaded(
            characters: [],
            weapons: [],
            materials: materials,
          )
        ];
      },
    );
  });

  group('Delete', () {
    blocTest<InventoryBloc, InventoryState>(
      'character = $_keqingKey',
      setUp: () async {
        await _dataService.deleteThemAll();
      },
      build: () => InventoryBloc(_genshinService, _dataService, _telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.addCharacter(key: _keqingKey))
        ..add(const InventoryEvent.deleteCharacter(key: _keqingKey))
        ..add(const InventoryEvent.init()),
      //here I skip only 2 cause the init event does not make an state change
      skip: 2,
      expect: () {
        final materials = _dataService.inventory.getAllMaterialsInInventory();
        return [
          InventoryState.loaded(
            characters: [],
            weapons: [],
            materials: materials,
          )
        ];
      },
    );

    blocTest<InventoryBloc, InventoryState>(
      'weapon = $_aquilaFavoniaKey',
      setUp: () async {
        await _dataService.deleteThemAll();
      },
      build: () => InventoryBloc(_genshinService, _dataService, _telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.addWeapon(key: _aquilaFavoniaKey))
        ..add(const InventoryEvent.deleteWeapon(key: _aquilaFavoniaKey))
        ..add(const InventoryEvent.init()),
      //here I skip only 2 cause the init event does not make an state change
      skip: 2,
      expect: () {
        final materials = _dataService.inventory.getAllMaterialsInInventory();
        return [
          InventoryState.loaded(
            characters: [],
            weapons: [],
            materials: materials,
          )
        ];
      },
    );

    blocTest<InventoryBloc, InventoryState>(
      'material = $_moraKey',
      setUp: () async {
        await _dataService.deleteThemAll();
      },
      build: () => InventoryBloc(_genshinService, _dataService, _telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.updateMaterial(key: _moraKey, quantity: 900))
        ..add(const InventoryEvent.updateMaterial(key: _moraKey, quantity: 0))
        ..add(const InventoryEvent.init()),
      //here I skip only 1 cause the init event does not make an state change
      skip: 1,
      expect: () {
        final materials = _dataService.inventory.getAllMaterialsInInventory();
        final material = materials.firstWhere((el) => el.key == _moraKey);
        expect(material.quantity, 0);
        return [
          InventoryState.loaded(
            characters: [],
            weapons: [],
            materials: materials,
          )
        ];
      },
    );
  });

  group('Clear', () {
    blocTest<InventoryBloc, InventoryState>(
      'characters',
      setUp: () async {
        await _dataService.deleteThemAll();
      },
      build: () => InventoryBloc(_genshinService, _dataService, _telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.init())
        ..add(const InventoryEvent.addCharacter(key: _keqingKey))
        ..add(const InventoryEvent.clearAllCharacters()),
      skip: 2,
      expect: () {
        final materials = _dataService.inventory.getAllMaterialsInInventory();
        return [
          InventoryState.loaded(
            characters: [],
            weapons: [],
            materials: materials,
          )
        ];
      },
    );

    blocTest<InventoryBloc, InventoryState>(
      'weapon = $_aquilaFavoniaKey',
      setUp: () async {
        await _dataService.deleteThemAll();
      },
      build: () => InventoryBloc(_genshinService, _dataService, _telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.init())
        ..add(const InventoryEvent.addWeapon(key: _aquilaFavoniaKey))
        ..add(const InventoryEvent.clearAllWeapons()),
      skip: 2,
      expect: () {
        final materials = _dataService.inventory.getAllMaterialsInInventory();
        return [
          InventoryState.loaded(
            characters: [],
            weapons: [],
            materials: materials,
          )
        ];
      },
    );

    blocTest<InventoryBloc, InventoryState>(
      'material',
      setUp: () async {
        await _dataService.deleteThemAll();
      },
      build: () => InventoryBloc(_genshinService, _dataService, _telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.init())
        ..add(const InventoryEvent.updateMaterial(key: _moraKey, quantity: 900))
        ..add(const InventoryEvent.clearAllMaterials()),
      skip: 2,
      expect: () {
        final materials = _dataService.inventory.getAllMaterialsInInventory();
        expect(materials.every((el) => el.quantity == 0), isTrue);
        return [
          InventoryState.loaded(
            characters: [],
            weapons: [],
            materials: materials,
          )
        ];
      },
    );
  });
}
