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
    expect(got.key, expected.key, reason: 'Persisted session item key must round-trip (expected=${expected.key})');
    expect(
      got.position,
      expected.position,
      reason: 'Persisted session item position must round-trip (key=${expected.key}, expected=${expected.position})',
    );
    expect(
      got.currentLevel,
      expected.currentLevel,
      reason: 'Persisted currentLevel must round-trip (key=${expected.key}, expected=${expected.currentLevel})',
    );
    expect(
      got.desiredLevel,
      expected.desiredLevel,
      reason: 'Persisted desiredLevel must round-trip (key=${expected.key}, expected=${expected.desiredLevel})',
    );
    expect(
      got.currentAscensionLevel,
      expected.currentAscensionLevel,
      reason: 'Persisted currentAscensionLevel must round-trip '
          '(key=${expected.key}, expected=${expected.currentAscensionLevel})',
    );
    expect(
      got.desiredAscensionLevel,
      expected.desiredAscensionLevel,
      reason: 'Persisted desiredAscensionLevel must round-trip '
          '(key=${expected.key}, expected=${expected.desiredAscensionLevel})',
    );
    expect(
      got.isCharacter,
      expected.isCharacter,
      reason: 'Persisted isCharacter flag must round-trip (key=${expected.key}, expected=${expected.isCharacter})',
    );
    expect(
      got.isWeapon,
      expected.isWeapon,
      reason: 'Persisted isWeapon flag must round-trip (key=${expected.key}, expected=${expected.isWeapon})',
    );
    expect(
      got.isActive,
      expected.isActive,
      reason: 'Persisted isActive flag must round-trip (key=${expected.key}, expected=${expected.isActive})',
    );
    expect(
      got.useMaterialsFromInventory,
      expected.useMaterialsFromInventory,
      reason: 'Persisted useMaterialsFromInventory flag must round-trip '
          '(key=${expected.key}, expected=${expected.useMaterialsFromInventory})',
    );
    if (expected.isCharacter) {
      expect(
        expected.skills,
        isNotEmpty,
        reason: 'A character session item must carry at least one skill (key=${expected.key})',
      );
      for (int j = 0; j < got.skills.length; j++) {
        final gotSkill = got.skills[j];
        final expectedSkill = expected.skills[j];
        expect(
          gotSkill.key,
          expectedSkill.key,
          reason: 'Persisted skill key must round-trip (itemKey=${expected.key}, expected=${expectedSkill.key})',
        );
        expect(
          gotSkill.currentLevel,
          expectedSkill.currentLevel,
          reason: 'Persisted skill currentLevel must round-trip '
              '(itemKey=${expected.key}, skill=${expectedSkill.key}, expected=${expectedSkill.currentLevel})',
        );
        expect(
          gotSkill.desiredLevel,
          expectedSkill.desiredLevel,
          reason: 'Persisted skill desiredLevel must round-trip '
              '(itemKey=${expected.key}, skill=${expectedSkill.key}, expected=${expectedSkill.desiredLevel})',
        );
        expect(
          gotSkill.position,
          expectedSkill.position,
          reason: 'Persisted skill position must round-trip '
              '(itemKey=${expected.key}, skill=${expectedSkill.key}, expected=${expectedSkill.position})',
        );
      }
    } else {
      expect(
        got.skills,
        isEmpty,
        reason: 'A weapon session item must carry no skills (key=${expected.key})',
      );
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
      expect(sessions, isEmpty, reason: 'getAllSessions must return no sessions when none were created');
    });

    test('data exists', () async {
      await dataService.calculator.createSession('Dummy', 0, true);
      final sessions = dataService.calculator.getAllSessions();
      expect(sessions.length, 1, reason: 'getAllSessions must return the single created session');
      final session = sessions.first;
      expect(session.key, greaterThanOrEqualTo(0), reason: 'Created session must have a non-negative Hive key');
      expect(session.name, 'Dummy', reason: 'Persisted session name must round-trip (expected=Dummy)');
      expect(session.showMaterialUsage, isTrue, reason: 'Session created with showMaterialUsage=true must persist it');
      expect(session.position, 0, reason: 'Persisted session position must round-trip (expected=0)');
      expect(session.numberOfCharacters, 0, reason: 'A freshly created session must contain no characters');
      expect(session.numberOfWeapons, 0, reason: 'A freshly created session must contain no weapons');
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
      expect(
        () => dataService.calculator.getSession(-1),
        throwsArgumentError,
        reason: 'getSession must reject a negative key (-1) with ArgumentError',
      );
    });

    test('key does not exist', () {
      expect(
        () => dataService.calculator.getSession(666),
        throwsA(isA<NotFoundError>()),
        reason: 'getSession must throw NotFoundError for an absent key (666)',
      );
    });

    test('key exists', () async {
      final createdSession = await dataService.calculator.createSession('Exists', 0, false);
      final existingSession = dataService.calculator.getSession(createdSession.key);
      expect(
        existingSession.key,
        createdSession.key,
        reason: 'getSession must return the session matching the created key (${createdSession.key})',
      );
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
      expect(
        dataService.calculator.createSession('', 0, false),
        throwsArgumentError,
        reason: 'createSession must reject an empty name with ArgumentError',
      );
    });

    test('position is not valid', () {
      expect(
        dataService.calculator.createSession('New', -1, false),
        throwsArgumentError,
        reason: 'createSession must reject a negative position (-1) with ArgumentError',
      );
    });

    test('valid call', () async {
      final createdSession = await dataService.calculator.createSession('New', 1, true);
      expect(createdSession.key, greaterThanOrEqualTo(0), reason: 'Created session must have a non-negative Hive key');
      expect(createdSession.name, 'New', reason: 'Created session must keep the provided name (expected=New)');
      expect(createdSession.position, 1, reason: 'Created session must keep the provided position (expected=1)');
      expect(
        createdSession.showMaterialUsage,
        isTrue,
        reason: 'Session created with showMaterialUsage=true must persist it',
      );
      expect(
        createdSession.numberOfCharacters,
        0,
        reason: 'A freshly created session must contain no characters',
      );
      expect(createdSession.numberOfWeapons, 0, reason: 'A freshly created session must contain no weapons');
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
      expect(
        dataService.calculator.updateSession(-1, 'Updated', false),
        throwsArgumentError,
        reason: 'updateSession must reject a negative key (-1) with ArgumentError',
      );
    });

    test('name is not valid', () {
      expect(
        dataService.calculator.updateSession(1, '', false),
        throwsArgumentError,
        reason: 'updateSession must reject an empty name with ArgumentError',
      );
    });

    test('session does not exist', () {
      expect(
        dataService.calculator.updateSession(1, 'Updated', false),
        throwsA(isA<NotFoundError>()),
        reason: 'updateSession must throw NotFoundError for an absent key (1)',
      );
    });

    test('valid call', () async {
      final existing = await dataService.calculator.createSession('New', 1, false);
      final updated = await dataService.calculator.updateSession(existing.key, 'Updated', true);
      expect(updated.key, existing.key, reason: 'updateSession must keep the same key (${existing.key})');
      expect(updated.name, 'Updated', reason: 'updateSession must apply the new name (expected=Updated)');
      expect(
        updated.position,
        existing.position,
        reason: 'updateSession must leave position unchanged (expected=${existing.position})',
      );
      expect(updated.showMaterialUsage, isTrue, reason: 'updateSession must apply showMaterialUsage=true');
      expect(updated.numberOfCharacters, 0, reason: 'Updating an empty session must leave zero characters');
      expect(updated.numberOfWeapons, 0, reason: 'Updating an empty session must leave zero weapons');
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
      expect(
        dataService.calculator.deleteSession(-1),
        throwsArgumentError,
        reason: 'deleteSession must reject a negative key (-1) with ArgumentError',
      );
    });

    test('session does not exist', () {
      const int key = 666;
      expect(
        () => dataService.calculator.getSession(key),
        throwsA(isA<NotFoundError>()),
        reason: 'getSession must throw NotFoundError for an absent key ($key)',
      );
      expect(
        dataService.calculator.deleteSession(key),
        completes,
        reason: 'deleteSession must complete without error for an absent key ($key)',
      );
    });

    test('session exists, and gets deleted', () async {
      final session = await dataService.calculator.createSession('Deleted', 0, false);
      expect(
        () => dataService.calculator.getSession(session.key),
        returnsNormally,
        reason: 'Created session (key=${session.key}) must be retrievable before deletion',
      );
      await dataService.calculator.deleteSession(session.key);
      expect(
        () => dataService.calculator.getSession(session.key),
        throwsA(isA<NotFoundError>()),
        reason: 'getSession must throw NotFoundError after the session (key=${session.key}) was deleted',
      );
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
      expect(sessions, isEmpty, reason: 'deleteAllSessions on an empty store must leave zero sessions');
    });

    test('data exists and gets deleted', () async {
      await dataService.calculator.createSession('To be deleted', 5, false);
      await dataService.calculator.deleteAllSessions();
      final sessions = dataService.calculator.getAllSessions();
      expect(sessions, isEmpty, reason: 'deleteAllSessions must remove every previously created session');
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
      expect(
        () => dataService.calculator.getAllSessionItems(-1),
        throwsArgumentError,
        reason: 'getAllSessionItems must reject a negative session key (-1) with ArgumentError',
      );
    });

    test('no data exists, returns empty', () {
      final items = dataService.calculator.getAllSessionItems(666);
      expect(items, isEmpty, reason: 'getAllSessionItems must return no items for an absent session key (666)');
    });

    test('data exists', () async {
      final session = await dataService.calculator.createSession('NewOne', 1, false);
      final charItem = getCharacter();
      final weaponItem = getWeapon();
      final items = <ItemAscensionMaterials>[charItem, weaponItem];
      await dataService.calculator.addSessionItems(session.key, items);
      expect(
        items.length,
        items.length,
        reason: 'Session ${session.key} must hold the added char+weapon items (expected=${items.length})',
      );
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
      expect(
        dataService.calculator.addSessionItem(-1, getCharacter(), []),
        throwsArgumentError,
        reason: 'addSessionItem must reject a negative session key (-1) with ArgumentError',
      );
    });

    test('session does not exist', () {
      expect(
        dataService.calculator.addSessionItem(666, getCharacter(), []),
        throwsA(isA<NotFoundError>()),
        reason: 'addSessionItem must throw NotFoundError for an absent session key (666)',
      );
    });

    test('of type character', () async {
      final item = getCharacter();
      final session = await dataService.calculator.createSession('Characters', 1, false);
      await dataService.calculator.addSessionItem(session.key, item, []);
      final items = dataService.calculator.getAllSessionItems(session.key);
      expect(items.length, 1, reason: 'Session ${session.key} must hold exactly the one added character item');
      checkSessionItem(items.first, item);
    });

    test('of type weapon', () async {
      final item = getWeapon();
      final session = await dataService.calculator.createSession('Weapons', 1, false);
      await dataService.calculator.addSessionItem(session.key, item, []);
      final items = dataService.calculator.getAllSessionItems(session.key);
      expect(items.length, 1, reason: 'Session ${session.key} must hold exactly the one added weapon item');
      checkSessionItem(items.first, item);
    });

    test('of type character and weapon', () async {
      final charItem = getCharacter();
      final weaponItem = getWeapon();
      final items = [charItem, weaponItem];
      final session = await dataService.calculator.createSession('Chars&Weapons', 1, false);
      await dataService.calculator.addSessionItems(session.key, items);
      final existing = dataService.calculator.getAllSessionItems(session.key);
      expect(existing.length, 2, reason: 'Session ${session.key} must hold both added items (character + weapon)');
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

      expect(
        requiredMaterials,
        isNotEmpty,
        reason: 'Ascension of a char + weapon must require at least one material to drive this test',
      );
      for (final kvp in requiredMaterials) {
        await dataService.inventory.addMaterialToInventory(kvp.key, kvp.value);
      }

      final session = await dataService.calculator.createSession('Chars&WeaponsFromInv', 1, false);
      await dataService.calculator.addSessionItems(session.key, [charItem, weaponItem]);
      final existing = dataService.calculator.getAllSessionItems(session.key);

      expect(existing.length, 2, reason: 'Session ${session.key} must hold both added items (character + weapon)');
      checkSessionItem(existing.first, charItem);
      checkSessionItem(existing.last, weaponItem);

      for (final kvp in requiredMaterials) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(kvp.key, ItemType.material);
        expect(
          quantity,
          kvp.value,
          reason: 'Inventory stock of ${kvp.key} must stay at what was added (expected=${kvp.value})',
        );

        final int used = dataService.inventory.getUsedMaterialQuantity(kvp.key);
        expect(
          used,
          kvp.value,
          reason: 'Items using inventory must reserve all of ${kvp.key} (expected used=${kvp.value})',
        );
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
      expect(
        dataService.calculator.updateSessionItem(-1, 1, getCharacter(), []),
        throwsArgumentError,
        reason: 'updateSessionItem must reject a negative session key (-1) with ArgumentError',
      );
    });

    test('position is not valid', () {
      expect(
        dataService.calculator.updateSessionItem(1, -1, getCharacter(), []),
        throwsArgumentError,
        reason: 'updateSessionItem must reject a negative item position (-1) with ArgumentError',
      );
    });

    test('session does not exist', () {
      expect(
        dataService.calculator.updateSessionItem(666, 1, getCharacter(), []),
        throwsA(isA<NotFoundError>()),
        reason: 'updateSessionItem must throw NotFoundError for an absent session key (666)',
      );
    });

    test('item does not exist thus a new one gets created', () async {
      final itemChar = getCharacter().copyWith(position: 2);
      final session = await dataService.calculator.createSession('UpdateItem', 0, false);
      await dataService.calculator.updateSessionItem(session.key, itemChar.position, itemChar, []);
      final items = dataService.calculator.getAllSessionItems(session.key);
      expect(
        items.length,
        1,
        reason: 'updateSessionItem on a missing position (${itemChar.position}) must insert one new item',
      );

      final got = items.first;
      checkSessionItem(got, itemChar);
    });

    test('item exists thus it gets recreated', () async {
      final session = await dataService.calculator.createSession('UpdateItem', 0, false);
      await dataService.calculator.addSessionItem(session.key, getCharacter(), []);

      final updated = getCharacter().copyWith(desiredLevel: 80);
      await dataService.calculator.updateSessionItem(session.key, 5, updated, []);
      final items = dataService.calculator.getAllSessionItems(session.key);
      expect(
        items.length,
        1,
        reason: 'updateSessionItem must replace, not append, leaving a single item in the session',
      );

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
      expect(
        dataService.calculator.deleteSessionItem(-1, 1),
        throwsArgumentError,
        reason: 'deleteSessionItem must reject a negative session key (-1) with ArgumentError',
      );
    });

    test('position is not valid', () {
      expect(
        dataService.calculator.deleteSessionItem(1, -1),
        throwsArgumentError,
        reason: 'deleteSessionItem must reject a negative item position (-1) with ArgumentError',
      );
    });

    test('which does not exist, returns normally', () {
      expect(
        dataService.calculator.deleteSessionItem(666, 666),
        completes,
        reason: 'deleteSessionItem must complete without error for an absent session/position (666, 666)',
      );
    });

    test('which exists and it gets deleted', () async {
      final item = getWeapon();
      final session = await dataService.calculator.createSession('Item Deleted', 0, false);
      await dataService.calculator.addSessionItem(session.key, item, []);
      final currentCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(currentCount, 1, reason: 'Session ${session.key} must hold the one added item before deletion');

      await dataService.calculator.deleteSessionItem(session.key, item.position);
      final newCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(newCount, 0, reason: 'Session ${session.key} must hold no items after its only item was deleted');
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

      expect(
        requiredMaterials,
        isNotEmpty,
        reason: 'Weapon ascension must require at least one material to drive this test',
      );
      for (final kvp in requiredMaterials) {
        await dataService.inventory.addMaterialToInventory(kvp.key, kvp.value);
      }

      await dataService.calculator.addSessionItem(session.key, item, []);
      final currentCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(currentCount, 1, reason: 'Session ${session.key} must hold the one added item before deletion');
      for (final kvp in requiredMaterials) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(kvp.key, ItemType.material);
        expect(
          quantity,
          kvp.value,
          reason: 'Inventory stock of ${kvp.key} must stay at what was added (expected=${kvp.value})',
        );

        final int used = dataService.inventory.getUsedMaterialQuantity(kvp.key);
        expect(
          used,
          kvp.value,
          reason: 'Item using inventory must reserve all of ${kvp.key} while present (expected used=${kvp.value})',
        );
      }

      await dataService.calculator.deleteSessionItem(session.key, item.position);
      final newCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(newCount, 0, reason: 'Session ${session.key} must hold no items after its only item was deleted');
      for (final kvp in requiredMaterials) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(kvp.key, ItemType.material);
        expect(
          quantity,
          kvp.value,
          reason: 'Deleting an item must not change inventory stock of ${kvp.key} (expected=${kvp.value})',
        );

        final int used = dataService.inventory.getUsedMaterialQuantity(kvp.key);
        expect(used, 0, reason: 'Deleting the item must release all reserved ${kvp.key} (expected used=0)');
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
      expect(
        dataService.calculator.deleteAllSessionItems(-1),
        throwsArgumentError,
        reason: 'deleteAllSessionItems must reject a negative session key (-1) with ArgumentError',
      );
    });

    test('session does not exist, returns normally', () {
      expect(
        dataService.calculator.deleteAllSessionItems(666),
        completes,
        reason: 'deleteAllSessionItems must complete without error for an absent session key (666)',
      );
    });

    test('session exists but it is empty, returns normally', () async {
      final session = await dataService.calculator.createSession('Delete all items', 0, false);
      expect(
        dataService.calculator.deleteAllSessionItems(session.key),
        completes,
        reason: 'deleteAllSessionItems must complete without error on an empty session (key=${session.key})',
      );
    });

    test('session exists and it is not empty, all items gets deleted', () async {
      final session = await dataService.calculator.createSession('Delete all items', 0, false);
      await dataService.calculator.addSessionItems(session.key, [getCharacter(), getWeapon()]);
      final currentCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(currentCount, 2, reason: 'Session ${session.key} must hold both added items before deletion');

      await dataService.calculator.deleteAllSessionItems(session.key);
      final newCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(newCount, 0, reason: 'deleteAllSessionItems must leave session ${session.key} with no items');
    });

    test('session exists, it is not empty and items were using materials from inventory', () async {
      final items = [getCharacter(useMaterialsFromInventory: true), getWeapon(useMaterialsFromInventory: true)];
      final requiredMaterials = items
          .selectMany((e, _) => e.materials)
          .groupBy((g) => g.key)
          .map((g) => MapEntry<String, int>(g.key, g.map((e) => e.requiredQuantity).sum()))
          .toList();

      expect(
        requiredMaterials,
        isNotEmpty,
        reason: 'Ascension of a char + weapon must require at least one material to drive this test',
      );
      for (final kvp in requiredMaterials) {
        await dataService.inventory.addMaterialToInventory(kvp.key, kvp.value);
      }

      final session = await dataService.calculator.createSession('Delete all items', 0, false);
      await dataService.calculator.addSessionItems(session.key, items);
      final currentCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(currentCount, 2, reason: 'Session ${session.key} must hold both added items before deletion');
      for (final kvp in requiredMaterials) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(kvp.key, ItemType.material);
        expect(
          quantity,
          kvp.value,
          reason: 'Inventory stock of ${kvp.key} must stay at what was added (expected=${kvp.value})',
        );

        final int used = dataService.inventory.getUsedMaterialQuantity(kvp.key);
        expect(
          used,
          kvp.value,
          reason: 'Items using inventory must reserve all of ${kvp.key} while present (expected used=${kvp.value})',
        );
      }

      await dataService.calculator.deleteAllSessionItems(session.key);
      final newCount = dataService.calculator.getAllSessionItems(session.key).length;
      expect(newCount, 0, reason: 'deleteAllSessionItems must leave session ${session.key} with no items');
      for (final kvp in requiredMaterials) {
        final int quantity = dataService.inventory.getItemQuantityFromInventory(kvp.key, ItemType.material);
        expect(
          quantity,
          kvp.value,
          reason: 'Deleting all items must not change inventory stock of ${kvp.key} (expected=${kvp.value})',
        );

        final int used = dataService.inventory.getUsedMaterialQuantity(kvp.key);
        expect(used, 0, reason: 'Deleting all items must release all reserved ${kvp.key} (expected used=0)');
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

      expect(
        requiredMaterials,
        isNotEmpty,
        reason: 'Ascension of a char + weapon must require at least one material to drive this test',
      );
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
        expect(
          quantity,
          kvp.value,
          reason: 'Inventory stock of ${kvp.key} must be unchanged by removing sessionA (expected=${kvp.value})',
        );

        final int used = dataService.inventory.getUsedMaterialQuantity(kvp.key);
        expect(
          used,
          kvp.value,
          reason: 'Surviving sessionB must still reserve ${kvp.key} after sessionA removal (used=${kvp.value})',
        );
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
      expect(
        quantity,
        availableMora,
        reason: 'Deleting the character must not change mora stock (expected=$availableMora)',
      );

      final int used = dataService.inventory.getUsedMaterialQuantity(moraKey);
      expect(
        used,
        weapon.materials.firstWhere((el) => el.key == moraKey).requiredQuantity,
        reason: 'After deleting the character, only the surviving weapon must reserve mora',
      );
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
        expect(
          usedMora,
          kvp.value,
          reason: 'Before update, item at calcKey=${kvp.key} must reserve mora=${kvp.value} (first item claims all)',
        );
      }

      await dataService.calculator.updateSessionItem(
        session.key,
        char.position,
        char.copyWith(isActive: isActive, useMaterialsFromInventory: useMaterialsFromInventory),
        [],
      );

      final int quantity = dataService.inventory.getItemQuantityFromInventory(moraKey, ItemType.material);
      expect(
        quantity,
        availableMora,
        reason: 'Updating the item must not change total mora stock (expected=$availableMora)',
      );
      final int used = dataService.inventory.getUsedMaterialQuantity(moraKey);
      expect(
        used,
        availableMora,
        reason: 'Total reserved mora must still equal available stock after update (expected=$availableMora)',
      );

      expectedQuantityMap = <int, int>{
        0: 0,
        1: availableMora,
      };
      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(kvp.key, moraKey);
        expect(
          usedMora,
          kvp.value,
          reason: 'After char disabled/opted-out, mora must shift to calcKey=${kvp.key} (expected=${kvp.value})',
        );
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
      expect(
        quantity,
        availableMora,
        reason: 'Adding items must not change total mora stock (expected=$availableMora)',
      );
      final int used = dataService.inventory.getUsedMaterialQuantity(moraKey);
      expect(
        used,
        availableMora,
        reason: 'Scarce mora must be fully reserved by the winning item (expected=$availableMora)',
      );

      var expectedQuantityMap = <int, int>{
        0: availableMora,
        1: 0,
        2: 0,
        3: 0,
      };
      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(kvp.key, moraKey);
        expect(
          usedMora,
          kvp.value,
          reason: 'Pre-reorder, mora reserved only by first item; calcKey=${kvp.key} expects ${kvp.value}',
        );
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
        expect(
          usedMora,
          kvp.value,
          reason: 'After moving sessionB first, mora must follow to calcKey=${kvp.key} (expected=${kvp.value})',
        );
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
        expect(
          usedMora,
          kvp.value,
          reason: 'Pre-reorder, mora reserved only by first item; calcKey=${kvp.key} expects ${kvp.value}',
        );
      }

      await dataService.calculator.reorderItems(session.key, [weapon, char]);

      final int quantity = dataService.inventory.getItemQuantityFromInventory(moraKey, ItemType.material);
      expect(
        quantity,
        availableMora,
        reason: 'Reordering items must not change total mora stock (expected=$availableMora)',
      );
      final int used = dataService.inventory.getUsedMaterialQuantity(moraKey);
      expect(
        used,
        availableMora,
        reason: 'Total reserved mora must stay at available stock after reorder (expected=$availableMora)',
      );

      expectedQuantityMap = <int, int>{
        0: 0,
        1: availableMora,
      };
      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(kvp.key, moraKey);
        expect(
          usedMora,
          kvp.value,
          reason: 'After moving the weapon first, mora must follow to calcKey=${kvp.key} (expected=${kvp.value})',
        );
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
        expect(
          usedMora,
          kvp.value,
          reason: 'With only the character added, calcKey=${kvp.key} must reserve mora=${kvp.value}',
        );
      }

      await dataService.calculator.addSessionItem(session.key, weapon, []);

      final int quantity = dataService.inventory.getItemQuantityFromInventory(moraKey, ItemType.material);
      expect(
        quantity,
        availableMora,
        reason: 'Adding the weapon must not change total mora stock (expected=$availableMora)',
      );
      final int used = dataService.inventory.getUsedMaterialQuantity(moraKey);
      expect(
        used,
        charRequiredMora + weaponRequiredMora,
        reason: 'With ample mora, both items must reserve their full need '
            '(expected=${charRequiredMora + weaponRequiredMora})',
      );

      expectedQuantityMap = <int, int>{
        0: charRequiredMora,
        1: weaponRequiredMora,
      };
      for (final kvp in expectedQuantityMap.entries) {
        final int usedMora = dataService.inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(kvp.key, moraKey);
        expect(
          usedMora,
          kvp.value,
          reason: 'Each item must reserve its own mora need; calcKey=${kvp.key} expects ${kvp.value}',
        );
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
      expect(bk, isEmpty, reason: 'getDataForBackup must return no sessions when none were created');
    });

    test('data exists', () async {
      final sessionA = await dataService.calculator.createSession('A', 0, false);
      final sessionB = await dataService.calculator.createSession('B', 0, false);
      final items = [getCharacter(), getWeapon()];
      await dataService.calculator.addSessionItems(sessionB.key, items);

      final bk = dataService.calculator.getDataForBackup();
      expect(bk.length, 2, reason: 'Backup must contain both created sessions (A and B)');
      for (int i = 0; i < bk.length; i++) {
        final bool firstOne = i == 0;
        final session = bk[i];
        if (firstOne) {
          expect(session.items, isEmpty, reason: 'Backup of session A must carry no items (none were added)');
        } else {
          expect(session.items, isNotEmpty, reason: 'Backup of session B must carry the items that were added');
        }
        final expectedSession = firstOne ? sessionA : sessionB;
        expect(
          session.name,
          expectedSession.name,
          reason: 'Backup session name must match source (expected=${expectedSession.name})',
        );
        expect(
          session.position,
          expectedSession.position,
          reason: 'Backup session position must match source (expected=${expectedSession.position})',
        );

        for (int j = 0; j < session.items.length; j++) {
          final expectedItem = items[j];
          final gotItem = session.items[j];
          expect(
            gotItem.position,
            expectedItem.position,
            reason: 'Backup item position must match source (key=${expectedItem.key}, pos=${expectedItem.position})',
          );
          expect(
            gotItem.currentLevel,
            expectedItem.currentLevel,
            reason: 'Backup item currentLevel must match source (key=${expectedItem.key})',
          );
          expect(
            gotItem.desiredLevel,
            expectedItem.desiredLevel,
            reason: 'Backup item desiredLevel must match source (key=${expectedItem.key})',
          );
          expect(
            gotItem.currentAscensionLevel,
            expectedItem.currentAscensionLevel,
            reason: 'Backup item currentAscensionLevel must match source (key=${expectedItem.key})',
          );
          expect(
            gotItem.desiredAscensionLevel,
            expectedItem.desiredAscensionLevel,
            reason: 'Backup item desiredAscensionLevel must match source (key=${expectedItem.key})',
          );
          expect(
            gotItem.isCharacter,
            expectedItem.isCharacter,
            reason: 'Backup item isCharacter flag must match source (key=${expectedItem.key})',
          );
          expect(
            gotItem.isWeapon,
            expectedItem.isWeapon,
            reason: 'Backup item isWeapon flag must match source (key=${expectedItem.key})',
          );
          expect(
            gotItem.isActive,
            expectedItem.isActive,
            reason: 'Backup item isActive flag must match source (key=${expectedItem.key})',
          );
          expect(
            gotItem.useMaterialsFromInventory,
            expectedItem.useMaterialsFromInventory,
            reason: 'Backup item useMaterialsFromInventory flag must match source (key=${expectedItem.key})',
          );
          if (gotItem.isCharacter) {
            expect(
              gotItem.characterSkills,
              isNotEmpty,
              reason: 'Backup of a character item must include its skills (key=${expectedItem.key})',
            );
            for (int j = 0; j < gotItem.characterSkills.length; j++) {
              final gotSkill = gotItem.characterSkills[j];
              final expectedSkill = expectedItem.skills[j];
              expect(
                gotSkill.skillKey,
                expectedSkill.key,
                reason: 'Backup skill key must match source (itemKey=${expectedItem.key}, key=${expectedSkill.key})',
              );
              expect(
                gotSkill.currentLevel,
                expectedSkill.currentLevel,
                reason: 'Backup skill currentLevel must match source (skill=${expectedSkill.key})',
              );
              expect(
                gotSkill.desiredLevel,
                expectedSkill.desiredLevel,
                reason: 'Backup skill desiredLevel must match source (skill=${expectedSkill.key})',
              );
              expect(
                gotSkill.position,
                expectedSkill.position,
                reason: 'Backup skill position must match source (skill=${expectedSkill.key})',
              );
            }
          } else {
            expect(
              gotItem.characterSkills,
              isEmpty,
              reason: 'Backup of a weapon item must include no skills (key=${expectedItem.key})',
            );
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
      expect(count, isZero, reason: 'Restoring an empty backup into an empty store must leave zero sessions');
    });

    test('no data to restore and previous data exist', () async {
      await dataService.calculator.createSession('Restore', 0, false);
      await dataService.calculator.restoreFromBackup([]);
      final count = dataService.calculator.getAllSessions().length;
      expect(count, isZero, reason: 'Restoring an empty backup must wipe pre-existing sessions, leaving zero');
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
      expect(
        sessions.length,
        1,
        reason: 'Restore must replace prior sessions with only the single backed-up session',
      );

      final session = sessions.first;
      expect(session.name, bk.name, reason: 'Restored session name must match backup (expected=${bk.name})');
      expect(
        session.position,
        bk.position,
        reason: 'Restored session position must match backup (expected=${bk.position})',
      );
      expect(session.numberOfCharacters, 1, reason: 'Restored session must report its one character item');
      expect(session.numberOfWeapons, 1, reason: 'Restored session must report its one weapon item');

      final createdItems = dataService.calculator.getAllSessionItems(session.key);
      expect(
        createdItems.length,
        bk.items.length,
        reason: 'Restored session must hold every backed-up item (expected=${bk.items.length})',
      );
      for (int i = 0; i < createdItems.length; i++) {
        final bool firstOne = i == 0;
        final gotItem = createdItems[i];
        final expectedItem = firstOne ? bk.items.first : bk.items.last;
        expect(
          gotItem.key,
          expectedItem.itemKey,
          reason: 'Restored item key must match backup (expected=${expectedItem.itemKey})',
        );
        expect(
          gotItem.position,
          expectedItem.position,
          reason: 'Restored item position must match backup (key=${expectedItem.itemKey})',
        );
        expect(
          gotItem.currentLevel,
          expectedItem.currentLevel,
          reason: 'Restored item currentLevel must match backup (key=${expectedItem.itemKey})',
        );
        expect(
          gotItem.desiredLevel,
          expectedItem.desiredLevel,
          reason: 'Restored item desiredLevel must match backup (key=${expectedItem.itemKey})',
        );
        expect(
          gotItem.currentAscensionLevel,
          expectedItem.currentAscensionLevel,
          reason: 'Restored item currentAscensionLevel must match backup (key=${expectedItem.itemKey})',
        );
        expect(
          gotItem.desiredAscensionLevel,
          expectedItem.desiredAscensionLevel,
          reason: 'Restored item desiredAscensionLevel must match backup (key=${expectedItem.itemKey})',
        );
        expect(
          gotItem.isCharacter,
          expectedItem.isCharacter,
          reason: 'Restored item isCharacter flag must match backup (key=${expectedItem.itemKey})',
        );
        expect(
          gotItem.isWeapon,
          expectedItem.isWeapon,
          reason: 'Restored item isWeapon flag must match backup (key=${expectedItem.itemKey})',
        );
        expect(
          gotItem.isActive,
          expectedItem.isActive,
          reason: 'Restored item isActive flag must match backup (key=${expectedItem.itemKey})',
        );
        expect(
          gotItem.useMaterialsFromInventory,
          expectedItem.useMaterialsFromInventory,
          reason: 'Restored item useMaterialsFromInventory flag must match backup (key=${expectedItem.itemKey})',
        );
        if (firstOne) {
          expect(
            gotItem.skills,
            isNotEmpty,
            reason: 'Restored character item must carry its skills (key=${expectedItem.itemKey})',
          );
          for (int j = 0; j < gotItem.skills.length; j++) {
            final gotSkill = gotItem.skills[j];
            final expectedSkill = expectedItem.characterSkills[j];
            expect(
              gotSkill.key,
              expectedSkill.skillKey,
              reason: 'Restored skill key must match backup (key=${expectedSkill.skillKey})',
            );
            expect(
              gotSkill.currentLevel,
              expectedSkill.currentLevel,
              reason: 'Restored skill currentLevel must match backup (skill=${expectedSkill.skillKey})',
            );
            expect(
              gotSkill.desiredLevel,
              expectedSkill.desiredLevel,
              reason: 'Restored skill desiredLevel must match backup (skill=${expectedSkill.skillKey})',
            );
            expect(
              gotSkill.position,
              expectedSkill.position,
              reason: 'Restored skill position must match backup (skill=${expectedSkill.skillKey})',
            );
          }
        } else {
          expect(
            gotItem.skills,
            isEmpty,
            reason: 'Restored weapon item must carry no skills (key=${expectedItem.itemKey})',
          );
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
      expect(
        dataService.calculator.reorderSessions([]),
        throwsArgumentError,
        reason: 'reorderSessions must reject an empty session list with ArgumentError',
      );
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
      expect(
        dataService.calculator.reorderSessions(updated),
        throwsArgumentError,
        reason: 'reorderSessions must reject a reorder whose count mismatches the (empty) stored sessions',
      );
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
      expect(
        dataService.calculator.reorderSessions(updated),
        throwsArgumentError,
        reason: 'reorderSessions must reject a 1-item reorder when 2 sessions are stored',
      );
    });

    test('valid call', () async {
      final sessionA = await dataService.calculator.createSession('A', 0, false);
      final sessionB = await dataService.calculator.createSession('B', 1, false);
      await dataService.calculator.reorderSessions([sessionB, sessionA]);

      final sessions = dataService.calculator.getAllSessions();
      expect(
        sessions.first.key,
        sessionB.key,
        reason: 'After reorder [B, A], sessionB must be first (key=${sessionB.key})',
      );
      expect(
        sessions.last.key,
        sessionA.key,
        reason: 'After reorder [B, A], sessionA must be last (key=${sessionA.key})',
      );
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
      expect(
        dataService.calculator.reorderItems(-1, []),
        throwsArgumentError,
        reason: 'reorderItems must reject a negative session key (-1) with ArgumentError',
      );
    });

    test('session does not exist', () {
      expect(
        dataService.calculator.reorderItems(666, []),
        throwsA(isA<NotFoundError>()),
        reason: 'reorderItems must throw NotFoundError for an absent session key (666)',
      );
    });

    test('provided data is empty', () async {
      final session = await dataService.calculator.createSession('Dummy', 0, false);
      expect(
        dataService.calculator.reorderItems(session.key, []),
        throwsArgumentError,
        reason: 'reorderItems must reject an empty item list for an existing session (key=${session.key})',
      );
    });

    test('data was provided but no previous data exist', () async {
      final session = await dataService.calculator.createSession('Dummy', 0, false);
      final updated = [getCharacter()];
      expect(
        dataService.calculator.reorderItems(session.key, updated),
        throwsArgumentError,
        reason: 'reorderItems must reject a 1-item reorder when the session (key=${session.key}) has no items',
      );
    });

    test('data was provided and previous data exists but invalid arrays', () async {
      final session = await dataService.calculator.createSession('A', 0, false);
      await dataService.calculator.addSessionItems(session.key, [getCharacter(), getWeapon()]);
      final updated = [getCharacter()];
      expect(
        dataService.calculator.reorderItems(session.key, updated),
        throwsArgumentError,
        reason: 'reorderItems must reject a 1-item reorder when the session (key=${session.key}) holds 2 items',
      );
    });

    test('valid call', () async {
      final session = await dataService.calculator.createSession('A', 0, false);
      await dataService.calculator.addSessionItems(session.key, [getCharacter(), getWeapon()]);
      final updated = [getWeapon(), getCharacter()];
      await dataService.calculator.reorderItems(session.key, updated);

      final items = dataService.calculator.getAllSessionItems(session.key);
      expect(
        items.first.key,
        updated.first.key,
        reason: 'After reorder, first item must be the weapon (${updated.first.key})',
      );
      expect(
        items.last.key,
        updated.last.key,
        reason: 'After reorder, last item must be the character (${updated.last.key})',
      );
    });
  });
}
