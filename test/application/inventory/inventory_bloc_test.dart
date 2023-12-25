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
  late final TelemetryService telemetryService;
  late final SettingsService settingsService;
  late final LocaleService localeService;
  late final GenshinService genshinService;
  late final DataService dataService;
  late final String dbPath;

  const keqingKey = 'keqing';
  const aquilaFavoniaKey = 'aquila-favonia';
  const moraKey = 'mora';

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    telemetryService = MockTelemetryService();
    settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    localeService = LocaleServiceImpl(settingsService);

    final resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);
    dataService = DataServiceImpl(genshinService, CalculatorAscMaterialsServiceImpl(genshinService, resourceService), resourceService);
    return Future(() async {
      await genshinService.init(settingsService.language);
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
      InventoryBloc(genshinService, dataService, telemetryService).state,
      const InventoryState.loaded(characters: [], weapons: [], materials: []),
    ),
  );

  blocTest<InventoryBloc, InventoryState>(
    'On init I should have 1 character, 1 weapon and 20k of mora',
    setUp: () async {
      await dataService.deleteThemAll();
    },
    build: () => InventoryBloc(genshinService, dataService, telemetryService),
    act: (bloc) => bloc
      ..add(const InventoryEvent.addCharacter(key: keqingKey))
      ..add(const InventoryEvent.addWeapon(key: aquilaFavoniaKey))
      ..add(const InventoryEvent.updateMaterial(key: moraKey, quantity: 20000))
      ..add(const InventoryEvent.init()),
    //here I skip only 2 cause the init event does not make an state change
    skip: 2,
    expect: () {
      final character = genshinService.characters.getCharacterForCard(keqingKey);
      final weapon = genshinService.weapons.getWeaponForCard(aquilaFavoniaKey);
      final materials = dataService.inventory.getAllMaterialsInInventory();
      final material = materials.firstWhere((el) => el.key == moraKey);
      expect(material.quantity, 20000);
      return [
        InventoryState.loaded(
          characters: [character],
          weapons: [weapon],
          materials: materials,
        ),
      ];
    },
  );

  group('Add', () {
    blocTest<InventoryBloc, InventoryState>(
      'character = $keqingKey',
      setUp: () async {
        await dataService.deleteThemAll();
      },
      build: () => InventoryBloc(genshinService, dataService, telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.init())
        ..add(const InventoryEvent.addCharacter(key: keqingKey)),
      skip: 1,
      expect: () {
        final character = genshinService.characters.getCharacterForCard(keqingKey);
        final materials = dataService.inventory.getAllMaterialsInInventory();
        return [
          InventoryState.loaded(
            characters: [character],
            weapons: [],
            materials: materials,
          ),
        ];
      },
    );

    blocTest<InventoryBloc, InventoryState>(
      'weapon = $aquilaFavoniaKey',
      setUp: () async {
        await dataService.deleteThemAll();
      },
      build: () => InventoryBloc(genshinService, dataService, telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.init())
        ..add(const InventoryEvent.addWeapon(key: aquilaFavoniaKey)),
      skip: 1,
      expect: () {
        final weapon = genshinService.weapons.getWeaponForCard(aquilaFavoniaKey);
        final materials = dataService.inventory.getAllMaterialsInInventory();
        return [
          InventoryState.loaded(
            characters: [],
            weapons: [weapon],
            materials: materials,
          ),
        ];
      },
    );

    blocTest<InventoryBloc, InventoryState>(
      'material = $moraKey',
      setUp: () async {
        await dataService.deleteThemAll();
      },
      build: () => InventoryBloc(genshinService, dataService, telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.init())
        ..add(const InventoryEvent.updateMaterial(key: moraKey, quantity: 100000)),
      skip: 1,
      expect: () {
        final materials = dataService.inventory.getAllMaterialsInInventory();
        final material = materials.firstWhere((el) => el.key == moraKey);
        expect(material.quantity, 100000);
        return [
          InventoryState.loaded(
            characters: [],
            weapons: [],
            materials: materials,
          ),
        ];
      },
    );
  });

  group('Delete', () {
    blocTest<InventoryBloc, InventoryState>(
      'character = $keqingKey',
      setUp: () async {
        await dataService.deleteThemAll();
      },
      build: () => InventoryBloc(genshinService, dataService, telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.addCharacter(key: keqingKey))
        ..add(const InventoryEvent.deleteCharacter(key: keqingKey))
        ..add(const InventoryEvent.init()),
      //here I skip only 2 cause the init event does not make an state change
      skip: 2,
      expect: () {
        final materials = dataService.inventory.getAllMaterialsInInventory();
        return [
          InventoryState.loaded(
            characters: [],
            weapons: [],
            materials: materials,
          ),
        ];
      },
    );

    blocTest<InventoryBloc, InventoryState>(
      'weapon = $aquilaFavoniaKey',
      setUp: () async {
        await dataService.deleteThemAll();
      },
      build: () => InventoryBloc(genshinService, dataService, telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.addWeapon(key: aquilaFavoniaKey))
        ..add(const InventoryEvent.deleteWeapon(key: aquilaFavoniaKey))
        ..add(const InventoryEvent.init()),
      //here I skip only 2 cause the init event does not make an state change
      skip: 2,
      expect: () {
        final materials = dataService.inventory.getAllMaterialsInInventory();
        return [
          InventoryState.loaded(
            characters: [],
            weapons: [],
            materials: materials,
          ),
        ];
      },
    );

    blocTest<InventoryBloc, InventoryState>(
      'material = $moraKey',
      setUp: () async {
        await dataService.deleteThemAll();
      },
      build: () => InventoryBloc(genshinService, dataService, telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.updateMaterial(key: moraKey, quantity: 900))
        ..add(const InventoryEvent.updateMaterial(key: moraKey, quantity: 0))
        ..add(const InventoryEvent.init()),
      //here I skip only 1 cause the init event does not make an state change
      skip: 1,
      expect: () {
        final materials = dataService.inventory.getAllMaterialsInInventory();
        final material = materials.firstWhere((el) => el.key == moraKey);
        expect(material.quantity, 0);
        return [
          InventoryState.loaded(
            characters: [],
            weapons: [],
            materials: materials,
          ),
        ];
      },
    );
  });

  group('Clear', () {
    blocTest<InventoryBloc, InventoryState>(
      'characters',
      setUp: () async {
        await dataService.deleteThemAll();
      },
      build: () => InventoryBloc(genshinService, dataService, telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.init())
        ..add(const InventoryEvent.addCharacter(key: keqingKey))
        ..add(const InventoryEvent.clearAllCharacters()),
      skip: 2,
      expect: () {
        final materials = dataService.inventory.getAllMaterialsInInventory();
        return [
          InventoryState.loaded(
            characters: [],
            weapons: [],
            materials: materials,
          ),
        ];
      },
    );

    blocTest<InventoryBloc, InventoryState>(
      'weapon = $aquilaFavoniaKey',
      setUp: () async {
        await dataService.deleteThemAll();
      },
      build: () => InventoryBloc(genshinService, dataService, telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.init())
        ..add(const InventoryEvent.addWeapon(key: aquilaFavoniaKey))
        ..add(const InventoryEvent.clearAllWeapons()),
      skip: 2,
      expect: () {
        final materials = dataService.inventory.getAllMaterialsInInventory();
        return [
          InventoryState.loaded(
            characters: [],
            weapons: [],
            materials: materials,
          ),
        ];
      },
    );

    blocTest<InventoryBloc, InventoryState>(
      'material',
      setUp: () async {
        await dataService.deleteThemAll();
      },
      build: () => InventoryBloc(genshinService, dataService, telemetryService),
      act: (bloc) => bloc
        ..add(const InventoryEvent.init())
        ..add(const InventoryEvent.updateMaterial(key: moraKey, quantity: 900))
        ..add(const InventoryEvent.clearAllMaterials()),
      skip: 2,
      expect: () {
        final materials = dataService.inventory.getAllMaterialsInInventory();
        expect(materials.every((el) => el.quantity == 0), isTrue);
        return [
          InventoryState.loaded(
            characters: [],
            weapons: [],
            materials: materials,
          ),
        ];
      },
    );
  });
}
