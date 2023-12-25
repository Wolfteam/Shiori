import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/check.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_asc_materials_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/persistence/calculator_asc_materials_data_service.dart';
import 'package:shiori/domain/services/persistence/inventory_data_service.dart';
import 'package:shiori/domain/services/resources_service.dart';

class CalculatorAscMaterialsDataServiceImpl implements CalculatorAscMaterialsDataService {
  final GenshinService _genshinService;
  final CalculatorAscMaterialsService _calculatorService;
  final InventoryDataService _inventory;
  final ResourceService _resourceService;

  late Box<CalculatorSession> _sessionBox;
  late Box<CalculatorItem> _calcItemBox;
  late Box<CalculatorCharacterSkill> _calcItemSkillBox;

  @override
  final StreamController<CalculatorAscMaterialSessionItemEvent> itemAdded = StreamController.broadcast();

  @override
  final StreamController<CalculatorAscMaterialSessionItemEvent> itemDeleted = StreamController.broadcast();

  CalculatorAscMaterialsDataServiceImpl(this._genshinService, this._calculatorService, this._inventory, this._resourceService);

  @override
  Future<void> init() async {
    _sessionBox = await Hive.openBox<CalculatorSession>('calculatorSessions');
    _calcItemBox = await Hive.openBox<CalculatorItem>('calculatorSessionsItems');
    _calcItemSkillBox = await Hive.openBox<CalculatorCharacterSkill>('calculatorSessionsItemsSkills');
  }

  @override
  Future<void> deleteThemAll() async {
    await _sessionBox.clear();
    await _calcItemBox.clear();
    await _calcItemSkillBox.clear();
  }

  @override
  List<CalculatorSessionModel> getAllSessions() {
    final sessions = _sessionBox.values.toList()..sort((x, y) => x.position.compareTo(y.position));
    final result = <CalculatorSessionModel>[];

    for (final session in sessions) {
      result.add(getSession(session.id));
    }

    return result;
  }

  @override
  CalculatorSessionModel getSession(int sessionKey) {
    Check.greaterThanOrEqualToZero(sessionKey, 'sessionKey');

    final CalculatorSession? session = _sessionBox.values.firstWhereOrNull((el) => el.key == sessionKey);
    if (session == null) {
      throw NotFoundError(sessionKey, 'sessionKey', 'Session does not exist');
    }

    final calcItems = _calcItemBox.values.where((el) => el.sessionKey == session.key).toList()..sort((x, y) => x.position.compareTo(y.position));
    int numberOfCharacters = 0;
    int numberOfWeapons = 0;
    for (final calItem in calcItems) {
      if (calItem.isCharacter) {
        numberOfCharacters++;
        continue;
      }

      if (calItem.isWeapon) {
        numberOfWeapons++;
        continue;
      }

      throw Exception('The provided item with key = ${calItem.key} is not neither a character nor weapon');
    }

    return CalculatorSessionModel(
      key: session.id,
      name: session.name,
      position: session.position,
      showMaterialUsage: session.showMaterialUsage ?? false,
      numberOfCharacters: numberOfCharacters,
      numberOfWeapons: numberOfWeapons,
    );
  }

  @override
  Future<CalculatorSessionModel> createSession(String name, int position, bool showMaterialUsage) async {
    Check.notEmpty(name, 'name');
    Check.greaterThanOrEqualToZero(position, 'position');

    final session = CalculatorSession(name, position, showMaterialUsage);
    final key = await _sessionBox.add(session);
    return CalculatorSessionModel(
      key: key,
      name: name,
      position: position,
      showMaterialUsage: showMaterialUsage,
      numberOfCharacters: 0,
      numberOfWeapons: 0,
    );
  }

  @override
  Future<CalculatorSessionModel> updateSession(int sessionKey, String name, bool showMaterialUsage) async {
    Check.greaterThanOrEqualToZero(sessionKey, 'sessionKey');
    Check.notEmpty(name, 'name');

    final CalculatorSession? session = _sessionBox.get(sessionKey);
    if (session == null) {
      throw NotFoundError(sessionKey, 'sessionKey', 'Session does not exist');
    }

    session.name = name;
    session.showMaterialUsage = showMaterialUsage;
    await session.save();

    return getSession(sessionKey);
  }

  @override
  Future<void> deleteSession(int sessionKey) async {
    Check.greaterThanOrEqualToZero(sessionKey, 'sessionKey');

    final onlyMaterialKeys = <String>[];
    final calItems = _calcItemBox.values.where((el) => el.sessionKey == sessionKey).toList();
    for (int i = 0; i < calItems.length; i++) {
      final calcItem = calItems[i];
      final usedItemKeys = _inventory.getUsedMaterialKeysByCalcKey(calcItem.id);
      onlyMaterialKeys.addAll(usedItemKeys);
      await deleteSessionItem(sessionKey, calcItem.position, redistribute: false);
    }

    if (calItems.isNotEmpty) {
      await redistributeAllInventoryMaterials(onlyMaterialKeys: onlyMaterialKeys);
    }
    await _sessionBox.delete(sessionKey);
  }

  @override
  Future<void> deleteAllSessions() async {
    //First we clear the used items in the inventory (if any)
    await _inventory.deleteAllUsedInventoryItems();

    //Finally we delete them all
    await deleteThemAll();
  }

  @override
  List<ItemAscensionMaterials> getAllSessionItems(int sessionKey) {
    Check.greaterThanOrEqualToZero(sessionKey, 'sessionKey');

    final items = <ItemAscensionMaterials>[];
    final calcItems = _calcItemBox.values.where((el) => el.sessionKey == sessionKey).toList()..sort((x, y) => x.position.compareTo(y.position));
    for (final calItem in calcItems) {
      if (calItem.isCharacter) {
        items.add(_buildForCharacter(calItem, calculatorItemKey: calItem.id, includeInventory: true));
        continue;
      }

      if (calItem.isWeapon) {
        items.add(_buildForWeapon(calItem, calculatorItemKey: calItem.id, includeInventory: true));
        continue;
      }

      throw Exception('The provided item with key = ${calItem.key} is not neither a character nor weapon');
    }

    return items;
  }

  @override
  Future<void> addSessionItems(int sessionKey, List<ItemAscensionMaterials> items, {bool redistributeAtTheEnd = true}) async {
    Check.greaterThanOrEqualToZero(sessionKey, 'sessionKey');
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final redistribute = i + 1 == items.length && redistributeAtTheEnd;
      await addSessionItem(sessionKey, item, [], redistribute: redistribute);
    }
  }

  @override
  Future<ItemAscensionMaterials> addSessionItem(
    int sessionKey,
    ItemAscensionMaterials item,
    List<String> allPossibleItemMaterialsKeys, {
    bool redistribute = true,
  }) async {
    Check.greaterThanOrEqualToZero(sessionKey, 'sessionKey');
    _checkSessionKey(sessionKey);

    final mappedItem = _toCalculatorItem(sessionKey, item);

    final calculatorItemKey = await _calcItemBox.add(mappedItem);
    final skills = item.skills.map((e) => CalculatorCharacterSkill(calculatorItemKey, e.key, e.currentLevel, e.desiredLevel, e.position)).toList();
    await _calcItemSkillBox.addAll(skills);

    itemAdded.add(CalculatorAscMaterialSessionItemEvent.created(sessionKey, calculatorItemKey, item.isCharacter));

    //Here we created a used inventory item for each material
    if (mappedItem.useMaterialsFromInventory && mappedItem.isActive) {
      for (final material in item.materials) {
        await _inventory.useMaterialFromInventory(calculatorItemKey, material.key, material.requiredQuantity);
      }
    }

    if (!redistribute) {
      return item;
    }
    //Since we added a new item, we need to redistribute
    //the materials because the priority of this item could be higher than the others
    //await redistributeInventoryMaterialsFromSessionPosition(sessionKey, onlyMaterialKeys: allPossibleItemMaterialsKeys);
    await redistributeAllInventoryMaterials(onlyMaterialKeys: allPossibleItemMaterialsKeys);

    //And finally update the material quantity based on the used inventory items
    final updatedMaterials = _considerMaterialsInInventory(calculatorItemKey, item.materials);

    return item.copyWith.call(materials: updatedMaterials);
  }

  @override
  Future<ItemAscensionMaterials> updateSessionItem(
    int sessionKey,
    int newItemPosition,
    ItemAscensionMaterials item,
    List<String> allPossibleItemMaterialsKeys, {
    bool redistribute = true,
  }) async {
    Check.greaterThanOrEqualToZero(sessionKey, 'sessionKey');
    Check.greaterThanOrEqualToZero(newItemPosition, 'newItemPosition');
    _checkSessionKey(sessionKey);

    await deleteSessionItem(sessionKey, item.position, redistribute: false);
    return addSessionItem(
      sessionKey,
      item.copyWith.call(position: newItemPosition),
      allPossibleItemMaterialsKeys,
      redistribute: redistribute,
    );
  }

  @override
  Future<void> deleteSessionItem(int sessionKey, int position, {bool redistribute = true}) async {
    Check.greaterThanOrEqualToZero(sessionKey, 'sessionKey');
    Check.greaterThanOrEqualToZero(position, 'position');

    final calcItem = _calcItemBox.values.firstWhereOrNull((el) => el.sessionKey == sessionKey && el.position == position);
    if (calcItem == null) {
      return;
    }
    final int calcItemKey = calcItem.id;
    final skillsKeys = _calcItemSkillBox.values.where((el) => el.calculatorItemKey == calcItemKey).map((e) => e.key).toList();
    await _calcItemSkillBox.deleteAll(skillsKeys);

    //Make sure we delete the item before redistributing
    itemDeleted.add(CalculatorAscMaterialSessionItemEvent.deleted(sessionKey, calcItemKey, calcItem.isCharacter));
    await _calcItemBox.delete(calcItemKey);

    final usedItemKeys = _inventory.getUsedMaterialKeysByCalcKey(calcItemKey);

    await _inventory.clearUsedInventoryItems(calcItemKey);

    if (redistribute) {
      await redistributeAllInventoryMaterials(onlyMaterialKeys: usedItemKeys);
    }
  }

  @override
  Future<void> deleteAllSessionItems(int sessionKey) async {
    Check.greaterThanOrEqualToZero(sessionKey, 'sessionKey');

    final calcItems = _calcItemBox.values.where((el) => el.sessionKey == sessionKey);
    if (calcItems.isEmpty) {
      return;
    }

    final onlyMaterialKeys = <String>[];
    for (final calcItem in calcItems) {
      final int calcItemKey = calcItem.id;
      final skillsKeys = _calcItemSkillBox.values.where((el) => el.calculatorItemKey == calcItemKey).map((e) => e.key).toList();
      await _calcItemSkillBox.deleteAll(skillsKeys);

      //Make sure we delete the item before redistributing
      itemDeleted.add(CalculatorAscMaterialSessionItemEvent.deleted(sessionKey, calcItemKey, calcItem.isCharacter));
      await _calcItemBox.delete(calcItemKey);

      final usedItemKeys = _inventory.getUsedMaterialKeysByCalcKey(calcItemKey);
      onlyMaterialKeys.addAll(usedItemKeys);

      await _inventory.clearUsedInventoryItems(calcItemKey);
    }

    //Only redistribute at the end of the process
    await redistributeAllInventoryMaterials(onlyMaterialKeys: onlyMaterialKeys);
  }

  @override
  Future<void> redistributeAllInventoryMaterials({List<String> onlyMaterialKeys = const <String>[]}) async {
    final checkedItems = <_RedistributeCheckedItem>[];
    final materialsInInventory = _inventory.getItemsForRedistribution(ItemType.material);
    final sessions = _sessionBox.values.toList()..sort((x, y) => x.position.compareTo(y.position));
    for (final material in materialsInInventory) {
      if (onlyMaterialKeys.isNotEmpty && !onlyMaterialKeys.contains(material.key)) {
        continue;
      }

      int currentQuantity = material.quantity;
      for (final session in sessions) {
        currentQuantity = await _redistributeInventoryMaterial(material.key, currentQuantity, session.id, checkedItems);
      }
    }
  }

  @override
  Future<void> redistributeInventoryMaterial(String itemKey, int newQuantity) async {
    Check.notEmpty(itemKey, 'itemKey');
    Check.greaterThanOrEqualToZero(newQuantity, 'newQuantity');

    final checkedItems = <_RedistributeCheckedItem>[];
    int currentQuantity = newQuantity;
    final sessions = _sessionBox.values.toList()..sort((x, y) => x.position.compareTo(y.position));
    for (final session in sessions) {
      currentQuantity = await _redistributeInventoryMaterial(itemKey, currentQuantity, session.id, checkedItems);
    }
  }

  @override
  Future<void> redistributeInventoryMaterialsFromSessionPosition(
    int sessionKey, {
    List<String> onlyMaterialKeys = const <String>[],
  }) async {
    Check.greaterThanOrEqualToZero(sessionKey, 'sessionKey');
    _checkSessionKey(sessionKey);

    final checkedItems = <_RedistributeCheckedItem>[];
    final materialsInInventory = _inventory.getItemsForRedistribution(ItemType.material);
    final fromSession = _sessionBox.values.firstWhere((s) => s.key == sessionKey);
    final until = _sessionBox.values.where((s) => s.position > fromSession.position);
    final sessions = [fromSession, ...until]..sort((x, y) => x.position.compareTo(y.position));
    for (final material in materialsInInventory) {
      if (onlyMaterialKeys.isNotEmpty && !onlyMaterialKeys.contains(material.key)) {
        continue;
      }

      int currentQuantity = material.quantity;
      for (final session in sessions) {
        currentQuantity = await _redistributeInventoryMaterial(
          material.key,
          currentQuantity,
          session.id,
          checkedItems,
          clearUsedMaterials: true,
        );
      }
    }
  }

  @override
  List<BackupCalculatorAscMaterialsSessionModel> getDataForBackup() {
    final sessions = _sessionBox.values.toList();
    final backup = <BackupCalculatorAscMaterialsSessionModel>[];
    for (final session in sessions) {
      final calcItems = _calcItemBox.values.where((el) => el.sessionKey == session.key).map(
        (calcItem) {
          final charSkills = _calcItemSkillBox.values
              .where((el) => el.calculatorItemKey == calcItem.id)
              .map(
                (e) => BackupCalculatorAscMaterialsSessionCharSkillItemModel(
                  skillKey: e.skillKey,
                  currentLevel: e.currentLevel,
                  desiredLevel: e.desiredLevel,
                  position: e.position,
                ),
              )
              .toList();
          return BackupCalculatorAscMaterialsSessionItemModel(
            itemKey: calcItem.itemKey,
            currentAscensionLevel: calcItem.currentAscensionLevel,
            currentLevel: calcItem.currentLevel,
            desiredAscensionLevel: calcItem.desiredAscensionLevel,
            desiredLevel: calcItem.desiredLevel,
            isActive: calcItem.isActive,
            isCharacter: calcItem.isCharacter,
            isWeapon: calcItem.isWeapon,
            position: calcItem.position,
            useMaterialsFromInventory: calcItem.useMaterialsFromInventory,
            characterSkills: charSkills,
          );
        },
      ).toList();
      final bk = BackupCalculatorAscMaterialsSessionModel(name: session.name, position: session.position, items: calcItems);
      backup.add(bk);
    }
    return backup;
  }

  @override
  Future<void> restoreFromBackup(List<BackupCalculatorAscMaterialsSessionModel> data) async {
    await deleteThemAll();
    for (final session in data) {
      final createdSession = await createSession(session.name, session.position, session.showMaterialUsage);
      final id = createdSession.key;
      final items = session.items.map((e) {
        if (e.isCharacter) {
          final skills = e.characterSkills
              .map(
                (s) => CharacterSkill.skill(
                  key: s.skillKey,
                  name: '',
                  position: s.position,
                  desiredLevel: s.desiredLevel,
                  currentLevel: s.currentLevel,
                  isCurrentDecEnabled: false,
                  isCurrentIncEnabled: false,
                  isDesiredDecEnabled: false,
                  isDesiredIncEnabled: false,
                ),
              )
              .toList();
          final char = _genshinService.characters.getCharacter(e.itemKey);
          final charMaterials = _calculatorService.getCharacterMaterialsToUse(
            char,
            e.currentLevel,
            e.desiredLevel,
            e.currentAscensionLevel,
            e.desiredAscensionLevel,
            skills,
          );
          return ItemAscensionMaterials.forCharacters(
            key: e.itemKey,
            name: '',
            position: e.position,
            image: '',
            rarity: 0,
            materials: charMaterials,
            currentLevel: e.currentLevel,
            desiredLevel: e.desiredLevel,
            currentAscensionLevel: e.currentAscensionLevel,
            desiredAscensionLevel: e.desiredAscensionLevel,
            useMaterialsFromInventory: e.useMaterialsFromInventory,
            skills: e.characterSkills
                .map(
                  (s) => CharacterSkill.skill(
                    key: s.skillKey,
                    name: '',
                    position: s.position,
                    desiredLevel: s.desiredLevel,
                    currentLevel: s.currentLevel,
                    isCurrentDecEnabled: false,
                    isCurrentIncEnabled: false,
                    isDesiredDecEnabled: false,
                    isDesiredIncEnabled: false,
                  ),
                )
                .toList(),
          );
        }

        final weapon = _genshinService.weapons.getWeapon(e.itemKey);
        final weaponMaterials = _calculatorService.getWeaponMaterialsToUse(
          weapon,
          e.currentLevel,
          e.desiredLevel,
          e.currentAscensionLevel,
          e.desiredAscensionLevel,
        );
        return ItemAscensionMaterials.forWeapons(
          key: e.itemKey,
          name: '',
          position: e.position,
          image: '',
          rarity: 0,
          materials: weaponMaterials,
          currentLevel: e.currentLevel,
          desiredLevel: e.desiredLevel,
          currentAscensionLevel: e.currentAscensionLevel,
          desiredAscensionLevel: e.desiredAscensionLevel,
          useMaterialsFromInventory: e.useMaterialsFromInventory,
        );
      }).toList();
      await addSessionItems(id, items, redistributeAtTheEnd: false);
    }

    await redistributeAllInventoryMaterials();
  }

  @override
  Future<void> reorderSessions(List<CalculatorSessionModel> updated) async {
    Check.notEmpty(updated, 'updated');

    final sessions = _sessionBox.values.toList()..sort((x, y) => x.position.compareTo(y.position));
    final existingKeys = sessions.map((e) => e.id).toSet().toList()..sort((x, y) => x.compareTo(y));
    final gotKeys = updated.map((e) => e.key).toSet().toList()..sort((x, y) => x.compareTo(y));

    if (!listEquals(existingKeys, gotKeys)) {
      throw ArgumentError.value(updated, 'updated', 'There are keys in the updated array not present in the other one');
    }

    bool somethingChanged = false;
    for (int i = 0; i < updated.length; i++) {
      final CalculatorSessionModel updatedSession = updated[i];
      final CalculatorSession currentSession = sessions.firstWhere((el) => el.id == updatedSession.key);
      final noPositionChange = currentSession.key == sessions[i].id && currentSession.position == sessions[i].position;
      if (noPositionChange) {
        continue;
      }

      currentSession.position = i;
      await currentSession.save();
      somethingChanged = true;
    }

    if (somethingChanged) {
      await redistributeAllInventoryMaterials();
    }
  }

  @override
  Future<void> reorderItems(int sessionKey, List<ItemAscensionMaterials> updatedItems) async {
    Check.greaterThanOrEqualToZero(sessionKey, 'sessionKey');
    _checkSessionKey(sessionKey);
    Check.notEmpty(updatedItems, 'updatedItems');

    final allPossibleMaterialItemKeys = <String>[];
    final allCalcItems = _calcItemBox.values.where((el) => el.sessionKey == sessionKey).toList()..sort((x, y) => x.position.compareTo(y.position));

    final existingKeys = allCalcItems.map((e) => e.itemKey).toSet().toList()..sort((x, y) => x.compareTo(y));
    final gotKeys = updatedItems.map((e) => e.key).toSet().toList()..sort((x, y) => x.compareTo(y));

    if (!listEquals(existingKeys, gotKeys)) {
      throw ArgumentError.value(updatedItems, 'updatedItems', 'There are keys in the updated items array not present in the other one');
    }

    for (int i = 0; i < updatedItems.length; i++) {
      final ItemAscensionMaterials updatedItem = updatedItems[i];
      final CalculatorItem currentItem = allCalcItems.firstWhere((el) => el.itemKey == updatedItem.key);
      if (currentItem.key != updatedItem.key) {
        allPossibleMaterialItemKeys.addAll(_calculatorService.getAllPossibleMaterialKeysToUse(updatedItem.key, updatedItem.isCharacter));
      }
      final noPositionChange = currentItem.key == updatedItem.key && currentItem.position == updatedItem.position;
      if (noPositionChange) {
        continue;
      }

      currentItem.position = i;
      await currentItem.save();
    }

    if (allPossibleMaterialItemKeys.isNotEmpty) {
      await _redistributeAllInventoryMaterialsOnItemsReorder(sessionKey, allPossibleMaterialItemKeys);
    }
  }

  CalculatorItem _toCalculatorItem(int sessionKey, ItemAscensionMaterials item) {
    return CalculatorItem(
      sessionKey,
      item.key,
      item.position,
      item.currentLevel,
      item.desiredLevel,
      item.currentAscensionLevel,
      item.desiredAscensionLevel,
      item.isCharacter,
      item.isWeapon,
      item.isActive,
      item.useMaterialsFromInventory,
    );
  }

  ItemAscensionMaterials _buildForCharacter(CalculatorItem item, {int? calculatorItemKey, bool includeInventory = false}) {
    final character = _genshinService.characters.getCharacter(item.itemKey);
    final translation = _genshinService.translations.getCharacterTranslation(item.itemKey);
    final skills = _calcItemSkillBox.values
        .where((s) => s.calculatorItemKey == item.key)
        .map((skill) => _buildCharacterSkill(item, skill, translation.skills.firstWhere((t) => t.key == skill.skillKey)))
        .toList();
    var materials = _calculatorService.getCharacterMaterialsToUse(
      character,
      item.currentLevel,
      item.desiredLevel,
      item.currentAscensionLevel,
      item.desiredAscensionLevel,
      skills,
    );

    if (item.useMaterialsFromInventory && item.isActive && includeInventory && calculatorItemKey != null) {
      materials = _considerMaterialsInInventory(calculatorItemKey, materials);
    }

    return ItemAscensionMaterials.forCharacters(
      key: item.itemKey,
      name: translation.name,
      image: _resourceService.getCharacterImagePath(character.image),
      elementType: character.elementType,
      rarity: character.rarity,
      materials: materials,
      currentLevel: item.currentLevel,
      desiredLevel: item.desiredLevel,
      currentAscensionLevel: item.currentAscensionLevel,
      desiredAscensionLevel: item.desiredAscensionLevel,
      skills: skills,
      isActive: item.isActive,
      position: item.position,
      isCharacter: item.isCharacter,
      isWeapon: item.isWeapon,
      useMaterialsFromInventory: item.useMaterialsFromInventory,
    );
  }

  CharacterSkill _buildCharacterSkill(CalculatorItem item, CalculatorCharacterSkill skillInDb, TranslationCharacterSkillFile skill) {
    final enableTuple = _calculatorService.isSkillEnabled(
      skillInDb.currentLevel,
      skillInDb.desiredLevel,
      item.currentAscensionLevel,
      item.desiredAscensionLevel,
      minSkillLevel,
      maxSkillLevel,
    );
    return CharacterSkill.skill(
      name: skill.title,
      currentLevel: skillInDb.currentLevel,
      desiredLevel: skillInDb.desiredLevel,
      isCurrentDecEnabled: enableTuple.$1,
      isCurrentIncEnabled: enableTuple.$2,
      isDesiredDecEnabled: enableTuple.$3,
      isDesiredIncEnabled: enableTuple.$4,
      position: skillInDb.position,
      key: skillInDb.skillKey,
    );
  }

  ItemAscensionMaterials _buildForWeapon(CalculatorItem item, {int? calculatorItemKey, bool includeInventory = false}) {
    final weapon = _genshinService.weapons.getWeapon(item.itemKey);
    final translation = _genshinService.translations.getWeaponTranslation(item.itemKey);
    var materials = _calculatorService.getWeaponMaterialsToUse(
      weapon,
      item.currentLevel,
      item.desiredLevel,
      item.currentAscensionLevel,
      item.desiredAscensionLevel,
    );

    if (item.useMaterialsFromInventory && item.isActive && includeInventory && calculatorItemKey != null) {
      materials = _considerMaterialsInInventory(calculatorItemKey, materials);
    }

    return ItemAscensionMaterials.forWeapons(
      key: item.itemKey,
      name: translation.name,
      image: _resourceService.getWeaponImagePath(weapon.image, weapon.type),
      rarity: weapon.rarity,
      materials: materials,
      currentLevel: item.currentLevel,
      desiredLevel: item.desiredLevel,
      currentAscensionLevel: item.currentAscensionLevel,
      desiredAscensionLevel: item.desiredAscensionLevel,
      skills: [],
      isActive: item.isActive,
      position: item.position,
      isWeapon: item.isWeapon,
      isCharacter: item.isCharacter,
      useMaterialsFromInventory: item.useMaterialsFromInventory,
    );
  }

  /// This method checks if the [calculatorItemKey] has used inventory items, if it does, it will update the quantity
  /// of each used material passed, otherwise it will return the same material unchanged
  ///
  /// Keep in mind that this method must be called in order based on the [calculatorItemKey]

  List<ItemAscensionMaterialModel> _considerMaterialsInInventory(int calculatorItemKey, List<ItemAscensionMaterialModel> materials) {
    return materials.map((e) {
      if (!_inventory.isItemInInventory(e.key, ItemType.material)) {
        return e;
      }

      final int used = _inventory.getUsedMaterialQuantityByCalcKeyAndItemKey(calculatorItemKey, e.key);
      final int remaining = e.requiredQuantity - used;
      return e.copyWith.call(remainingQuantity: remaining.abs(), usedQuantity: used);
    }).toList();
  }

  Future<int> _redistributeInventoryMaterial(
    String materialKey,
    int materialQuantity,
    int sessionKey,
    List<_RedistributeCheckedItem> checkedItems, {
    bool clearUsedMaterials = false,
  }) async {
    int currentQuantity = materialQuantity;
    final calcItems = _calcItemBox.values.where((el) => el.sessionKey == sessionKey).toList()..sort((x, y) => x.position.compareTo(y.position));

    if (clearUsedMaterials) {
      for (final calcItem in calcItems) {
        final calcItemKey = calcItem.id;
        await _inventory.clearUsedInventoryItems(calcItemKey, onlyItemKey: materialKey);
      }
    }

    for (final calcItem in calcItems) {
      final calcItemKey = calcItem.id;

      if (!calcItem.useMaterialsFromInventory || !calcItem.isActive) {
        continue;
      }

      _RedistributeCheckedItem? checked = checkedItems.firstWhereOrNull((el) => el.sessionKey == sessionKey && el.calcItemKey == calcItemKey);
      if (checked == null) {
        final item = calcItem.isCharacter ? _buildForCharacter(calcItem) : _buildForWeapon(calcItem);
        checked = _RedistributeCheckedItem(sessionKey, calcItemKey, item.materials);
        checkedItems.add(checked);
      }

      if (!checked.materials.any((m) => m.key == materialKey)) {
        continue;
      }

      //If we hit this point, that means that itemKey COULD be being used, so we need to update the used values accordingly
      currentQuantity = await _inventory.redistributeMaterial(
        calcItemKey,
        checked.materials,
        materialKey,
        currentQuantity,
        checkUsed: clearUsedMaterials,
      );
    }
    return currentQuantity;
  }

  /// This one is kinda like a combination of [redistributeAllInventoryMaterials] and [redistributeInventoryMaterial]
  /// but with just one session
  Future<void> _redistributeAllInventoryMaterialsOnItemsReorder(int sessionKey, List<String> onlyMaterialKeys) async {
    //Here we just redistribute what we got based on what we have
    final checkedItems = <_RedistributeCheckedItem>[];
    final materialsInInventory = _inventory.getItemsForRedistribution(ItemType.material);
    for (final material in materialsInInventory) {
      if (onlyMaterialKeys.isNotEmpty && !onlyMaterialKeys.contains(material.key)) {
        continue;
      }

      await _redistributeInventoryMaterial(material.key, material.quantity, sessionKey, checkedItems);
    }
  }

  void _checkSessionKey(int sessionKey) {
    if (!_sessionBox.containsKey(sessionKey)) {
      throw NotFoundError(sessionKey, 'sessionKey', 'Session does not exist');
    }
  }
}

class _RedistributeCheckedItem {
  final int sessionKey;
  final int calcItemKey;
  final List<ItemAscensionMaterialModel> materials;

  _RedistributeCheckedItem(this.sessionKey, this.calcItemKey, this.materials);
}
