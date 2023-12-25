import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_asc_materials_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const String _baseDbFolder = 'shiori_inventory_data_service';

void main() {
  late final ResourceService resourceService;
  late final GenshinService genshinService;
  late final CalculatorAscMaterialsService calculatorService;

  const String charKey = 'keqing';
  const String weaponKey = 'aquila-favonia';
  const String artifactKey = 'thundering-fury';
  const String materialKey = 'mora';

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

  String getItemKey(ItemType type) {
    return switch (type) {
      ItemType.character => charKey,
      ItemType.weapon => weaponKey,
      ItemType.artifact => artifactKey,
      ItemType.material => materialKey,
    };
  }

  group('Add character to inventory', () {
    const dbFolder = '${_baseDbFolder}_add_character_to_inventory_tests';
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

    test('invalid item key', () {
      expect(dataService.inventory.addCharacterToInventory(''), throwsArgumentError);
    });

    test('which does not exist in inventory', () async {
      await dataService.inventory.addCharacterToInventory(charKey);
      final int count = dataService.inventory.getItemQuantityFromInventory(charKey, ItemType.character);
      expect(count, 1);
    });

    test('which exists in inventory', () async {
      await dataService.inventory.addCharacterToInventory(charKey);
      await dataService.inventory.addCharacterToInventory(charKey);
      final int count = dataService.inventory.getItemQuantityFromInventory(charKey, ItemType.character);
      expect(count, 1);
    });
  });

  group('Delete character from inventory', () {
    const dbFolder = '${_baseDbFolder}_delete_character_from_inventory_tests';
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

    test('invalid item key', () {
      expect(dataService.inventory.deleteCharacterFromInventory(''), throwsArgumentError);
    });

    test('which does not exist in inventory', () async {
      await dataService.inventory.deleteCharacterFromInventory(charKey);
      final bool exists = dataService.inventory.isItemInInventory(charKey, ItemType.character);
      expect(exists, isFalse);
    });

    test('which exists in inventory', () async {
      await dataService.inventory.addCharacterToInventory(charKey);
      await dataService.inventory.deleteCharacterFromInventory(charKey);
      final bool exists = dataService.inventory.isItemInInventory(charKey, ItemType.character);
      expect(exists, isFalse);
    });
  });

  group('Add weapon to inventory', () {
    const dbFolder = '${_baseDbFolder}_add_weapon_to_inventory_tests';
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

    test('invalid item key', () {
      expect(dataService.inventory.addWeaponToInventory(''), throwsArgumentError);
    });

    test('which does not exist in inventory', () async {
      await dataService.inventory.addWeaponToInventory(weaponKey);
      final int count = dataService.inventory.getItemQuantityFromInventory(weaponKey, ItemType.weapon);
      expect(count, 1);
    });

    test('which exists in inventory', () async {
      await dataService.inventory.addWeaponToInventory(weaponKey);
      await dataService.inventory.addWeaponToInventory(weaponKey);
      final int count = dataService.inventory.getItemQuantityFromInventory(weaponKey, ItemType.weapon);
      expect(count, 1);
    });
  });

  group('Delete weapon from inventory', () {
    const dbFolder = '${_baseDbFolder}_delete_weapon_from_inventory_tests';
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

    test('invalid item key', () {
      expect(dataService.inventory.deleteWeaponFromInventory(''), throwsArgumentError);
    });

    test('which does not exist in inventory', () async {
      await dataService.inventory.deleteWeaponFromInventory(weaponKey);
      final bool exists = dataService.inventory.isItemInInventory(weaponKey, ItemType.weapon);
      expect(exists, isFalse);
    });

    test('which exists in inventory', () async {
      await dataService.inventory.addCharacterToInventory(weaponKey);
      await dataService.inventory.deleteWeaponFromInventory(weaponKey);
      final bool exists = dataService.inventory.isItemInInventory(weaponKey, ItemType.weapon);
      expect(exists, isFalse);
    });
  });

  group('Delete items from inventory', () {
    const dbFolder = '${_baseDbFolder}_delete_items_from_inventory_tests';
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

    for (final type in ItemType.values) {
      test('of type ${type.name}', () async {
        final int quantity = type == ItemType.material ? 666 : 1;
        final String key = getItemKey(type);

        switch (type) {
          case ItemType.material:
            await dataService.inventory.addMaterialToInventory(key, quantity);
          case ItemType.character:
            await dataService.inventory.addCharacterToInventory(key);
          case ItemType.weapon:
            await dataService.inventory.addWeaponToInventory(key);
          case ItemType.artifact:
            return;
        }

        int count = dataService.inventory.getItemQuantityFromInventory(key, type);
        expect(count, quantity);

        dataService.inventory.deleteItemsFromInventory(type);
        count = dataService.inventory.getItemQuantityFromInventory(key, type);
        expect(count, isZero);
      });
    }
  });

  group('Delete all used material items', () {
    const dbFolder = '${_baseDbFolder}_delete_all_used_material_items_tests';
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
      expect(dataService.inventory.deleteAllUsedMaterialItems(), completes);
    });

    test('data exists', () async {
      await dataService.inventory.addMaterialToInventory(materialKey, 999);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, 666);
      int used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, 666);

      await dataService.inventory.deleteAllUsedMaterialItems();
      used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, isZero);
    });
  });

  group('Delete all used inventory items', () {
    const dbFolder = '${_baseDbFolder}_delete_all_used_inventory_items_tests';
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
      expect(dataService.inventory.deleteAllUsedInventoryItems(), completes);
    });

    test('data exists', () async {
      await dataService.inventory.addMaterialToInventory(materialKey, 999);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, 666);
      int used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, 666);

      await dataService.inventory.deleteAllUsedInventoryItems();
      used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, isZero);
    });
  });

  group('Get all characters in inventory', () {
    const dbFolder = '${_baseDbFolder}_get_all_characters_in_inventory_tests';
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
      final chars = dataService.inventory.getAllCharactersInInventory();
      expect(chars.isEmpty, isTrue);
    });

    test('data exists', () async {
      await dataService.inventory.addCharacterToInventory(charKey);
      final chars = dataService.inventory.getAllCharactersInInventory();
      expect(chars.length, 1);

      final char = chars.first;
      expect(char.key, charKey);
    });
  });

  group('Get all materials in inventory', () {
    const dbFolder = '${_baseDbFolder}_get_all_materials_in_inventory_tests';
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
      final data = dataService.inventory.getAllMaterialsInInventory();
      expect(data.isNotEmpty, isTrue);
      expect(data.every((el) => el.quantity == 0 && el.usedQuantity == 0), isTrue);
    });

    test('data exists', () async {
      const int quantity = 666;
      const int used = quantity ~/ 2;
      await dataService.inventory.addMaterialToInventory(materialKey, quantity);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, used);
      final data = dataService.inventory.getAllMaterialsInInventory();
      expect(data.isNotEmpty, isTrue);
      expect(data.where((el) => el.key != materialKey).every((el) => el.quantity == 0 && el.usedQuantity == 0), isTrue);

      final material = data.firstWhere((el) => el.key == materialKey);
      expect(material.quantity, quantity);
      expect(material.usedQuantity, used);
    });
  });

  group('Get all weapons in inventory', () {
    const dbFolder = '${_baseDbFolder}_get_all_weapons_in_inventory_tests';
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
      final weapons = dataService.inventory.getAllWeaponsInInventory();
      expect(weapons.isEmpty, isTrue);
    });

    test('data exists', () async {
      await dataService.inventory.addWeaponToInventory(weaponKey);
      final weapons = dataService.inventory.getAllWeaponsInInventory();
      expect(weapons.length, 1);

      final weapon = weapons.first;
      expect(weapon.key, weaponKey);
    });
  });

  group('Get item quantity from inventory', () {
    const dbFolder = '${_baseDbFolder}_get_item_quantity_from_inventory_tests';
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
      expect(() => dataService.inventory.getItemQuantityFromInventory('', ItemType.material), throwsArgumentError);
    });

    test('item does not exist', () {
      final int quantity = dataService.inventory.getItemQuantityFromInventory(materialKey, ItemType.material);
      expect(quantity, isZero);
    });

    test('item exists', () async {
      const int expected = 666;
      await dataService.inventory.addMaterialToInventory(materialKey, expected);
      final int quantity = dataService.inventory.getItemQuantityFromInventory(materialKey, ItemType.material);
      expect(quantity, expected);
    });
  });

  group('Add material to inventory', () {
    const dbFolder = '${_baseDbFolder}_add_material_to_inventory_tests';
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
      expect(dataService.inventory.addMaterialToInventory('', 666), throwsArgumentError);
    });

    test('item quantity is not valid', () {
      expect(dataService.inventory.addMaterialToInventory(materialKey, -1), throwsArgumentError);
    });

    test('item does not exist thus it gets added', () async {
      int count = dataService.inventory.getItemQuantityFromInventory(materialKey, ItemType.material);
      expect(count, isZero);

      await dataService.inventory.addMaterialToInventory(materialKey, 666);
      count = dataService.inventory.getItemQuantityFromInventory(materialKey, ItemType.material);
      expect(count, 666);
    });

    test('item already exists thus it gets updated', () async {
      await dataService.inventory.addMaterialToInventory(materialKey, 666);
      int count = dataService.inventory.getItemQuantityFromInventory(materialKey, ItemType.material);
      expect(count, 666);

      await dataService.inventory.addMaterialToInventory(materialKey, 333);
      count = dataService.inventory.getItemQuantityFromInventory(materialKey, ItemType.material);
      expect(count, 333);
    });
  });

  group('Is item in inventory', () {
    const dbFolder = '${_baseDbFolder}_is_item_in_inventory_tests';
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

    for (final type in ItemType.values) {
      test('item key is not valid for type = ${type.name}', () {
        expect(() => dataService.inventory.isItemInInventory('', type), throwsArgumentError);
      });

      test('no data exist for type = ${type.name}', () {
        final String key = getItemKey(type);
        final bool exist = dataService.inventory.isItemInInventory(key, type);
        expect(exist, isFalse);
      });

      test('data exist for type = ${type.name}', () async {
        final String key = getItemKey(type);
        switch (type) {
          case ItemType.material:
            await dataService.inventory.addMaterialToInventory(key, 666);
          case ItemType.character:
            await dataService.inventory.addCharacterToInventory(key);
          case ItemType.weapon:
            await dataService.inventory.addWeaponToInventory(key);
          case ItemType.artifact:
            return;
        }
        final bool exist = dataService.inventory.isItemInInventory(key, type);
        expect(exist, isTrue);
      });
    }
  });

  group('Get used material quantity', () {
    const dbFolder = '${_baseDbFolder}_get_number_of_items_used_tests';
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
      expect(() => dataService.inventory.getUsedMaterialQuantity(''), throwsArgumentError);
    });

    test('no data exist', () {
      final int count = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(count, isZero);
    });

    test('data exists', () async {
      const calcId = 1;
      const int quantity = 666;
      const expected = quantity ~/ 2;
      await dataService.inventory.addMaterialToInventory(materialKey, quantity);
      await dataService.inventory.useMaterialFromInventory(calcId, materialKey, expected);
      final int used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, expected);
    });
  });

  group('Redistribute material', () {
    const dbFolder = '${_baseDbFolder}_redistribute_material_tests';
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

    test('calc key is not valid', () {
      expect(() => dataService.inventory.redistributeMaterial(-1, [], materialKey, 0), throwsArgumentError);
    });

    test('item key is not valid', () {
      expect(() => dataService.inventory.redistributeMaterial(1, [], '', 0), throwsArgumentError);
    });

    test('current quantity is not valid', () {
      expect(() => dataService.inventory.redistributeMaterial(1, [], materialKey, -1), throwsArgumentError);
    });

    test('not being used and provided materials array is empty', () async {
      const int available = 666;
      final int remaining = await dataService.inventory.redistributeMaterial(1, [], materialKey, available);
      expect(remaining, available);

      final used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, isZero);
    });

    test('not being used and required quantity is less than available', () async {
      const int available = 666;
      const int required = 110;
      final material = genshinService.materials.getMaterial(materialKey);
      final materials = [ItemAscensionMaterialModel.fromMaterial(required, material, '')];
      final int remaining = await dataService.inventory.redistributeMaterial(1, materials, materialKey, available);
      expect(remaining, available - required);

      final used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, required);
    });

    test('not being used and required quantity equals available', () async {
      const int available = 666;
      final material = genshinService.materials.getMaterial(materialKey);
      final materials = [ItemAscensionMaterialModel.fromMaterial(available, material, '')];
      final int remaining = await dataService.inventory.redistributeMaterial(1, materials, materialKey, available);
      expect(remaining, isZero);

      final used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, available);
    });

    test('not being used and required quantity is greater than available', () async {
      const int available = 666;
      final material = genshinService.materials.getMaterial(materialKey);
      final materials = [ItemAscensionMaterialModel.fromMaterial(available * 2, material, '')];
      final int remaining = await dataService.inventory.redistributeMaterial(1, materials, materialKey, available);
      expect(remaining, isZero);

      final used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, available);
    });

    test('being used and provided materials array is empty', () async {
      const int calcId = 1;
      const int available = 666;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(calcId, materialKey, 10);
      final int remaining = await dataService.inventory.redistributeMaterial(calcId, [], materialKey, available);
      expect(remaining, available);

      final updatedUsed = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(updatedUsed, isZero);
    });

    test('being used and required quantity is less than available', () async {
      const int calcId = 1;
      const int available = 666;
      const int required = 102;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(calcId, materialKey, required);

      final material = genshinService.materials.getMaterial(materialKey);
      final materials = [ItemAscensionMaterialModel.fromMaterial(required, material, '')];
      final int remaining = await dataService.inventory.redistributeMaterial(calcId, materials, materialKey, available);
      expect(remaining, available - required);

      final updatedUsed = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(updatedUsed, required);
    });

    test('being used and required quantity equals available', () async {
      const int calcId = 1;
      const int available = 666;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(calcId, materialKey, available);

      final material = genshinService.materials.getMaterial(materialKey);
      final materials = [ItemAscensionMaterialModel.fromMaterial(available, material, '')];
      final int remaining = await dataService.inventory.redistributeMaterial(calcId, materials, materialKey, available);
      expect(remaining, isZero);

      final updatedUsed = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(updatedUsed, available);
    });

    test('not being used and required quantity is greater than available', () async {
      const int calcId = 1;
      const int available = 666;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(calcId, materialKey, available);

      final material = genshinService.materials.getMaterial(materialKey);
      final materials = [ItemAscensionMaterialModel.fromMaterial(available * 2, material, '')];
      final int remaining = await dataService.inventory.redistributeMaterial(calcId, materials, materialKey, available);
      expect(remaining, isZero);

      final updatedUsed = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(updatedUsed, available);
    });
  });

  group('Use material from inventory', () {
    const dbFolder = '${_baseDbFolder}_use_material_from_inventory_tests';
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

    test('calc key is not valid', () {
      expect(dataService.inventory.useMaterialFromInventory(-1, materialKey, 666), throwsArgumentError);
    });

    test('item key is not valid', () {
      expect(dataService.inventory.useMaterialFromInventory(1, '', 666), throwsArgumentError);
    });

    test('quantity is not valid', () {
      expect(dataService.inventory.useMaterialFromInventory(1, materialKey, -1), throwsArgumentError);
    });

    test('item is not in inventory', () async {
      await dataService.inventory.useMaterialFromInventory(1, materialKey, 666);
      final int used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, isZero);
    });

    test('quantity to use is zero', () async {
      const int available = 666;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, 0);
      final int used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, isZero);
    });

    test('quantity to use is greater than available', () async {
      const int available = 666;
      const int required = available * 2;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, required);
      final int used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, available);
    });

    test('quantity to use is less than available', () async {
      const int available = 666;
      const int required = available ~/ 2;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, required);
      final int used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, required);
    });

    test('quantity to use equals available', () async {
      const int available = 666;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, available);
      final int used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, available);
    });
  });

  group('Clear used inventory items', () {
    const dbFolder = '${_baseDbFolder}_clear_used_inventory_items_tests';
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

    test('calc key is not valid', () {
      expect(dataService.inventory.clearUsedInventoryItems(-1), throwsArgumentError);
    });

    test('data does not exist', () {
      expect(dataService.inventory.clearUsedInventoryItems(1), completes);
    });

    test('data exists and no item key is provided', () async {
      await dataService.inventory.addMaterialToInventory(materialKey, 666);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, 10);
      await dataService.inventory.useMaterialFromInventory(2, materialKey, 5);
      await dataService.inventory.clearUsedInventoryItems(1);

      final int usedA = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(1, materialKey);
      expect(usedA, isZero);

      final int usedB = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(2, materialKey);
      expect(usedB, 5);
    });

    test('data exists and item key is provided', () async {
      const String primogem = 'primogem';
      await dataService.inventory.addMaterialToInventory(materialKey, 666);
      await dataService.inventory.addMaterialToInventory(primogem, 666);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, 10);
      await dataService.inventory.useMaterialFromInventory(1, primogem, 10);
      await dataService.inventory.clearUsedInventoryItems(1, onlyItemKey: materialKey);

      int used = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(1, materialKey);
      expect(used, isZero);

      used = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(1, primogem);
      expect(used, 10);
    });
  });

  group('Get used material quantity by calc key and item key', () {
    const dbFolder = '${_baseDbFolder}_get_used_material_quantity_by_calckey_and_itemkey_tests';
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

    test('calc key is not valid', () {
      expect(() => dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(-1, materialKey), throwsArgumentError);
    });

    test('item key is not valid', () {
      expect(() => dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(1, ''), throwsArgumentError);
    });

    test('no data exist', () {
      final int count = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(1, materialKey);
      expect(count, isZero);
    });

    test('data exists', () async {
      const int calcKey = 1;
      const int available = 666;
      const int used = available ~/ 2;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(calcKey, materialKey, used);
      final int count = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(calcKey, materialKey);
      expect(count, used);
    });
  });

  group('Get items for redistribution', () {
    const dbFolder = '${_baseDbFolder}_get_items_for_redistribution_tests';
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

    for (final type in ItemType.values) {
      test('of type ${type.name} when no data exist', () {
        final items = dataService.inventory.getItemsForRedistribution(type);
        expect(items.isEmpty, isTrue);
      });

      test('of type ${type.name} when data exists', () async {
        final String itemKey = getItemKey(type);
        switch (type) {
          case ItemType.character:
            await dataService.inventory.addCharacterToInventory(itemKey);
          case ItemType.weapon:
            await dataService.inventory.addWeaponToInventory(itemKey);
          case ItemType.material:
            await dataService.inventory.addMaterialToInventory(itemKey, 666);
          case ItemType.artifact:
            return;
        }
        final items = dataService.inventory.getItemsForRedistribution(type);
        expect(items.length, 1);

        final item = items.first;
        expect(item.key, itemKey);
        expect(item.quantity, type == ItemType.material ? 666 : 1);
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

    test('no data exist', () {
      final bk = dataService.inventory.getDataForBackup();
      expect(bk, isEmpty);
    });

    test('data exists', () async {
      await dataService.inventory.addCharacterToInventory(charKey);
      await dataService.inventory.addWeaponToInventory(weaponKey);
      await dataService.inventory.addMaterialToInventory(materialKey, 666);

      final bk = dataService.inventory.getDataForBackup();
      expect(bk.length, 3);

      const expected = <String, ItemType>{
        charKey: ItemType.character,
        weaponKey: ItemType.weapon,
        materialKey: ItemType.material,
      };
      for (int i = 0; i < bk.length; i++) {
        final kvp = expected.entries.elementAt(i);
        final bkItem = bk[i];

        expect(bkItem.itemKey, kvp.key);
        expect(bkItem.quantity, kvp.value == ItemType.material ? 666 : 1);
        expect(bkItem.type, kvp.value.index);
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
      await dataService.inventory.restoreFromBackup([]);
      final count = dataService.inventory.getDataForBackup().length;
      expect(count, isZero);
    });

    test('no data to restore and previous data exist', () async {
      await dataService.inventory.addCharacterToInventory(charKey);
      await dataService.inventory.restoreFromBackup([]);
      final count = dataService.inventory.getDataForBackup().length;
      expect(count, isZero);
    });

    test('there is data to restore and previous data exist', () async {
      await dataService.inventory.addCharacterToInventory(charKey);
      final bk = [
        BackupInventoryModel(itemKey: charKey, type: ItemType.character.index, quantity: 1),
        BackupInventoryModel(itemKey: weaponKey, type: ItemType.weapon.index, quantity: 1),
        BackupInventoryModel(itemKey: materialKey, type: ItemType.material.index, quantity: 666),
        BackupInventoryModel(itemKey: 'primogem', type: ItemType.material.index, quantity: 10),
      ];
      await dataService.inventory.restoreFromBackup(bk);

      final count = dataService.inventory.getDataForBackup().length;
      expect(count, bk.length);
      for (final bkItem in bk) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(bkItem.itemKey, ItemType.values[bkItem.type]);
        expect(quantity, bkItem.quantity);
      }
    });
  });

  group('Get used material keys by calc key', () {
    const dbFolder = '${_baseDbFolder}_get_used_material_keys_by_calc_key_tests';
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

    test('calc key is not valid', () {
      expect(() => dataService.inventory.getUsedMaterialKeysByCalcKey(-1), throwsArgumentError);
    });

    test('no data exist', () {
      final List<String> keys = dataService.inventory.getUsedMaterialKeysByCalcKey(666);
      expect(keys.isEmpty, isTrue);
    });

    test('data exists', () async {
      const int calcId = 1;
      const expected = <String, int>{materialKey: 666, 'primogem': 100};

      for (final kvp in expected.entries) {
        await dataService.inventory.addMaterialToInventory(kvp.key, kvp.value);
        await dataService.inventory.useMaterialFromInventory(calcId, kvp.key, kvp.value);
      }

      final List<String> keys = dataService.inventory.getUsedMaterialKeysByCalcKey(calcId);
      expect(keys.length, expected.length);
      expect(keys, expected.keys.toList());
    });
  });
}
