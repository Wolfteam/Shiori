import 'dart:math';

import 'package:darq/darq.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_asc_materials_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const String _baseDbFolder = 'shiori_calc_asc_materials_data_service';

void main() {
  late final ResourceService resourceService;
  late final GenshinService genshinService;
  late final CalculatorAscMaterialsService calculatorService;

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

  ItemAscensionMaterials getCharacter({
    String key = 'keqing',
    int currentLevel = 1,
    int desiredLevel = maxItemLevel,
    int currentAscLevel = 0,
    int desiredAscLevel = 6,
    bool useMaterialsFromInventory = false,
  }) {
    final char = genshinService.characters.getCharacter(key);
    final skills = char.skills
        .mapIndex(
          (e, i) => CharacterSkill.skill(
            key: e.key,
            position: i,
            name: 'Skill-$i',
            currentLevel: minSkillLevel,
            desiredLevel: maxSkillLevel,
            isCurrentIncEnabled: false,
            isCurrentDecEnabled: false,
            isDesiredIncEnabled: false,
            isDesiredDecEnabled: false,
          ),
        )
        .toList();
    final materials = calculatorService.getCharacterMaterialsToUse(char, currentLevel, desiredLevel, currentAscLevel, desiredAscLevel, skills);
    return ItemAscensionMaterials.forCharacters(
      key: key,
      name: 'Name',
      position: 0,
      image: 'img.webp',
      rarity: 5,
      materials: materials,
      currentLevel: currentLevel,
      desiredLevel: desiredLevel,
      currentAscensionLevel: currentAscLevel,
      desiredAscensionLevel: desiredAscLevel,
      skills: skills,
      useMaterialsFromInventory: useMaterialsFromInventory,
    );
  }

  ItemAscensionMaterials getWeapon({
    String key = 'aquila-favonia',
    int currentLevel = 1,
    int desiredLevel = maxItemLevel,
    int currentAscLevel = 0,
    int desiredAscLevel = 6,
    bool useMaterialsFromInventory = false,
  }) {
    final weapon = genshinService.weapons.getWeapon(key);
    final materials = calculatorService.getWeaponMaterialsToUse(weapon, currentLevel, desiredLevel, currentAscLevel, desiredAscLevel);
    return ItemAscensionMaterials.forWeapons(
      key: key,
      name: 'Name',
      position: 0,
      image: 'img.webp',
      rarity: 5,
      materials: materials,
      currentLevel: currentLevel,
      desiredLevel: desiredLevel,
      currentAscensionLevel: currentAscLevel,
      desiredAscensionLevel: desiredAscLevel,
      useMaterialsFromInventory: useMaterialsFromInventory,
    );
  }

  void checkSessionItem(ItemAscensionMaterials got, ItemAscensionMaterials expected) {
    expect(got.key, expected.key);
    expect(got.position, expected.position);
    expect(got.currentLevel, expected.currentLevel);
    expect(got.desiredLevel, expected.desiredLevel);
    expect(got.currentAscensionLevel, expected.currentAscensionLevel);
    expect(got.desiredAscensionLevel, expected.desiredAscensionLevel);
    expect(got.isCharacter, expected.isCharacter);
    expect(got.isWeapon, expected.isWeapon);
    expect(got.isActive, expected.isActive);
    expect(got.useMaterialsFromInventory, expected.useMaterialsFromInventory);
    if (expected.isCharacter) {
      expect(expected.skills, isNotEmpty);
      for (int j = 0; j < got.skills.length; j++) {
        final gotSkill = got.skills[j];
        final expectedSkill = expected.skills[j];
        expect(gotSkill.key, expectedSkill.key);
        expect(gotSkill.currentLevel, expectedSkill.currentLevel);
        expect(gotSkill.desiredLevel, expectedSkill.desiredLevel);
        expect(gotSkill.position, expectedSkill.position);
      }
    } else {
      expect(got.skills, isEmpty);
    }
  }

  group('Get all sessions', () {
    const dbFolder = '${_baseDbFolder}_get_all_sessions_tests';
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
      final sessions = dataService.calculator.getAllSessions();
      expect(sessions.isEmpty, isTrue);
    });

    test('data exists', () async {
      await dataService.calculator.createSession('Dummy', 0);
      final sessions = dataService.calculator.getAllSessions();
      expect(sessions.length, 1);
      final session = sessions.first;
      expect(session.key >= 0, isTrue);
      expect(session.name, 'Dummy');
      expect(session.position, 0);
      expect(session.numberOfCharacters, 0);
      expect(session.numberOfWeapons, 0);
    });
  });

  group('Get session', () {
    const dbFolder = '${_baseDbFolder}_get_session_tests';
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

    test('key is not valid', () {
      expect(() => dataService.calculator.getSession(-1), throwsArgumentError);
    });

    test('key does not exist', () {
      expect(() => dataService.calculator.getSession(666), throwsException);
    });

    test('key exists', () async {
      final createdSession = await dataService.calculator.createSession('Exists', 0);
      final existingSession = dataService.calculator.getSession(createdSession.key);
      expect(existingSession.key, createdSession.key);
    });
  });

  group('Create session', () {
    const dbFolder = '${_baseDbFolder}_create_session_tests';
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

    test('name is not valid', () {
      expect(dataService.calculator.createSession('', 0), throwsArgumentError);
    });

    test('position is not valid', () {
      expect(dataService.calculator.createSession('New', -1), throwsArgumentError);
    });

    test('valid call', () async {
      final createdSession = await dataService.calculator.createSession('New', 1);
      expect(createdSession.key >= 0, isTrue);
      expect(createdSession.name, 'New');
      expect(createdSession.position, 1);
      expect(createdSession.numberOfCharacters, 0);
      expect(createdSession.numberOfWeapons, 0);
    });
  });

  group('Update session', () {
    const dbFolder = '${_baseDbFolder}_update_session_tests';
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

    test('key is not valid', () {
      expect(dataService.calculator.updateSession(-1, 'Updated'), throwsArgumentError);
    });

    test('name is not valid', () async {
      expect(dataService.calculator.updateSession(1, ''), throwsArgumentError);
    });

    test('session does not exist', () {
      expect(dataService.calculator.updateSession(1, 'Updated'), throwsException);
    });

    test('valid call', () async {
      final existing = await dataService.calculator.createSession('New', 1);
      final updated = await dataService.calculator.updateSession(existing.key, 'Updated');
      expect(updated.key, existing.key);
      expect(updated.name, 'Updated');
      expect(updated.position, existing.position);
      expect(updated.numberOfCharacters, 0);
      expect(updated.numberOfWeapons, 0);
    });
  });

  group('Delete session', () {
    const dbFolder = '${_baseDbFolder}_delete_session_tests';
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

    test('key is not valid', () {
      expect(dataService.calculator.deleteSession(-1), throwsArgumentError);
    });

    test('session does not exist, completes normally', () {
      const int key = 666;
      expect(() => dataService.calculator.getSession(key), throwsException);
      expect(dataService.calculator.deleteSession(key), completes);
    });

    test('session exists, and gets deleted', () async {
      final session = await dataService.calculator.createSession('Deleted', 0);
      expect(() => dataService.calculator.getSession(session.key), returnsNormally);
      await dataService.calculator.deleteSession(session.key);
      expect(() => dataService.calculator.getSession(session.key), throwsException);
    });
  });

  group('Delete all sessions', () {
    const dbFolder = '${_baseDbFolder}_delete_all_sessions_tests';
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

    test('no data exists, completes normally', () async {
      await dataService.calculator.deleteAllSessions();
      final sessions = dataService.calculator.getAllSessions();
      expect(sessions.isEmpty, isTrue);
    });

    test('data exists and gets deleted', () async {
      await dataService.calculator.createSession('To be deleted', 5);
      await dataService.calculator.deleteAllSessions();
      final sessions = dataService.calculator.getAllSessions();
      expect(sessions.isEmpty, isTrue);
    });
  });

  group('Get all session items', () {
    const dbFolder = '${_baseDbFolder}_get_all_session_items_tests';
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

    test('key is not valid', () {
      expect(() => dataService.calculator.getAllSessionItems(-1), throwsArgumentError);
    });

    test('no data exists, returns empty', () async {
      final items = dataService.calculator.getAllSessionItems(666);
      expect(items.isEmpty, isTrue);
    });

    test('data exists', () async {
      final session = await dataService.calculator.createSession('NewOne', 1);
      final charItem = getCharacter();
      final weaponItem = getWeapon();
      final items = <ItemAscensionMaterials>[charItem, weaponItem];
      await dataService.calculator.addSessionItems(session.key, items);
      expect(items.length, items.length);
    });
  });

  group('Add session item', () {
    const dbFolder = '${_baseDbFolder}_add_session_item_tests';
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

    test('key is not valid', () {
      expect(dataService.calculator.addSessionItem(-1, getCharacter(), []), throwsArgumentError);
    });

    test('session does not exist', () {
      expect(dataService.calculator.addSessionItem(666, getCharacter(), []), throwsArgumentError);
    });

    test('of type character', () async {
      final item = getCharacter();
      final session = await dataService.calculator.createSession('Characters', 1);
      await dataService.calculator.addSessionItem(session.key, item, []);
      final items = dataService.calculator.getAllSessionItems(session.key);
      expect(items.length, 1);
      checkSessionItem(items.first, item);
    });

    test('of type weapon', () async {
      final item = getWeapon();
      final session = await dataService.calculator.createSession('Weapons', 1);
      await dataService.calculator.addSessionItem(session.key, item, []);
      final items = dataService.calculator.getAllSessionItems(session.key);
      expect(items.length, 1);
      checkSessionItem(items.first, item);
    });

    test('of type character and weapon', () async {
      final charItem = getCharacter();
      final weaponItem = getWeapon();
      final items = [charItem, weaponItem];
      final session = await dataService.calculator.createSession('Chars&Weapons', 1);
      await dataService.calculator.addSessionItems(session.key, items);
      final existing = dataService.calculator.getAllSessionItems(session.key);
      expect(existing.length, 2);
      checkSessionItem(existing.first, charItem);
      checkSessionItem(existing.last, weaponItem);
    });

    test('of type character and weapon and use items from inventory', () async {
      final charItem = getCharacter(useMaterialsFromInventory: true);
      final weaponItem = getWeapon(useMaterialsFromInventory: true);
      final requiredMaterials = charItem.materials
          .concat(weaponItem.materials)
          .groupBy((g) => g.key)
          .map((g) => MapEntry<String, int>(g.key, g.map((e) => e.requiredQuantity).sum()))
          .toList();

      expect(requiredMaterials.isNotEmpty, isTrue);
      for (final kvp in requiredMaterials) {
        await dataService.inventory.addItemToInventory(kvp.key, ItemType.material, kvp.value);
      }

      final session = await dataService.calculator.createSession('Chars&WeaponsFromInv', 1);
      await dataService.calculator.addSessionItems(session.key, [charItem, weaponItem]);
      final existing = dataService.calculator.getAllSessionItems(session.key);

      expect(existing.length, 2);
      checkSessionItem(existing.first, charItem);
      checkSessionItem(existing.last, weaponItem);

      for (final kvp in requiredMaterials) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(kvp.key, ItemType.material);
        expect(kvp.value, quantity);

        final int used = dataService.inventory.getNumberOfItemsUsed(kvp.key, ItemType.material);
        expect(kvp.value, used);
      }
    });
  });

  group('Update session item', () {
    const dbFolder = '${_baseDbFolder}_update_session_item_tests';
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

    test('key is not valid', () {
      expect(dataService.calculator.updateSessionItem(-1, 1, getCharacter(), []), throwsArgumentError);
    });

    test('position is not valid', () {
      expect(dataService.calculator.updateSessionItem(1, -1, getCharacter(), []), throwsArgumentError);
    });

    test('session does not exist', () {
      expect(dataService.calculator.updateSessionItem(666, 1, getCharacter(), []), throwsArgumentError);
    });

    test('item does not exist thus a new one gets created', () async {
      final itemChar = getCharacter().copyWith(position: 2);
      final session = await dataService.calculator.createSession('UpdateItem', 0);
      await dataService.calculator.updateSessionItem(session.key, itemChar.position, itemChar, []);
      final items = dataService.calculator.getAllSessionItems(session.key);
      expect(items.length, 1);

      final got = items.first;
      checkSessionItem(got, itemChar);
    });

    test('item exists thus it gets recreated', () async {
      final session = await dataService.calculator.createSession('UpdateItem', 0);
      await dataService.calculator.addSessionItem(session.key, getCharacter(), []);

      final updated = getCharacter().copyWith(desiredLevel: 80);
      await dataService.calculator.updateSessionItem(session.key, 5, updated, []);
      final items = dataService.calculator.getAllSessionItems(session.key);
      expect(items.length, 1);

      final got = items.first;
      checkSessionItem(got, updated.copyWith(position: 5));
    });
  });

  group('Delete session item', () {
    const dbFolder = '${_baseDbFolder}_delete_session_item_tests';
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

    test('key is not valid', () {
      expect(dataService.calculator.deleteSessionItem(-1, 1), throwsArgumentError);
    });

    test('position is not valid', () {
      expect(dataService.calculator.deleteSessionItem(1, -1), throwsArgumentError);
    });

    test('which does not exist, returns normally', () {
      expect(dataService.calculator.deleteSessionItem(666, 666), completes);
    });

    test('which exists and it gets deleted', () async {
      final item = getWeapon();
      final session = await dataService.calculator.createSession('Item Deleted', 0);
      await dataService.calculator.addSessionItem(session.key, item, []);
      final currentCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(currentCount, 1);

      await dataService.calculator.deleteSessionItem(session.key, item.position);
      final newCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(newCount, 0);
    });

    test('which exists and it was using materials from inventory', () async {
      final session = await dataService.calculator.createSession('Item Deleted', 0);
      final item = getWeapon(useMaterialsFromInventory: true);
      final requiredMaterials = item.materials
          .groupBy((g) => g.key)
          .map(
            (g) => MapEntry<String, int>(g.key, g.map((e) => e.requiredQuantity).sum()),
          )
          .toList();

      expect(requiredMaterials.isNotEmpty, isTrue);
      for (final kvp in requiredMaterials) {
        await dataService.inventory.addItemToInventory(kvp.key, ItemType.material, kvp.value);
      }

      await dataService.calculator.addSessionItem(session.key, item, []);
      final currentCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(currentCount, 1);
      for (final kvp in requiredMaterials) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(kvp.key, ItemType.material);
        expect(kvp.value, quantity);

        final int used = dataService.inventory.getNumberOfItemsUsed(kvp.key, ItemType.material);
        expect(kvp.value, used);
      }

      await dataService.calculator.deleteSessionItem(session.key, item.position);
      final newCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(newCount, 0);
      for (final kvp in requiredMaterials) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(kvp.key, ItemType.material);
        expect(kvp.value, quantity);

        final int used = dataService.inventory.getNumberOfItemsUsed(kvp.key, ItemType.material);
        expect(used, 0);
      }
    });
  });

  group('Delete all session items', () {
    const dbFolder = '${_baseDbFolder}_delete_all_session_item_tests';
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

    test('key is not valid', () {
      expect(dataService.calculator.deleteAllSessionItems(-1), throwsArgumentError);
    });

    test('session does not exist, returns normally', () {
      expect(dataService.calculator.deleteAllSessionItems(666), completes);
    });

    test('session exists but it is empty, returns normally', () async {
      final session = await dataService.calculator.createSession('Delete all items', 0);
      expect(dataService.calculator.deleteAllSessionItems(session.key), completes);
    });

    test('session exists and it is not empty, all items gets deleted', () async {
      final session = await dataService.calculator.createSession('Delete all items', 0);
      await dataService.calculator.addSessionItems(session.key, [getCharacter(), getWeapon()]);
      final currentCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(currentCount, 2);

      await dataService.calculator.deleteAllSessionItems(session.key);
      final newCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(newCount, 0);
    });

    test('session exists, it is not empty and items were using materials from inventory', () async {
      final items = [getCharacter(useMaterialsFromInventory: true), getWeapon(useMaterialsFromInventory: true)];
      final requiredMaterials = items
          .selectMany((e, _) => e.materials)
          .groupBy((g) => g.key)
          .map((g) => MapEntry<String, int>(g.key, g.map((e) => e.requiredQuantity).sum()))
          .toList();

      expect(requiredMaterials.isNotEmpty, isTrue);
      for (final kvp in requiredMaterials) {
        await dataService.inventory.addItemToInventory(kvp.key, ItemType.material, kvp.value);
      }

      final session = await dataService.calculator.createSession('Delete all items', 0);
      await dataService.calculator.addSessionItems(session.key, items);
      final currentCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(currentCount, 2);
      for (final kvp in requiredMaterials) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(kvp.key, ItemType.material);
        expect(kvp.value, quantity);

        final int used = dataService.inventory.getNumberOfItemsUsed(kvp.key, ItemType.material);
        expect(kvp.value, used);
      }

      await dataService.calculator.deleteAllSessionItems(session.key);
      final newCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(newCount, 0);
      for (final kvp in requiredMaterials) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(kvp.key, ItemType.material);
        expect(kvp.value, quantity);

        final int used = dataService.inventory.getNumberOfItemsUsed(kvp.key, ItemType.material);
        expect(used, 0);
      }
    });
  });

  group('Redistribute all inventory materials', () {
    const dbFolder = '${_baseDbFolder}_redistribute_all_inventory_materials_tests';
    const String moraKey = 'mora';
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

    Future<void> runItemsDeletedTest(bool deleteSession) async {
      final sessionA = await dataService.calculator.createSession('RedistributeA', 0);
      final sessionB = await dataService.calculator.createSession('RedistributeB', 1);

      final items = [getCharacter(useMaterialsFromInventory: true), getWeapon(useMaterialsFromInventory: true)];
      final requiredMaterials = items
          .selectMany((e, _) => e.materials)
          .groupBy((g) => g.key)
          .map(
            (g) => MapEntry<String, int>(g.key, g.map((e) => e.requiredQuantity).sum()),
          )
          .toList();

      expect(requiredMaterials.isNotEmpty, isTrue);
      for (final kvp in requiredMaterials) {
        await dataService.inventory.addItemToInventory(kvp.key, ItemType.material, kvp.value);
      }

      await dataService.calculator.addSessionItems(sessionA.key, items);
      await dataService.calculator.addSessionItems(sessionB.key, items);

      if (deleteSession) {
        await dataService.calculator.deleteSession(sessionA.key);
      } else {
        await dataService.calculator.deleteAllSessionItems(sessionA.key);
      }

      for (final kvp in requiredMaterials) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(kvp.key, ItemType.material);
        expect(kvp.value, quantity);

        final int used = dataService.inventory.getNumberOfItemsUsed(kvp.key, ItemType.material);
        expect(used, kvp.value);
      }
    }

    Future<void> runItemDeleteTest(bool redistributeOnDelete) async {
      final session = await dataService.calculator.createSession('Redistribute', 0);

      final char = getCharacter(useMaterialsFromInventory: true);
      final weapon = getWeapon(useMaterialsFromInventory: true);
      final items = [char, weapon];
      final int availableMora = max(
        char.materials.where((g) => g.key == moraKey).first.requiredQuantity,
        weapon.materials.where((g) => g.key == moraKey).first.requiredQuantity,
      );

      await dataService.inventory.addItemToInventory(moraKey, ItemType.material, availableMora);
      await dataService.calculator.addSessionItems(session.key, items);
      await dataService.calculator.deleteSessionItem(session.key, char.position, redistribute: redistributeOnDelete);

      if (!redistributeOnDelete) {
        await dataService.calculator.redistributeInventoryMaterialsFromSessionPosition(session.key);
      }

      final int quantity = dataService.inventory.getItemQuantityFromInventory(moraKey, ItemType.material);
      expect(availableMora, quantity);

      final int used = dataService.inventory.getNumberOfItemsUsed(moraKey, ItemType.material);
      expect(used, weapon.materials.firstWhere((el) => el.key == moraKey).requiredQuantity);
    }

    Future<void> runItemUpdateTest(bool useMaterialsFromInventory, bool isActive) async {
      final session = await dataService.calculator.createSession('Redistribute', 0);

      final char = getCharacter(useMaterialsFromInventory: true);
      final weapon = getWeapon(useMaterialsFromInventory: true);
      final items = [char, weapon];
      int availableMora = min(
        char.materials.where((g) => g.key == moraKey).first.requiredQuantity,
        weapon.materials.where((g) => g.key == moraKey).first.requiredQuantity,
      );
      availableMora ~/= 2;

      await dataService.inventory.addItemToInventory(moraKey, ItemType.material, availableMora);
      await dataService.calculator.addSessionItems(session.key, items);

      var expectedQuantityMap = <int, int>{
        0: availableMora,
        1: 0,
      };

      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getNumberOfItemsUsedByCalcKeyItemKeyAndType(kvp.key, moraKey, ItemType.material);
        expect(usedMora, kvp.value);
      }

      await dataService.calculator.updateSessionItem(
        session.key,
        char.position,
        char.copyWith(isActive: isActive, useMaterialsFromInventory: useMaterialsFromInventory),
        [],
      );

      final int quantity = dataService.inventory.getItemQuantityFromInventory(moraKey, ItemType.material);
      expect(availableMora, quantity);
      final int used = dataService.inventory.getNumberOfItemsUsed(moraKey, ItemType.material);
      expect(used, availableMora);

      expectedQuantityMap = <int, int>{
        0: 0,
        1: availableMora,
      };
      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getNumberOfItemsUsedByCalcKeyItemKeyAndType(kvp.key, moraKey, ItemType.material);
        expect(usedMora, kvp.value);
      }
    }

    test('2 sessions contains same items but the first session gets deleted', () async {
      await runItemsDeletedTest(true);
    });

    test('2 sessions contains same items but the items in the first one gets deleted', () async {
      await runItemsDeletedTest(false);
    });

    test('2 sessions contains 2 items with same used material but session order changes', () async {
      final sessionA = await dataService.calculator.createSession('RedistributeA', 0);
      final sessionB = await dataService.calculator.createSession('RedistributeB', 1);

      final char = getCharacter(useMaterialsFromInventory: true);
      final weapon = getWeapon(useMaterialsFromInventory: true);
      final items = [char, weapon];
      int availableMora = min(
        char.materials.where((g) => g.key == moraKey).first.requiredQuantity,
        weapon.materials.where((g) => g.key == moraKey).first.requiredQuantity,
      );
      availableMora ~/= 2;
      await dataService.inventory.addItemToInventory(moraKey, ItemType.material, availableMora);

      await dataService.calculator.addSessionItems(sessionA.key, items);
      await dataService.calculator.addSessionItems(sessionB.key, items);

      final int quantity = dataService.inventory.getItemQuantityFromInventory(moraKey, ItemType.material);
      expect(availableMora, quantity);
      final int used = dataService.inventory.getNumberOfItemsUsed(moraKey, ItemType.material);
      expect(used, availableMora);

      var expectedQuantityMap = <int, int>{
        0: availableMora,
        1: 0,
        2: 0,
        3: 0,
      };
      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getNumberOfItemsUsedByCalcKeyItemKeyAndType(kvp.key, moraKey, ItemType.material);
        expect(usedMora, kvp.value);
      }

      await dataService.calculator.reorderSessions([sessionB, sessionA]);

      expectedQuantityMap = <int, int>{
        0: 0,
        1: 0,
        2: availableMora,
        3: 0,
      };
      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getNumberOfItemsUsedByCalcKeyItemKeyAndType(kvp.key, moraKey, ItemType.material);
        expect(usedMora, kvp.value);
      }
    });

    test('session contains 2 items with same used material but one gets deleted', () async {
      await runItemDeleteTest(true);
    });

    test('session contains 2 items with same used material but item order changes', () async {
      final session = await dataService.calculator.createSession('Redistribute', 0);

      final char = getCharacter(useMaterialsFromInventory: true);
      final weapon = getWeapon(useMaterialsFromInventory: true);
      final items = [char, weapon];
      int availableMora = min(
        char.materials.where((g) => g.key == moraKey).first.requiredQuantity,
        weapon.materials.where((g) => g.key == moraKey).first.requiredQuantity,
      );
      availableMora ~/= 2;

      await dataService.inventory.addItemToInventory(moraKey, ItemType.material, availableMora);
      await dataService.calculator.addSessionItems(session.key, items);

      var expectedQuantityMap = <int, int>{
        0: availableMora,
        1: 0,
      };

      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getNumberOfItemsUsedByCalcKeyItemKeyAndType(kvp.key, moraKey, ItemType.material);
        expect(usedMora, kvp.value);
      }

      await dataService.calculator.reorderItems(session.key, [weapon, char]);

      final int quantity = dataService.inventory.getItemQuantityFromInventory(moraKey, ItemType.material);
      expect(availableMora, quantity);
      final int used = dataService.inventory.getNumberOfItemsUsed(moraKey, ItemType.material);
      expect(used, availableMora);

      expectedQuantityMap = <int, int>{
        0: 0,
        1: availableMora,
      };
      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getNumberOfItemsUsedByCalcKeyItemKeyAndType(kvp.key, moraKey, ItemType.material);
        expect(usedMora, kvp.value);
      }
    });

    test('session contains 1 item but a new item gets added that uses same materials', () async {
      final session = await dataService.calculator.createSession('Redistribute', 0);

      final char = getCharacter(useMaterialsFromInventory: true);
      final int charRequiredMora = char.materials.where((g) => g.key == moraKey).first.requiredQuantity;
      final weapon = getWeapon(useMaterialsFromInventory: true);
      final int weaponRequiredMora = weapon.materials.where((g) => g.key == moraKey).first.requiredQuantity;
      final int availableMora = 2 * max(charRequiredMora, weaponRequiredMora);

      await dataService.inventory.addItemToInventory(moraKey, ItemType.material, availableMora);
      await dataService.calculator.addSessionItem(session.key, char, []);

      var expectedQuantityMap = <int, int>{
        0: charRequiredMora,
        1: 0,
      };

      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getNumberOfItemsUsedByCalcKeyItemKeyAndType(kvp.key, moraKey, ItemType.material);
        expect(usedMora, kvp.value);
      }

      await dataService.calculator.addSessionItem(session.key, weapon, []);

      final int quantity = dataService.inventory.getItemQuantityFromInventory(moraKey, ItemType.material);
      expect(availableMora, quantity);
      final int used = dataService.inventory.getNumberOfItemsUsed(moraKey, ItemType.material);
      expect(used, charRequiredMora + weaponRequiredMora);

      expectedQuantityMap = <int, int>{
        0: charRequiredMora,
        1: weaponRequiredMora,
      };
      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getNumberOfItemsUsedByCalcKeyItemKeyAndType(kvp.key, moraKey, ItemType.material);
        expect(usedMora, kvp.value);
      }
    });

    test('session contains 2 items but first one gets disabled', () async {
      await runItemUpdateTest(true, false);
    });

    test('session contains 2 items but first one stops using materials from inventory', () async {
      await runItemUpdateTest(false, true);
    });

    test('session contains 2 items but one gets deleted and redistribution starts from session position', () async {
      await runItemDeleteTest(false);
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

    test('no data exists, returns empty', () {
      final bk = dataService.calculator.getDataForBackup();
      expect(bk.isEmpty, isTrue);
    });

    test('data exists', () async {
      final sessionA = await dataService.calculator.createSession('A', 0);
      final sessionB = await dataService.calculator.createSession('B', 0);
      final items = [getCharacter(), getWeapon()];
      await dataService.calculator.addSessionItems(sessionB.key, items);

      final bk = dataService.calculator.getDataForBackup();
      expect(bk.length, 2);
      for (int i = 0; i < bk.length; i++) {
        final bool firstOne = i == 0;
        final session = bk[i];
        if (firstOne) {
          expect(session.items.isEmpty, isTrue);
        } else {
          expect(session.items.isNotEmpty, isTrue);
        }
        final expectedSession = firstOne ? sessionA : sessionB;
        expect(session.name, expectedSession.name);
        expect(session.position, expectedSession.position);

        for (int j = 0; j < session.items.length; j++) {
          final expectedItem = items[j];
          final gotItem = session.items[j];
          expect(gotItem.position, expectedItem.position);
          expect(gotItem.currentLevel, expectedItem.currentLevel);
          expect(gotItem.desiredLevel, expectedItem.desiredLevel);
          expect(gotItem.currentAscensionLevel, expectedItem.currentAscensionLevel);
          expect(gotItem.desiredAscensionLevel, expectedItem.desiredAscensionLevel);
          expect(gotItem.isCharacter, expectedItem.isCharacter);
          expect(gotItem.isWeapon, expectedItem.isWeapon);
          expect(gotItem.isActive, expectedItem.isActive);
          expect(gotItem.useMaterialsFromInventory, expectedItem.useMaterialsFromInventory);
          if (gotItem.isCharacter) {
            expect(gotItem.characterSkills, isNotEmpty);
            for (int j = 0; j < gotItem.characterSkills.length; j++) {
              final gotSkill = gotItem.characterSkills[j];
              final expectedSkill = expectedItem.skills[j];
              expect(gotSkill.skillKey, expectedSkill.key);
              expect(gotSkill.currentLevel, expectedSkill.currentLevel);
              expect(gotSkill.desiredLevel, expectedSkill.desiredLevel);
              expect(gotSkill.position, expectedSkill.position);
            }
          } else {
            expect(gotItem.characterSkills, isEmpty);
          }
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

    test('no data to restore and no previous data exist', () async {
      await dataService.calculator.restoreFromBackup([]);
      final count = dataService.calculator.getAllSessions().length;
      expect(count, isZero);
    });

    test('no data to restore and previous data exist', () async {
      await dataService.calculator.createSession('Restore', 0);
      await dataService.calculator.restoreFromBackup([]);
      final count = dataService.calculator.getAllSessions().length;
      expect(count, isZero);
    });

    test('there is data to restore and previous data exist', () async {
      final sessionA = await dataService.calculator.createSession('ToBeDeletedA', 0);
      final sessionB = await dataService.calculator.createSession('ToBeDeletedB', 1);
      await dataService.calculator.addSessionItem(sessionA.key, getWeapon(), []);
      await dataService.calculator.addSessionItem(sessionB.key, getCharacter(), []);

      final bk = BackupCalculatorAscMaterialsSessionModel(
        name: 'Existing',
        position: 0,
        items: [getCharacter(), getWeapon()]
            .map(
              (e) => BackupCalculatorAscMaterialsSessionItemModel(
                itemKey: e.key,
                position: e.position,
                currentLevel: e.currentLevel,
                desiredLevel: e.desiredLevel,
                currentAscensionLevel: e.currentAscensionLevel,
                desiredAscensionLevel: e.desiredAscensionLevel,
                isActive: e.isActive,
                isCharacter: e.isCharacter,
                isWeapon: e.isWeapon,
                useMaterialsFromInventory: e.useMaterialsFromInventory,
                characterSkills: e.skills
                    .map(
                      (s) => BackupCalculatorAscMaterialsSessionCharSkillItemModel(
                        skillKey: s.key,
                        currentLevel: s.currentLevel,
                        desiredLevel: s.desiredLevel,
                        position: s.position,
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
      );
      await dataService.calculator.restoreFromBackup([bk]);
      final sessions = dataService.calculator.getAllSessions();
      expect(sessions.length, 1);

      final session = sessions.first;
      expect(session.name, bk.name);
      expect(session.position, bk.position);
      expect(session.numberOfCharacters, 1);
      expect(session.numberOfWeapons, 1);

      final createdItems = dataService.calculator.getAllSessionItems(session.key);
      expect(createdItems.length, bk.items.length);
      for (int i = 0; i < createdItems.length; i++) {
        final bool firstOne = i == 0;
        final gotItem = createdItems[i];
        final expectedItem = firstOne ? bk.items.first : bk.items.last;
        expect(gotItem.key, expectedItem.itemKey);
        expect(gotItem.position, expectedItem.position);
        expect(gotItem.currentLevel, expectedItem.currentLevel);
        expect(gotItem.desiredLevel, expectedItem.desiredLevel);
        expect(gotItem.currentAscensionLevel, expectedItem.currentAscensionLevel);
        expect(gotItem.desiredAscensionLevel, expectedItem.desiredAscensionLevel);
        expect(gotItem.isCharacter, expectedItem.isCharacter);
        expect(gotItem.isWeapon, expectedItem.isWeapon);
        expect(gotItem.isActive, expectedItem.isActive);
        expect(gotItem.useMaterialsFromInventory, expectedItem.useMaterialsFromInventory);
        if (firstOne) {
          expect(gotItem.skills, isNotEmpty);
          for (int j = 0; j < gotItem.skills.length; j++) {
            final gotSkill = gotItem.skills[j];
            final expectedSkill = expectedItem.characterSkills[j];
            expect(gotSkill.key, expectedSkill.skillKey);
            expect(gotSkill.currentLevel, expectedSkill.currentLevel);
            expect(gotSkill.desiredLevel, expectedSkill.desiredLevel);
            expect(gotSkill.position, expectedSkill.position);
          }
        } else {
          expect(gotItem.skills, isEmpty);
        }
      }
    });
  });

  group('Reorder sessions', () {
    const dbFolder = '${_baseDbFolder}_reorder_sessions_tests';
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

    test('provided array is empty', () async {
      expect(dataService.calculator.reorderSessions([]), throwsArgumentError);
    });

    test('data was provided but no previous data exist', () async {
      const updated = [CalculatorSessionModel(key: 1, name: 'NA', position: 0, numberOfWeapons: 0, numberOfCharacters: 0)];
      expect(dataService.calculator.reorderSessions(updated), throwsArgumentError);
    });

    test('data was provided and previous data exists but invalid arrays', () async {
      await dataService.calculator.createSession('A', 0);
      await dataService.calculator.createSession('B', 0);
      const updated = [CalculatorSessionModel(key: 1, name: 'NA', position: 0, numberOfWeapons: 0, numberOfCharacters: 0)];
      expect(dataService.calculator.reorderSessions(updated), throwsArgumentError);
    });

    test('valid call', () async {
      final sessionA = await dataService.calculator.createSession('A', 0);
      final sessionB = await dataService.calculator.createSession('B', 1);
      await dataService.calculator.reorderSessions([sessionB, sessionA]);

      final sessions = dataService.calculator.getAllSessions();
      expect(sessions.first.key, sessionB.key);
      expect(sessions.last.key, sessionA.key);
    });
  });

  group('Reorder items', () {
    const dbFolder = '${_baseDbFolder}_reorder_items_tests';
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

    test('session key is not valid', () async {
      expect(dataService.calculator.reorderItems(-1, []), throwsArgumentError);
    });

    test('session does not exist', () async {
      expect(dataService.calculator.reorderItems(666, []), throwsArgumentError);
    });

    test('provided data is empty', () async {
      final session = await dataService.calculator.createSession('Dummy', 0);
      expect(dataService.calculator.reorderItems(session.key, []), throwsArgumentError);
    });

    test('data was provided but no previous data exist', () async {
      final session = await dataService.calculator.createSession('Dummy', 0);
      final updated = [getCharacter()];
      expect(dataService.calculator.reorderItems(session.key, updated), throwsArgumentError);
    });

    test('data was provided and previous data exists but invalid arrays', () async {
      final session = await dataService.calculator.createSession('A', 0);
      await dataService.calculator.addSessionItems(session.key, [getCharacter(), getWeapon()]);
      final updated = [getCharacter()];
      expect(dataService.calculator.reorderItems(session.key, updated), throwsArgumentError);
    });

    test('valid call', () async {
      final session = await dataService.calculator.createSession('A', 0);
      await dataService.calculator.addSessionItems(session.key, [getCharacter(), getWeapon()]);
      final updated = [getWeapon(), getCharacter()];
      await dataService.calculator.reorderItems(session.key, updated);

      final items = dataService.calculator.getAllSessionItems(session.key);
      expect(items.first.key, updated.first.key);
      expect(items.last.key, updated.last.key);
    });
  });
}
