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
      expect(
        dataService.inventory.addCharacterToInventory(''),
        throwsArgumentError,
        reason: 'Adding a character with an empty key must throw ArgumentError',
      );
    });

    test('which does not exist in inventory', () async {
      await dataService.inventory.addCharacterToInventory(charKey);
      final int count = dataService.inventory.getItemQuantityFromInventory(charKey, ItemType.character);
      expect(count, 1, reason: 'After adding character (key=$charKey) once, inventory quantity should be 1');
    });

    test('which exists in inventory', () async {
      await dataService.inventory.addCharacterToInventory(charKey);
      await dataService.inventory.addCharacterToInventory(charKey);
      final int count = dataService.inventory.getItemQuantityFromInventory(charKey, ItemType.character);
      expect(count, 1, reason: 'Adding character (key=$charKey) twice must not duplicate; quantity should stay 1');
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
      expect(
        dataService.inventory.deleteCharacterFromInventory(''),
        throwsArgumentError,
        reason: 'Deleting a character with an empty key must throw ArgumentError',
      );
    });

    test('which does not exist in inventory', () async {
      await dataService.inventory.deleteCharacterFromInventory(charKey);
      final bool exists = dataService.inventory.isItemInInventory(charKey, ItemType.character);
      expect(exists, isFalse, reason: 'Deleting an absent character (key=$charKey) should leave it not in inventory');
    });

    test('which exists in inventory', () async {
      await dataService.inventory.addCharacterToInventory(charKey);
      await dataService.inventory.deleteCharacterFromInventory(charKey);
      final bool exists = dataService.inventory.isItemInInventory(charKey, ItemType.character);
      expect(exists, isFalse, reason: 'After deleting character (key=$charKey), it should no longer be in inventory');
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
      expect(
        dataService.inventory.addWeaponToInventory(''),
        throwsArgumentError,
        reason: 'Adding a weapon with an empty key must throw ArgumentError',
      );
    });

    test('which does not exist in inventory', () async {
      await dataService.inventory.addWeaponToInventory(weaponKey);
      final int count = dataService.inventory.getItemQuantityFromInventory(weaponKey, ItemType.weapon);
      expect(count, 1, reason: 'After adding weapon (key=$weaponKey) once, inventory quantity should be 1');
    });

    test('which exists in inventory', () async {
      await dataService.inventory.addWeaponToInventory(weaponKey);
      await dataService.inventory.addWeaponToInventory(weaponKey);
      final int count = dataService.inventory.getItemQuantityFromInventory(weaponKey, ItemType.weapon);
      expect(count, 1, reason: 'Adding weapon (key=$weaponKey) twice must not duplicate; quantity should stay 1');
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
      expect(
        dataService.inventory.deleteWeaponFromInventory(''),
        throwsArgumentError,
        reason: 'Deleting a weapon with an empty key must throw ArgumentError',
      );
    });

    test('which does not exist in inventory', () async {
      await dataService.inventory.deleteWeaponFromInventory(weaponKey);
      final bool exists = dataService.inventory.isItemInInventory(weaponKey, ItemType.weapon);
      expect(exists, isFalse, reason: 'Deleting an absent weapon (key=$weaponKey) should leave it not in inventory');
    });

    test('which exists in inventory', () async {
      await dataService.inventory.addCharacterToInventory(weaponKey);
      await dataService.inventory.deleteWeaponFromInventory(weaponKey);
      final bool exists = dataService.inventory.isItemInInventory(weaponKey, ItemType.weapon);
      expect(exists, isFalse, reason: 'After deleting weapon (key=$weaponKey), it should no longer be in inventory');
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
        expect(count, quantity, reason: 'After adding ${type.name} (key=$key), quantity should be $quantity');

        dataService.inventory.deleteItemsFromInventory(type);
        count = dataService.inventory.getItemQuantityFromInventory(key, type);
        expect(
          count,
          isZero,
          reason: 'After deleteItemsFromInventory(${type.name}), quantity for key=$key should be 0',
        );
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
      expect(
        dataService.inventory.deleteAllUsedMaterialItems(),
        completes,
        reason: 'deleteAllUsedMaterialItems() with no data should complete without error',
      );
    });

    test('data exists', () async {
      await dataService.inventory.addMaterialToInventory(materialKey, 999);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, 666);
      int used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, 666, reason: 'After using 666 of material (key=$materialKey), used quantity should be 666');

      await dataService.inventory.deleteAllUsedMaterialItems();
      used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(
        used,
        isZero,
        reason: 'After deleteAllUsedMaterialItems(), used quantity for material (key=$materialKey) should be 0',
      );
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
      expect(
        dataService.inventory.deleteAllUsedInventoryItems(),
        completes,
        reason: 'deleteAllUsedInventoryItems() with no data should complete without error',
      );
    });

    test('data exists', () async {
      await dataService.inventory.addMaterialToInventory(materialKey, 999);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, 666);
      int used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, 666, reason: 'After using 666 of material (key=$materialKey), used quantity should be 666');

      await dataService.inventory.deleteAllUsedInventoryItems();
      used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(
        used,
        isZero,
        reason: 'After deleteAllUsedInventoryItems(), used quantity for material (key=$materialKey) should be 0',
      );
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
      expect(chars.isEmpty, isTrue, reason: 'With no data, getAllCharactersInInventory() should return an empty list');
    });

    test('data exists', () async {
      await dataService.inventory.addCharacterToInventory(charKey);
      final chars = dataService.inventory.getAllCharactersInInventory();
      expect(
        chars.length,
        1,
        reason: 'After adding character (key=$charKey), inventory should contain exactly 1 character',
      );

      final char = chars.first;
      expect(char.key, charKey, reason: 'Stored character key should be $charKey');
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
      expect(
        data.isNotEmpty,
        isTrue,
        reason: 'getAllMaterialsInInventory() should always return the full material catalog, not empty',
      );
      expect(
        data.every((el) => el.quantity == 0 && el.usedQuantity == 0),
        isTrue,
        reason: 'With no data added, every material should have quantity 0 and usedQuantity 0',
      );
    });

    test('data exists', () async {
      const int quantity = 666;
      const int used = quantity ~/ 2;
      await dataService.inventory.addMaterialToInventory(materialKey, quantity);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, used);
      final data = dataService.inventory.getAllMaterialsInInventory();
      expect(
        data.isNotEmpty,
        isTrue,
        reason: 'getAllMaterialsInInventory() should always return the full material catalog, not empty',
      );
      expect(
        data.where((el) => el.key != materialKey).every((el) => el.quantity == 0 && el.usedQuantity == 0),
        isTrue,
        reason: 'Materials other than key=$materialKey should remain at quantity 0 and usedQuantity 0',
      );

      final material = data.firstWhere((el) => el.key == materialKey);
      expect(material.quantity, quantity, reason: 'Stored material (key=$materialKey) quantity should be $quantity');
      expect(material.usedQuantity, used, reason: 'Stored material (key=$materialKey) usedQuantity should be $used');
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
      expect(weapons.isEmpty, isTrue, reason: 'With no data, getAllWeaponsInInventory() should return an empty list');
    });

    test('data exists', () async {
      await dataService.inventory.addWeaponToInventory(weaponKey);
      final weapons = dataService.inventory.getAllWeaponsInInventory();
      expect(
        weapons.length,
        1,
        reason: 'After adding weapon (key=$weaponKey), inventory should contain exactly 1 weapon',
      );

      final weapon = weapons.first;
      expect(weapon.key, weaponKey, reason: 'Stored weapon key should be $weaponKey');
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
      expect(
        () => dataService.inventory.getItemQuantityFromInventory('', ItemType.material),
        throwsArgumentError,
        reason: 'Querying quantity with an empty key must throw ArgumentError',
      );
    });

    test('item does not exist', () {
      final int quantity = dataService.inventory.getItemQuantityFromInventory(materialKey, ItemType.material);
      expect(quantity, isZero, reason: 'Quantity for a material never added (key=$materialKey) should be 0');
    });

    test('item exists', () async {
      const int expected = 666;
      await dataService.inventory.addMaterialToInventory(materialKey, expected);
      final int quantity = dataService.inventory.getItemQuantityFromInventory(materialKey, ItemType.material);
      expect(
        quantity,
        expected,
        reason: 'After adding $expected of material (key=$materialKey), queried quantity should be $expected',
      );
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
      expect(
        dataService.inventory.addMaterialToInventory('', 666),
        throwsArgumentError,
        reason: 'Adding a material with an empty key must throw ArgumentError',
      );
    });

    test('item quantity is not valid', () {
      expect(
        dataService.inventory.addMaterialToInventory(materialKey, -1),
        throwsArgumentError,
        reason: 'Adding a material with negative quantity (-1) must throw ArgumentError',
      );
    });

    test('item does not exist thus it gets added', () async {
      int count = dataService.inventory.getItemQuantityFromInventory(materialKey, ItemType.material);
      expect(count, isZero, reason: 'Before adding, quantity for material (key=$materialKey) should be 0');

      await dataService.inventory.addMaterialToInventory(materialKey, 666);
      count = dataService.inventory.getItemQuantityFromInventory(materialKey, ItemType.material);
      expect(count, 666, reason: 'After adding 666 of material (key=$materialKey), quantity should be 666');
    });

    test('item already exists thus it gets updated', () async {
      await dataService.inventory.addMaterialToInventory(materialKey, 666);
      int count = dataService.inventory.getItemQuantityFromInventory(materialKey, ItemType.material);
      expect(count, 666, reason: 'After first add of 666 to material (key=$materialKey), quantity should be 666');

      await dataService.inventory.addMaterialToInventory(materialKey, 333);
      count = dataService.inventory.getItemQuantityFromInventory(materialKey, ItemType.material);
      expect(
        count,
        333,
        reason: 'Re-adding material (key=$materialKey) should overwrite quantity to 333, not accumulate',
      );
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
        expect(
          () => dataService.inventory.isItemInInventory('', type),
          throwsArgumentError,
          reason: 'Checking inventory membership with an empty key must throw ArgumentError (type=${type.name})',
        );
      });

      test('no data exist for type = ${type.name}', () {
        final String key = getItemKey(type);
        final bool exist = dataService.inventory.isItemInInventory(key, type);
        expect(exist, isFalse, reason: 'With no data, item (key=$key, type=${type.name}) should not be in inventory');
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
        expect(exist, isTrue, reason: 'After adding item (key=$key, type=${type.name}), it should be in inventory');
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
      expect(
        () => dataService.inventory.getUsedMaterialQuantity(''),
        throwsArgumentError,
        reason: 'Querying used quantity with an empty key must throw ArgumentError',
      );
    });

    test('no data exist', () {
      final int count = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(
        count,
        isZero,
        reason: 'With no usage recorded, used quantity for material (key=$materialKey) should be 0',
      );
    });

    test('data exists', () async {
      const calcId = 1;
      const int quantity = 666;
      const expected = quantity ~/ 2;
      await dataService.inventory.addMaterialToInventory(materialKey, quantity);
      await dataService.inventory.useMaterialFromInventory(calcId, materialKey, expected);
      final int used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(
        used,
        expected,
        reason: 'After using $expected of material (key=$materialKey), used quantity should be $expected',
      );
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
      expect(
        () => dataService.inventory.redistributeMaterial(-1, [], materialKey, 0),
        throwsArgumentError,
        reason: 'Redistributing with an invalid calc key (-1) must throw ArgumentError',
      );
    });

    test('item key is not valid', () {
      expect(
        () => dataService.inventory.redistributeMaterial(1, [], '', 0),
        throwsArgumentError,
        reason: 'Redistributing with an empty item key must throw ArgumentError',
      );
    });

    test('current quantity is not valid', () {
      expect(
        () => dataService.inventory.redistributeMaterial(1, [], materialKey, -1),
        throwsArgumentError,
        reason: 'Redistributing with negative current quantity (-1) must throw ArgumentError',
      );
    });

    test('not being used and provided materials array is empty', () async {
      const int available = 666;
      final int remaining = await dataService.inventory.redistributeMaterial(1, [], materialKey, available);
      expect(
        remaining,
        available,
        reason: 'With no materials to allocate, redistribute should return all $available as remaining',
      );

      final used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(
        used,
        isZero,
        reason: 'With an empty materials array, no material (key=$materialKey) should be marked used',
      );
    });

    test('not being used and required quantity is less than available', () async {
      const int available = 666;
      const int required = 110;
      final material = genshinService.materials.getMaterial(materialKey);
      final materials = [ItemAscensionMaterialModel.fromMaterial(required, material, '')];
      final int remaining = await dataService.inventory.redistributeMaterial(1, materials, materialKey, available);
      expect(
        remaining,
        available - required,
        reason: 'Redistributing $required of $available available should leave ${available - required} remaining',
      );

      final used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(
        used,
        required,
        reason: 'After redistributing, used quantity for material (key=$materialKey) should be $required',
      );
    });

    test('not being used and required quantity equals available', () async {
      const int available = 666;
      final material = genshinService.materials.getMaterial(materialKey);
      final materials = [ItemAscensionMaterialModel.fromMaterial(available, material, '')];
      final int remaining = await dataService.inventory.redistributeMaterial(1, materials, materialKey, available);
      expect(remaining, isZero, reason: 'Redistributing exactly the available $available should leave 0 remaining');

      final used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(
        used,
        available,
        reason: 'After redistributing all, used quantity for material (key=$materialKey) should be $available',
      );
    });

    test('not being used and required quantity is greater than available', () async {
      const int available = 666;
      final material = genshinService.materials.getMaterial(materialKey);
      final materials = [ItemAscensionMaterialModel.fromMaterial(available * 2, material, '')];
      final int remaining = await dataService.inventory.redistributeMaterial(1, materials, materialKey, available);
      expect(
        remaining,
        isZero,
        reason: 'Redistributing more than available (${available * 2} of $available) should leave 0 remaining',
      );

      final used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(
        used,
        available,
        reason: 'Used quantity for material (key=$materialKey) should cap at available $available',
      );
    });

    test('being used and provided materials array is empty', () async {
      const int calcId = 1;
      const int available = 666;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(calcId, materialKey, 10);
      final int remaining = await dataService.inventory.redistributeMaterial(calcId, [], materialKey, available);
      expect(
        remaining,
        available,
        reason: 'Redistributing with empty materials should free all usage and return all $available remaining',
      );

      final updatedUsed = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(
        updatedUsed,
        isZero,
        reason: 'After clearing usage via redistribute, used quantity for material (key=$materialKey) should be 0',
      );
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
      expect(
        remaining,
        available - required,
        reason: 'Redistributing $required of $available in-use should leave ${available - required} remaining',
      );

      final updatedUsed = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(
        updatedUsed,
        required,
        reason: 'After redistributing in-use material (key=$materialKey), used quantity should be $required',
      );
    });

    test('being used and required quantity equals available', () async {
      const int calcId = 1;
      const int available = 666;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(calcId, materialKey, available);

      final material = genshinService.materials.getMaterial(materialKey);
      final materials = [ItemAscensionMaterialModel.fromMaterial(available, material, '')];
      final int remaining = await dataService.inventory.redistributeMaterial(calcId, materials, materialKey, available);
      expect(
        remaining,
        isZero,
        reason: 'Redistributing exactly the available $available while in use should leave 0 remaining',
      );

      final updatedUsed = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(
        updatedUsed,
        available,
        reason: 'After redistributing all in-use material (key=$materialKey), used quantity should be $available',
      );
    });

    test('not being used and required quantity is greater than available', () async {
      const int calcId = 1;
      const int available = 666;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(calcId, materialKey, available);

      final material = genshinService.materials.getMaterial(materialKey);
      final materials = [ItemAscensionMaterialModel.fromMaterial(available * 2, material, '')];
      final int remaining = await dataService.inventory.redistributeMaterial(calcId, materials, materialKey, available);
      expect(
        remaining,
        isZero,
        reason: 'Redistributing more than available (${available * 2} of $available) in use should leave 0 remaining',
      );

      final updatedUsed = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(
        updatedUsed,
        available,
        reason: 'Used quantity for in-use material (key=$materialKey) should cap at available $available',
      );
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
      expect(
        dataService.inventory.useMaterialFromInventory(-1, materialKey, 666),
        throwsArgumentError,
        reason: 'Using a material with an invalid calc key (-1) must throw ArgumentError',
      );
    });

    test('item key is not valid', () {
      expect(
        dataService.inventory.useMaterialFromInventory(1, '', 666),
        throwsArgumentError,
        reason: 'Using a material with an empty item key must throw ArgumentError',
      );
    });

    test('quantity is not valid', () {
      expect(
        dataService.inventory.useMaterialFromInventory(1, materialKey, -1),
        throwsArgumentError,
        reason: 'Using a material with negative quantity (-1) must throw ArgumentError',
      );
    });

    test('item is not in inventory', () async {
      await dataService.inventory.useMaterialFromInventory(1, materialKey, 666);
      final int used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, isZero, reason: 'Using a material never added (key=$materialKey) should record 0 used');
    });

    test('quantity to use is zero', () async {
      const int available = 666;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, 0);
      final int used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, isZero, reason: 'Using 0 of material (key=$materialKey) should leave used quantity at 0');
    });

    test('quantity to use is greater than available', () async {
      const int available = 666;
      const int required = available * 2;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, required);
      final int used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(
        used,
        available,
        reason: 'Using more than available ($required of $available) should cap used at $available',
      );
    });

    test('quantity to use is less than available', () async {
      const int available = 666;
      const int required = available ~/ 2;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, required);
      final int used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, required, reason: 'Using $required of $available available should record $required used');
    });

    test('quantity to use equals available', () async {
      const int available = 666;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, available);
      final int used = dataService.inventory.getUsedMaterialQuantity(materialKey);
      expect(used, available, reason: 'Using exactly the available $available should record $available used');
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
      expect(
        dataService.inventory.clearUsedInventoryItems(-1),
        throwsArgumentError,
        reason: 'Clearing used items with an invalid calc key (-1) must throw ArgumentError',
      );
    });

    test('data does not exist', () {
      expect(
        dataService.inventory.clearUsedInventoryItems(1),
        completes,
        reason: 'clearUsedInventoryItems(1) with no data should complete without error',
      );
    });

    test('data exists and no item key is provided', () async {
      await dataService.inventory.addMaterialToInventory(materialKey, 666);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, 10);
      await dataService.inventory.useMaterialFromInventory(2, materialKey, 5);
      await dataService.inventory.clearUsedInventoryItems(1);

      final int usedA = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(1, materialKey);
      expect(
        usedA,
        isZero,
        reason: 'After clearUsedInventoryItems(1), usage for calc 1 material (key=$materialKey) should be 0',
      );

      final int usedB = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(2, materialKey);
      expect(usedB, 5, reason: 'Clearing calc 1 must not touch calc 2; material (key=$materialKey) used should stay 5');
    });

    test('data exists and item key is provided', () async {
      const String primogem = 'primogem';
      await dataService.inventory.addMaterialToInventory(materialKey, 666);
      await dataService.inventory.addMaterialToInventory(primogem, 666);
      await dataService.inventory.useMaterialFromInventory(1, materialKey, 10);
      await dataService.inventory.useMaterialFromInventory(1, primogem, 10);
      await dataService.inventory.clearUsedInventoryItems(1, onlyItemKey: materialKey);

      int used = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(1, materialKey);
      expect(used, isZero, reason: 'After clearing only key=$materialKey for calc 1, its used quantity should be 0');

      used = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(1, primogem);
      expect(used, 10, reason: 'Clearing only key=$materialKey must leave key=$primogem used quantity at 10');
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
      expect(
        () => dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(-1, materialKey),
        throwsArgumentError,
        reason: 'Querying used quantity with an invalid calc key (-1) must throw ArgumentError',
      );
    });

    test('item key is not valid', () {
      expect(
        () => dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(1, ''),
        throwsArgumentError,
        reason: 'Querying used quantity with an empty item key must throw ArgumentError',
      );
    });

    test('no data exist', () {
      final int count = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(1, materialKey);
      expect(
        count,
        isZero,
        reason: 'With no usage recorded, used quantity for calc 1 material (key=$materialKey) should be 0',
      );
    });

    test('data exists', () async {
      const int calcKey = 1;
      const int available = 666;
      const int used = available ~/ 2;
      await dataService.inventory.addMaterialToInventory(materialKey, available);
      await dataService.inventory.useMaterialFromInventory(calcKey, materialKey, used);
      final int count = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(calcKey, materialKey);
      expect(
        count,
        used,
        reason: 'After using $used, used quantity for calc $calcKey material (key=$materialKey) should be $used',
      );
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
        expect(items.isEmpty, isTrue, reason: 'With no data, getItemsForRedistribution(${type.name}) should be empty');
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
        expect(
          items.length,
          1,
          reason: 'After adding ${type.name} (key=$itemKey), redistribution list should have exactly 1 item',
        );

        final item = items.first;
        expect(item.key, itemKey, reason: 'Redistribution item key should be $itemKey (type=${type.name})');
        expect(
          item.quantity,
          type == ItemType.material ? 666 : 1,
          reason: 'Redistribution item (key=$itemKey) quantity should be ${type == ItemType.material ? 666 : 1}',
        );
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
      expect(bk, isEmpty, reason: 'With no inventory, getDataForBackup() should return an empty list');
    });

    test('data exists', () async {
      await dataService.inventory.addCharacterToInventory(charKey);
      await dataService.inventory.addWeaponToInventory(weaponKey);
      await dataService.inventory.addMaterialToInventory(materialKey, 666);

      final bk = dataService.inventory.getDataForBackup();
      expect(bk.length, 3, reason: 'Backup should contain the 3 added items (character, weapon, material)');

      const expected = <String, ItemType>{
        charKey: ItemType.character,
        weaponKey: ItemType.weapon,
        materialKey: ItemType.material,
      };
      for (int i = 0; i < bk.length; i++) {
        final kvp = expected.entries.elementAt(i);
        final bkItem = bk[i];

        expect(bkItem.itemKey, kvp.key, reason: 'Backup item at index $i should have key=${kvp.key}');
        expect(
          bkItem.quantity,
          kvp.value == ItemType.material ? 666 : 1,
          reason: 'Backup item (key=${kvp.key}) quantity should be ${kvp.value == ItemType.material ? 666 : 1}',
        );
        expect(
          bkItem.type,
          kvp.value.index,
          reason: 'Backup item (key=${kvp.key}) type should be ${kvp.value.name} (index ${kvp.value.index})',
        );
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
      expect(count, isZero, reason: 'Restoring an empty backup onto empty inventory should leave 0 items');
    });

    test('no data to restore and previous data exist', () async {
      await dataService.inventory.addCharacterToInventory(charKey);
      await dataService.inventory.restoreFromBackup([]);
      final count = dataService.inventory.getDataForBackup().length;
      expect(count, isZero, reason: 'Restoring an empty backup should wipe existing inventory, leaving 0 items');
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
      expect(count, bk.length, reason: 'Restore should replace inventory with the ${bk.length} backup items');
      for (final bkItem in bk) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(bkItem.itemKey, ItemType.values[bkItem.type]);
        expect(
          quantity,
          bkItem.quantity,
          reason: 'Restored item (key=${bkItem.itemKey}) quantity should be ${bkItem.quantity}',
        );
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
      expect(
        () => dataService.inventory.getUsedMaterialKeysByCalcKey(-1),
        throwsArgumentError,
        reason: 'Querying used material keys with an invalid calc key (-1) must throw ArgumentError',
      );
    });

    test('no data exist', () {
      final List<String> keys = dataService.inventory.getUsedMaterialKeysByCalcKey(666);
      expect(keys.isEmpty, isTrue, reason: 'With no usage recorded, getUsedMaterialKeysByCalcKey(666) should be empty');
    });

    test('data exists', () async {
      const int calcId = 1;
      const expected = <String, int>{materialKey: 666, 'primogem': 100};

      for (final kvp in expected.entries) {
        await dataService.inventory.addMaterialToInventory(kvp.key, kvp.value);
        await dataService.inventory.useMaterialFromInventory(calcId, kvp.key, kvp.value);
      }

      final List<String> keys = dataService.inventory.getUsedMaterialKeysByCalcKey(calcId);
      expect(
        keys.length,
        expected.length,
        reason: 'Used material keys for calc $calcId should number ${expected.length}',
      );
      expect(
        keys,
        expected.keys.toList(),
        reason: 'Used material keys for calc $calcId should be ${expected.keys.toList()}',
      );
    });
  });
}
