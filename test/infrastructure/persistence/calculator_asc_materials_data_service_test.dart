import 'dart:math';

import 'package:darq/darq.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
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
    final materials = calculatorService.getCharacterMaterialsToUse(
      char,
      currentLevel,
      desiredLevel,
      currentAscLevel,
      desiredAscLevel,
      skills,
    );
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
    final materials = calculatorService.getWeaponMaterialsToUse(
      weapon,
      currentLevel,
      desiredLevel,
      currentAscLevel,
      desiredAscLevel,
    );
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
    expect(got.key, expected.key, reason: 'Should match expected value (property=key)');
    expect(got.position, expected.position, reason: 'Should match expected value (property=position)');
    expect(got.currentLevel, expected.currentLevel, reason: 'Should match expected value (property=currentLevel)');
    expect(got.desiredLevel, expected.desiredLevel, reason: 'Should match expected value (property=desiredLevel)');
    expect(got.currentAscensionLevel, expected.currentAscensionLevel, reason: 'Should match expected value (property=currentAscensionLevel)');
    expect(got.desiredAscensionLevel, expected.desiredAscensionLevel, reason: 'Should match expected value (property=desiredAscensionLevel)');
    expect(got.isCharacter, expected.isCharacter, reason: 'Should match expected value (property=isCharacter)');
    expect(got.isWeapon, expected.isWeapon, reason: 'Should match expected value (property=isWeapon)');
    expect(got.isActive, expected.isActive, reason: 'Should match expected value (property=isActive)');
    expect(got.useMaterialsFromInventory, expected.useMaterialsFromInventory, reason: 'Should match expected value (property=useMaterialsFromInventory)');
    if (expected.isCharacter) {
      expect(expected.skills, isNotEmpty, reason: 'Should not be empty (property=skills)');
      for (int j = 0; j < got.skills.length; j++) {
        final gotSkill = got.skills[j];
        final expectedSkill = expected.skills[j];
        expect(gotSkill.key, expectedSkill.key, reason: 'Should match expected value (property=key)');
        expect(gotSkill.currentLevel, expectedSkill.currentLevel, reason: 'Should match expected value (property=currentLevel)');
        expect(gotSkill.desiredLevel, expectedSkill.desiredLevel, reason: 'Should match expected value (property=desiredLevel)');
        expect(gotSkill.position, expectedSkill.position, reason: 'Should match expected value (property=position)');
      }
    } else {
      expect(got.skills, isEmpty, reason: 'Should be empty (property=skills)');
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
      expect(sessions.isEmpty, isTrue, reason: 'Should be true');
    });

    test('data exists', () async {
      await dataService.calculator.createSession('Dummy', 0, true);
      final sessions = dataService.calculator.getAllSessions();
      expect(sessions.length, 1, reason: 'Should match expected value (expected=1)');
      final session = sessions.first;
      expect(session.key >= 0, isTrue, reason: 'Should be true (property=key >= 0, isTrue)');
      expect(session.name, 'Dummy', reason: 'Should match expected value (property=name, expected=\'Dummy\')');
      expect(session.showMaterialUsage, isTrue, reason: 'Should be true (property=showMaterialUsage)');
      expect(session.position, 0, reason: 'Should match expected value (property=position, expected=0)');
      expect(session.numberOfCharacters, 0, reason: 'Should match expected value (property=numberOfCharacters, expected=0)');
      expect(session.numberOfWeapons, 0, reason: 'Should match expected value (property=numberOfWeapons, expected=0)');
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
      expect(() => dataService.calculator.getSession(-1), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('key does not exist', () {
      expect(() => dataService.calculator.getSession(666), throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
    });

    test('key exists', () async {
      final createdSession = await dataService.calculator.createSession('Exists', 0, false);
      final existingSession = dataService.calculator.getSession(createdSession.key);
      expect(existingSession.key, createdSession.key, reason: 'Should match expected value (property=key)');
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
      expect(dataService.calculator.createSession('', 0, false), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('position is not valid', () {
      expect(dataService.calculator.createSession('New', -1, false), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('valid call', () async {
      final createdSession = await dataService.calculator.createSession('New', 1, true);
      expect(createdSession.key >= 0, isTrue, reason: 'Should be true (property=key >= 0, isTrue)');
      expect(createdSession.name, 'New', reason: 'Should match expected value (property=name, expected=\'New\')');
      expect(createdSession.position, 1, reason: 'Should match expected value (property=position, expected=1)');
      expect(createdSession.showMaterialUsage, isTrue, reason: 'Should be true (property=showMaterialUsage)');
      expect(createdSession.numberOfCharacters, 0, reason: 'Should match expected value (property=numberOfCharacters, expected=0)');
      expect(createdSession.numberOfWeapons, 0, reason: 'Should match expected value (property=numberOfWeapons, expected=0)');
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
      expect(dataService.calculator.updateSession(-1, 'Updated', false), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('name is not valid', () {
      expect(dataService.calculator.updateSession(1, '', false), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('session does not exist', () {
      expect(dataService.calculator.updateSession(1, 'Updated', false), throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
    });

    test('valid call', () async {
      final existing = await dataService.calculator.createSession('New', 1, false);
      final updated = await dataService.calculator.updateSession(existing.key, 'Updated', true);
      expect(updated.key, existing.key, reason: 'Should match expected value (property=key)');
      expect(updated.name, 'Updated', reason: 'Should match expected value (property=name, expected=\'Updated\')');
      expect(updated.position, existing.position, reason: 'Should match expected value (property=position)');
      expect(updated.showMaterialUsage, isTrue, reason: 'Should be true (property=showMaterialUsage)');
      expect(updated.numberOfCharacters, 0, reason: 'Should match expected value (property=numberOfCharacters, expected=0)');
      expect(updated.numberOfWeapons, 0, reason: 'Should match expected value (property=numberOfWeapons, expected=0)');
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
      expect(dataService.calculator.deleteSession(-1), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('session does not exist', () {
      const int key = 666;
      expect(() => dataService.calculator.getSession(key), throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
      expect(dataService.calculator.deleteSession(key), completes, reason: 'Should match expected value (property=deleteSession(key))');
    });

    test('session exists, and gets deleted', () async {
      final session = await dataService.calculator.createSession('Deleted', 0, false);
      expect(() => dataService.calculator.getSession(session.key), returnsNormally, reason: 'Should execute without throwing');
      await dataService.calculator.deleteSession(session.key);
      expect(() => dataService.calculator.getSession(session.key), throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
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
      expect(sessions.isEmpty, isTrue, reason: 'Should be true');
    });

    test('data exists and gets deleted', () async {
      await dataService.calculator.createSession('To be deleted', 5, false);
      await dataService.calculator.deleteAllSessions();
      final sessions = dataService.calculator.getAllSessions();
      expect(sessions.isEmpty, isTrue, reason: 'Should be true');
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
      expect(() => dataService.calculator.getAllSessionItems(-1), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('no data exists, returns empty', () {
      final items = dataService.calculator.getAllSessionItems(666);
      expect(items.isEmpty, isTrue, reason: 'Should be true');
    });

    test('data exists', () async {
      final session = await dataService.calculator.createSession('NewOne', 1, false);
      final charItem = getCharacter();
      final weaponItem = getWeapon();
      final items = <ItemAscensionMaterials>[charItem, weaponItem];
      await dataService.calculator.addSessionItems(session.key, items);
      expect(items.length, items.length, reason: 'Should match expected value');
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
      expect(dataService.calculator.addSessionItem(-1, getCharacter(), []), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('session does not exist', () {
      expect(dataService.calculator.addSessionItem(666, getCharacter(), []), throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
    });

    test('of type character', () async {
      final item = getCharacter();
      final session = await dataService.calculator.createSession('Characters', 1, false);
      await dataService.calculator.addSessionItem(session.key, item, []);
      final items = dataService.calculator.getAllSessionItems(session.key);
      expect(items.length, 1, reason: 'Should match expected value (expected=1)');
      checkSessionItem(items.first, item);
    });

    test('of type weapon', () async {
      final item = getWeapon();
      final session = await dataService.calculator.createSession('Weapons', 1, false);
      await dataService.calculator.addSessionItem(session.key, item, []);
      final items = dataService.calculator.getAllSessionItems(session.key);
      expect(items.length, 1, reason: 'Should match expected value (expected=1)');
      checkSessionItem(items.first, item);
    });

    test('of type character and weapon', () async {
      final charItem = getCharacter();
      final weaponItem = getWeapon();
      final items = [charItem, weaponItem];
      final session = await dataService.calculator.createSession('Chars&Weapons', 1, false);
      await dataService.calculator.addSessionItems(session.key, items);
      final existing = dataService.calculator.getAllSessionItems(session.key);
      expect(existing.length, 2, reason: 'Should match expected value (expected=2)');
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

      expect(requiredMaterials.isNotEmpty, isTrue, reason: 'Should be true');
      for (final kvp in requiredMaterials) {
        await dataService.inventory.addMaterialToInventory(kvp.key, kvp.value);
      }

      final session = await dataService.calculator.createSession('Chars&WeaponsFromInv', 1, false);
      await dataService.calculator.addSessionItems(session.key, [charItem, weaponItem]);
      final existing = dataService.calculator.getAllSessionItems(session.key);

      expect(existing.length, 2, reason: 'Should match expected value (expected=2)');
      checkSessionItem(existing.first, charItem);
      checkSessionItem(existing.last, weaponItem);

      for (final kvp in requiredMaterials) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(kvp.key, ItemType.material);
        expect(kvp.value, quantity, reason: 'Should match expected value (property=value)');

        final int used = dataService.inventory.getUsedMaterialQuantity(kvp.key);
        expect(kvp.value, used, reason: 'Should match expected value (property=value)');
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
      expect(dataService.calculator.updateSessionItem(-1, 1, getCharacter(), []), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('position is not valid', () {
      expect(dataService.calculator.updateSessionItem(1, -1, getCharacter(), []), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('session does not exist', () {
      expect(dataService.calculator.updateSessionItem(666, 1, getCharacter(), []), throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
    });

    test('item does not exist thus a new one gets created', () async {
      final itemChar = getCharacter().copyWith(position: 2);
      final session = await dataService.calculator.createSession('UpdateItem', 0, false);
      await dataService.calculator.updateSessionItem(session.key, itemChar.position, itemChar, []);
      final items = dataService.calculator.getAllSessionItems(session.key);
      expect(items.length, 1, reason: 'Should match expected value (expected=1)');

      final got = items.first;
      checkSessionItem(got, itemChar);
    });

    test('item exists thus it gets recreated', () async {
      final session = await dataService.calculator.createSession('UpdateItem', 0, false);
      await dataService.calculator.addSessionItem(session.key, getCharacter(), []);

      final updated = getCharacter().copyWith(desiredLevel: 80);
      await dataService.calculator.updateSessionItem(session.key, 5, updated, []);
      final items = dataService.calculator.getAllSessionItems(session.key);
      expect(items.length, 1, reason: 'Should match expected value (expected=1)');

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
      expect(dataService.calculator.deleteSessionItem(-1, 1), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('position is not valid', () {
      expect(dataService.calculator.deleteSessionItem(1, -1), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('which does not exist, returns normally', () {
      expect(dataService.calculator.deleteSessionItem(666, 666), completes, reason: 'Should match expected value (property=deleteSessionItem(666, 666))');
    });

    test('which exists and it gets deleted', () async {
      final item = getWeapon();
      final session = await dataService.calculator.createSession('Item Deleted', 0, false);
      await dataService.calculator.addSessionItem(session.key, item, []);
      final currentCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(currentCount, 1, reason: 'Should match expected value (expected=1)');

      await dataService.calculator.deleteSessionItem(session.key, item.position);
      final newCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(newCount, 0, reason: 'Should match expected value (expected=0)');
    });

    test('which exists and it was using materials from inventory', () async {
      final session = await dataService.calculator.createSession('Item Deleted', 0, false);
      final item = getWeapon(useMaterialsFromInventory: true);
      final requiredMaterials = item.materials
          .groupBy((g) => g.key)
          .map(
            (g) => MapEntry<String, int>(g.key, g.map((e) => e.requiredQuantity).sum()),
          )
          .toList();

      expect(requiredMaterials.isNotEmpty, isTrue, reason: 'Should be true');
      for (final kvp in requiredMaterials) {
        await dataService.inventory.addMaterialToInventory(kvp.key, kvp.value);
      }

      await dataService.calculator.addSessionItem(session.key, item, []);
      final currentCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(currentCount, 1, reason: 'Should match expected value (expected=1)');
      for (final kvp in requiredMaterials) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(kvp.key, ItemType.material);
        expect(kvp.value, quantity, reason: 'Should match expected value (property=value)');

        final int used = dataService.inventory.getUsedMaterialQuantity(kvp.key);
        expect(kvp.value, used, reason: 'Should match expected value (property=value)');
      }

      await dataService.calculator.deleteSessionItem(session.key, item.position);
      final newCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(newCount, 0, reason: 'Should match expected value (expected=0)');
      for (final kvp in requiredMaterials) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(kvp.key, ItemType.material);
        expect(kvp.value, quantity, reason: 'Should match expected value (property=value)');

        final int used = dataService.inventory.getUsedMaterialQuantity(kvp.key);
        expect(used, 0, reason: 'Should match expected value (expected=0)');
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
      expect(dataService.calculator.deleteAllSessionItems(-1), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('session does not exist, returns normally', () {
      expect(dataService.calculator.deleteAllSessionItems(666), completes, reason: 'Should match expected value (property=deleteAllSessionItems(666))');
    });

    test('session exists but it is empty, returns normally', () async {
      final session = await dataService.calculator.createSession('Delete all items', 0, false);
      expect(dataService.calculator.deleteAllSessionItems(session.key), completes, reason: 'Should match expected value (property=key))');
    });

    test('session exists and it is not empty, all items gets deleted', () async {
      final session = await dataService.calculator.createSession('Delete all items', 0, false);
      await dataService.calculator.addSessionItems(session.key, [getCharacter(), getWeapon()]);
      final currentCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(currentCount, 2, reason: 'Should match expected value (expected=2)');

      await dataService.calculator.deleteAllSessionItems(session.key);
      final newCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(newCount, 0, reason: 'Should match expected value (expected=0)');
    });

    test('session exists, it is not empty and items were using materials from inventory', () async {
      final items = [getCharacter(useMaterialsFromInventory: true), getWeapon(useMaterialsFromInventory: true)];
      final requiredMaterials = items
          .selectMany((e, _) => e.materials)
          .groupBy((g) => g.key)
          .map((g) => MapEntry<String, int>(g.key, g.map((e) => e.requiredQuantity).sum()))
          .toList();

      expect(requiredMaterials.isNotEmpty, isTrue, reason: 'Should be true');
      for (final kvp in requiredMaterials) {
        await dataService.inventory.addMaterialToInventory(kvp.key, kvp.value);
      }

      final session = await dataService.calculator.createSession('Delete all items', 0, false);
      await dataService.calculator.addSessionItems(session.key, items);
      final currentCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(currentCount, 2, reason: 'Should match expected value (expected=2)');
      for (final kvp in requiredMaterials) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(kvp.key, ItemType.material);
        expect(kvp.value, quantity, reason: 'Should match expected value (property=value)');

        final int used = dataService.inventory.getUsedMaterialQuantity(kvp.key);
        expect(kvp.value, used, reason: 'Should match expected value (property=value)');
      }

      await dataService.calculator.deleteAllSessionItems(session.key);
      final newCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(newCount, 0, reason: 'Should match expected value (expected=0)');
      for (final kvp in requiredMaterials) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(kvp.key, ItemType.material);
        expect(kvp.value, quantity, reason: 'Should match expected value (property=value)');

        final int used = dataService.inventory.getUsedMaterialQuantity(kvp.key);
        expect(used, 0, reason: 'Should match expected value (expected=0)');
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
      final sessionA = await dataService.calculator.createSession('RedistributeA', 0, false);
      final sessionB = await dataService.calculator.createSession('RedistributeB', 1, false);

      final items = [getCharacter(useMaterialsFromInventory: true), getWeapon(useMaterialsFromInventory: true)];
      final requiredMaterials = items
          .selectMany((e, _) => e.materials)
          .groupBy((g) => g.key)
          .map(
            (g) => MapEntry<String, int>(g.key, g.map((e) => e.requiredQuantity).sum()),
          )
          .toList();

      expect(requiredMaterials.isNotEmpty, isTrue, reason: 'Should be true');
      for (final kvp in requiredMaterials) {
        await dataService.inventory.addMaterialToInventory(kvp.key, kvp.value);
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
        expect(kvp.value, quantity, reason: 'Should match expected value (property=value)');

        final int used = dataService.inventory.getUsedMaterialQuantity(kvp.key);
        expect(used, kvp.value, reason: 'Should match expected value');
      }
    }

    Future<void> runItemDeleteTest(bool redistributeOnDelete) async {
      final session = await dataService.calculator.createSession('Redistribute', 0, false);

      final char = getCharacter(useMaterialsFromInventory: true);
      final weapon = getWeapon(useMaterialsFromInventory: true);
      final items = [char, weapon];
      final int availableMora = max(
        char.materials.where((g) => g.key == moraKey).first.requiredQuantity,
        weapon.materials.where((g) => g.key == moraKey).first.requiredQuantity,
      );

      await dataService.inventory.addMaterialToInventory(moraKey, availableMora);
      await dataService.calculator.addSessionItems(session.key, items);
      await dataService.calculator.deleteSessionItem(session.key, char.position, redistribute: redistributeOnDelete);

      if (!redistributeOnDelete) {
        await dataService.calculator.redistributeInventoryMaterialsFromSessionPosition(session.key);
      }

      final int quantity = dataService.inventory.getItemQuantityFromInventory(moraKey, ItemType.material);
      expect(availableMora, quantity, reason: 'Should match expected value');

      final int used = dataService.inventory.getUsedMaterialQuantity(moraKey);
      expect(used, weapon.materials.firstWhere((el) => el.key == moraKey).requiredQuantity, reason: 'Should match expected value');
    }

    Future<void> runItemUpdateTest(bool useMaterialsFromInventory, bool isActive) async {
      final session = await dataService.calculator.createSession('Redistribute', 0, false);

      final char = getCharacter(useMaterialsFromInventory: true);
      final weapon = getWeapon(useMaterialsFromInventory: true);
      final items = [char, weapon];
      int availableMora = min(
        char.materials.where((g) => g.key == moraKey).first.requiredQuantity,
        weapon.materials.where((g) => g.key == moraKey).first.requiredQuantity,
      );
      availableMora ~/= 2;

      await dataService.inventory.addMaterialToInventory(moraKey, availableMora);
      await dataService.calculator.addSessionItems(session.key, items);

      var expectedQuantityMap = <int, int>{
        0: availableMora,
        1: 0,
      };

      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(kvp.key, moraKey);
        expect(usedMora, kvp.value, reason: 'Should match expected value');
      }

      await dataService.calculator.updateSessionItem(
        session.key,
        char.position,
        char.copyWith(isActive: isActive, useMaterialsFromInventory: useMaterialsFromInventory),
        [],
      );

      final int quantity = dataService.inventory.getItemQuantityFromInventory(moraKey, ItemType.material);
      expect(availableMora, quantity, reason: 'Should match expected value');
      final int used = dataService.inventory.getUsedMaterialQuantity(moraKey);
      expect(used, availableMora, reason: 'Should match expected value');

      expectedQuantityMap = <int, int>{
        0: 0,
        1: availableMora,
      };
      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(kvp.key, moraKey);
        expect(usedMora, kvp.value, reason: 'Should match expected value');
      }
    }

    test('2 sessions contains same items but the first session gets deleted', () async {
      await runItemsDeletedTest(true);
    });

    test('2 sessions contains same items but the items in the first one gets deleted', () async {
      await runItemsDeletedTest(false);
    });

    test('2 sessions contains 2 items with same used material but session order changes', () async {
      final sessionA = await dataService.calculator.createSession('RedistributeA', 0, false);
      final sessionB = await dataService.calculator.createSession('RedistributeB', 1, false);

      final char = getCharacter(useMaterialsFromInventory: true);
      final weapon = getWeapon(useMaterialsFromInventory: true);
      final items = [char, weapon];
      int availableMora = min(
        char.materials.where((g) => g.key == moraKey).first.requiredQuantity,
        weapon.materials.where((g) => g.key == moraKey).first.requiredQuantity,
      );
      availableMora ~/= 2;
      await dataService.inventory.addMaterialToInventory(moraKey, availableMora);

      await dataService.calculator.addSessionItems(sessionA.key, items);
      await dataService.calculator.addSessionItems(sessionB.key, items);

      final int quantity = dataService.inventory.getItemQuantityFromInventory(moraKey, ItemType.material);
      expect(availableMora, quantity, reason: 'Should match expected value');
      final int used = dataService.inventory.getUsedMaterialQuantity(moraKey);
      expect(used, availableMora, reason: 'Should match expected value');

      var expectedQuantityMap = <int, int>{
        0: availableMora,
        1: 0,
        2: 0,
        3: 0,
      };
      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(kvp.key, moraKey);
        expect(usedMora, kvp.value, reason: 'Should match expected value');
      }

      await dataService.calculator.reorderSessions([sessionB, sessionA]);

      expectedQuantityMap = <int, int>{
        0: 0,
        1: 0,
        2: availableMora,
        3: 0,
      };
      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(kvp.key, moraKey);
        expect(usedMora, kvp.value, reason: 'Should match expected value');
      }
    });

    test('session contains 2 items with same used material but one gets deleted', () async {
      await runItemDeleteTest(true);
    });

    test('session contains 2 items with same used material but item order changes', () async {
      final session = await dataService.calculator.createSession('Redistribute', 0, false);

      final char = getCharacter(useMaterialsFromInventory: true);
      final weapon = getWeapon(useMaterialsFromInventory: true);
      final items = [char, weapon];
      int availableMora = min(
        char.materials.where((g) => g.key == moraKey).first.requiredQuantity,
        weapon.materials.where((g) => g.key == moraKey).first.requiredQuantity,
      );
      availableMora ~/= 2;

      await dataService.inventory.addMaterialToInventory(moraKey, availableMora);
      await dataService.calculator.addSessionItems(session.key, items);

      var expectedQuantityMap = <int, int>{
        0: availableMora,
        1: 0,
      };

      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(kvp.key, moraKey);
        expect(usedMora, kvp.value, reason: 'Should match expected value');
      }

      await dataService.calculator.reorderItems(session.key, [weapon, char]);

      final int quantity = dataService.inventory.getItemQuantityFromInventory(moraKey, ItemType.material);
      expect(availableMora, quantity, reason: 'Should match expected value');
      final int used = dataService.inventory.getUsedMaterialQuantity(moraKey);
      expect(used, availableMora, reason: 'Should match expected value');

      expectedQuantityMap = <int, int>{
        0: 0,
        1: availableMora,
      };
      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(kvp.key, moraKey);
        expect(usedMora, kvp.value, reason: 'Should match expected value');
      }
    });

    test('session contains 1 item but a new item gets added that uses same materials', () async {
      final session = await dataService.calculator.createSession('Redistribute', 0, false);

      final char = getCharacter(useMaterialsFromInventory: true);
      final int charRequiredMora = char.materials.where((g) => g.key == moraKey).first.requiredQuantity;
      final weapon = getWeapon(useMaterialsFromInventory: true);
      final int weaponRequiredMora = weapon.materials.where((g) => g.key == moraKey).first.requiredQuantity;
      final int availableMora = 2 * max(charRequiredMora, weaponRequiredMora);

      await dataService.inventory.addMaterialToInventory(moraKey, availableMora);
      await dataService.calculator.addSessionItem(session.key, char, []);

      var expectedQuantityMap = <int, int>{
        0: charRequiredMora,
        1: 0,
      };

      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(kvp.key, moraKey);
        expect(usedMora, kvp.value, reason: 'Should match expected value');
      }

      await dataService.calculator.addSessionItem(session.key, weapon, []);

      final int quantity = dataService.inventory.getItemQuantityFromInventory(moraKey, ItemType.material);
      expect(availableMora, quantity, reason: 'Should match expected value');
      final int used = dataService.inventory.getUsedMaterialQuantity(moraKey);
      expect(used, charRequiredMora + weaponRequiredMora, reason: 'Should match expected value');

      expectedQuantityMap = <int, int>{
        0: charRequiredMora,
        1: weaponRequiredMora,
      };
      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(kvp.key, moraKey);
        expect(usedMora, kvp.value, reason: 'Should match expected value');
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
      expect(bk.isEmpty, isTrue, reason: 'Should be true');
    });

    test('data exists', () async {
      final sessionA = await dataService.calculator.createSession('A', 0, false);
      final sessionB = await dataService.calculator.createSession('B', 0, false);
      final items = [getCharacter(), getWeapon()];
      await dataService.calculator.addSessionItems(sessionB.key, items);

      final bk = dataService.calculator.getDataForBackup();
      expect(bk.length, 2, reason: 'Should match expected value (expected=2)');
      for (int i = 0; i < bk.length; i++) {
        final bool firstOne = i == 0;
        final session = bk[i];
        if (firstOne) {
          expect(session.items.isEmpty, isTrue, reason: 'Should be true (property=items)');
        } else {
          expect(session.items.isNotEmpty, isTrue, reason: 'Should be true (property=items)');
        }
        final expectedSession = firstOne ? sessionA : sessionB;
        expect(session.name, expectedSession.name, reason: 'Should match expected value (property=name)');
        expect(session.position, expectedSession.position, reason: 'Should match expected value (property=position)');

        for (int j = 0; j < session.items.length; j++) {
          final expectedItem = items[j];
          final gotItem = session.items[j];
          expect(gotItem.position, expectedItem.position, reason: 'Should match expected value (property=position)');
          expect(gotItem.currentLevel, expectedItem.currentLevel, reason: 'Should match expected value (property=currentLevel)');
          expect(gotItem.desiredLevel, expectedItem.desiredLevel, reason: 'Should match expected value (property=desiredLevel)');
          expect(gotItem.currentAscensionLevel, expectedItem.currentAscensionLevel, reason: 'Should match expected value (property=currentAscensionLevel)');
          expect(gotItem.desiredAscensionLevel, expectedItem.desiredAscensionLevel, reason: 'Should match expected value (property=desiredAscensionLevel)');
          expect(gotItem.isCharacter, expectedItem.isCharacter, reason: 'Should match expected value (property=isCharacter)');
          expect(gotItem.isWeapon, expectedItem.isWeapon, reason: 'Should match expected value (property=isWeapon)');
          expect(gotItem.isActive, expectedItem.isActive, reason: 'Should match expected value (property=isActive)');
          expect(gotItem.useMaterialsFromInventory, expectedItem.useMaterialsFromInventory, reason: 'Should match expected value (property=useMaterialsFromInventory)');
          if (gotItem.isCharacter) {
            expect(gotItem.characterSkills, isNotEmpty, reason: 'Should not be empty (property=characterSkills)');
            for (int j = 0; j < gotItem.characterSkills.length; j++) {
              final gotSkill = gotItem.characterSkills[j];
              final expectedSkill = expectedItem.skills[j];
              expect(gotSkill.skillKey, expectedSkill.key, reason: 'Should match expected value (property=skillKey)');
              expect(gotSkill.currentLevel, expectedSkill.currentLevel, reason: 'Should match expected value (property=currentLevel)');
              expect(gotSkill.desiredLevel, expectedSkill.desiredLevel, reason: 'Should match expected value (property=desiredLevel)');
              expect(gotSkill.position, expectedSkill.position, reason: 'Should match expected value (property=position)');
            }
          } else {
            expect(gotItem.characterSkills, isEmpty, reason: 'Should be empty (property=characterSkills)');
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
      expect(count, isZero, reason: 'Should match expected value');
    });

    test('no data to restore and previous data exist', () async {
      await dataService.calculator.createSession('Restore', 0, false);
      await dataService.calculator.restoreFromBackup([]);
      final count = dataService.calculator.getAllSessions().length;
      expect(count, isZero, reason: 'Should match expected value');
    });

    test('there is data to restore and previous data exist', () async {
      final sessionA = await dataService.calculator.createSession('ToBeDeletedA', 0, false);
      final sessionB = await dataService.calculator.createSession('ToBeDeletedB', 1, false);
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
      expect(sessions.length, 1, reason: 'Should match expected value (expected=1)');

      final session = sessions.first;
      expect(session.name, bk.name, reason: 'Should match expected value (property=name)');
      expect(session.position, bk.position, reason: 'Should match expected value (property=position)');
      expect(session.numberOfCharacters, 1, reason: 'Should match expected value (property=numberOfCharacters, expected=1)');
      expect(session.numberOfWeapons, 1, reason: 'Should match expected value (property=numberOfWeapons, expected=1)');

      final createdItems = dataService.calculator.getAllSessionItems(session.key);
      expect(createdItems.length, bk.items.length, reason: 'Should match expected value');
      for (int i = 0; i < createdItems.length; i++) {
        final bool firstOne = i == 0;
        final gotItem = createdItems[i];
        final expectedItem = firstOne ? bk.items.first : bk.items.last;
        expect(gotItem.key, expectedItem.itemKey, reason: 'Should match expected value (property=key)');
        expect(gotItem.position, expectedItem.position, reason: 'Should match expected value (property=position)');
        expect(gotItem.currentLevel, expectedItem.currentLevel, reason: 'Should match expected value (property=currentLevel)');
        expect(gotItem.desiredLevel, expectedItem.desiredLevel, reason: 'Should match expected value (property=desiredLevel)');
        expect(gotItem.currentAscensionLevel, expectedItem.currentAscensionLevel, reason: 'Should match expected value (property=currentAscensionLevel)');
        expect(gotItem.desiredAscensionLevel, expectedItem.desiredAscensionLevel, reason: 'Should match expected value (property=desiredAscensionLevel)');
        expect(gotItem.isCharacter, expectedItem.isCharacter, reason: 'Should match expected value (property=isCharacter)');
        expect(gotItem.isWeapon, expectedItem.isWeapon, reason: 'Should match expected value (property=isWeapon)');
        expect(gotItem.isActive, expectedItem.isActive, reason: 'Should match expected value (property=isActive)');
        expect(gotItem.useMaterialsFromInventory, expectedItem.useMaterialsFromInventory, reason: 'Should match expected value (property=useMaterialsFromInventory)');
        if (firstOne) {
          expect(gotItem.skills, isNotEmpty, reason: 'Should not be empty (property=skills)');
          for (int j = 0; j < gotItem.skills.length; j++) {
            final gotSkill = gotItem.skills[j];
            final expectedSkill = expectedItem.characterSkills[j];
            expect(gotSkill.key, expectedSkill.skillKey, reason: 'Should match expected value (property=key)');
            expect(gotSkill.currentLevel, expectedSkill.currentLevel, reason: 'Should match expected value (property=currentLevel)');
            expect(gotSkill.desiredLevel, expectedSkill.desiredLevel, reason: 'Should match expected value (property=desiredLevel)');
            expect(gotSkill.position, expectedSkill.position, reason: 'Should match expected value (property=position)');
          }
        } else {
          expect(gotItem.skills, isEmpty, reason: 'Should be empty (property=skills)');
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

    test('provided array is empty', () {
      expect(dataService.calculator.reorderSessions([]), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('data was provided but no previous data exist', () {
      const updated = [
        CalculatorSessionModel(
          key: 1,
          name: 'NA',
          position: 0,
          numberOfWeapons: 0,
          numberOfCharacters: 0,
          showMaterialUsage: false,
        ),
      ];
      expect(dataService.calculator.reorderSessions(updated), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('data was provided and previous data exists but invalid arrays', () async {
      await dataService.calculator.createSession('A', 0, false);
      await dataService.calculator.createSession('B', 0, false);
      const updated = [
        CalculatorSessionModel(
          key: 1,
          name: 'NA',
          position: 0,
          numberOfWeapons: 0,
          numberOfCharacters: 0,
          showMaterialUsage: false,
        ),
      ];
      expect(dataService.calculator.reorderSessions(updated), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('valid call', () async {
      final sessionA = await dataService.calculator.createSession('A', 0, false);
      final sessionB = await dataService.calculator.createSession('B', 1, false);
      await dataService.calculator.reorderSessions([sessionB, sessionA]);

      final sessions = dataService.calculator.getAllSessions();
      expect(sessions.first.key, sessionB.key, reason: 'Should match expected value (property=key)');
      expect(sessions.last.key, sessionA.key, reason: 'Should match expected value (property=key)');
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

    test('session key is not valid', () {
      expect(dataService.calculator.reorderItems(-1, []), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('session does not exist', () {
      expect(dataService.calculator.reorderItems(666, []), throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
    });

    test('provided data is empty', () async {
      final session = await dataService.calculator.createSession('Dummy', 0, false);
      expect(dataService.calculator.reorderItems(session.key, []), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('data was provided but no previous data exist', () async {
      final session = await dataService.calculator.createSession('Dummy', 0, false);
      final updated = [getCharacter()];
      expect(dataService.calculator.reorderItems(session.key, updated), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('data was provided and previous data exists but invalid arrays', () async {
      final session = await dataService.calculator.createSession('A', 0, false);
      await dataService.calculator.addSessionItems(session.key, [getCharacter(), getWeapon()]);
      final updated = [getCharacter()];
      expect(dataService.calculator.reorderItems(session.key, updated), throwsArgumentError, reason: 'Should throw expected exception');
    });

    test('valid call', () async {
      final session = await dataService.calculator.createSession('A', 0, false);
      await dataService.calculator.addSessionItems(session.key, [getCharacter(), getWeapon()]);
      final updated = [getWeapon(), getCharacter()];
      await dataService.calculator.reorderItems(session.key, updated);

      final items = dataService.calculator.getAllSessionItems(session.key);
      expect(items.first.key, updated.first.key, reason: 'Should match expected value (property=key)');
      expect(items.last.key, updated.last.key, reason: 'Should match expected value (property=key)');
    });
  });
}
