import 'package:collection/collection.dart' show IterableExtension;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/persistence/calculator_data_service.dart';
import 'package:shiori/domain/services/persistence/inventory_data_service.dart';
import 'package:shiori/domain/services/resources_service.dart';

class CalculatorDataServiceImpl implements CalculatorDataService {
  final GenshinService _genshinService;
  final CalculatorService _calculatorService;
  final InventoryDataService _inventory;
  final ResourceService _resourceService;

  late Box<CalculatorSession> _sessionBox;
  late Box<CalculatorItem> _calcItemBox;
  late Box<CalculatorCharacterSkill> _calcItemSkillBox;

  CalculatorDataServiceImpl(this._genshinService, this._calculatorService, this._inventory, this._resourceService);

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
  List<CalculatorSessionModel> getAllCalAscMatSessions() {
    final sessions = _sessionBox.values.toList()..sort((x, y) => x.position.compareTo(y.position));
    final result = <CalculatorSessionModel>[];

    for (final session in sessions) {
      result.add(getCalcAscMatSession(session.key as int));
    }

    return result;
  }

  @override
  CalculatorSessionModel getCalcAscMatSession(int sessionKey) {
    final session = _sessionBox.values.firstWhere((el) => el.key == sessionKey);

    final sessionItems = <ItemAscensionMaterials>[];
    final calcItems = _calcItemBox.values.where((el) => el.sessionKey == session.key).toList()..sort((x, y) => x.position.compareTo(y.position));
    for (final calItem in calcItems) {
      if (calItem.isCharacter) {
        sessionItems.add(_buildForCharacter(calItem, calculatorItemKey: calItem.key as int, includeInventory: true));
        continue;
      }

      if (calItem.isWeapon) {
        sessionItems.add(_buildForWeapon(calItem, calculatorItemKey: calItem.key as int, includeInventory: true));
        continue;
      }

      throw Exception('The provided item with key = ${calItem.key} is not neither a character nor weapon');
    }

    return CalculatorSessionModel(key: session.key as int, name: session.name, position: session.position, items: sessionItems);
  }

  @override
  Future<int> createCalAscMatSession(String name, int position) {
    final session = CalculatorSession(name, position);
    return _sessionBox.add(session);
  }

  @override
  Future<void> updateCalAscMatSession(int sessionKey, String name, int position, {bool redistributeMaterials = false}) async {
    final session = _sessionBox.get(sessionKey)!;
    session.name = name;
    session.position = position;
    await session.save();

    if (redistributeMaterials) {
      await redistributeAllInventoryMaterials();
    }
  }

  @override
  Future<void> deleteCalAscMatSession(int sessionKey) async {
    await _sessionBox.delete(sessionKey);
    final calItems = _calcItemBox.values.where((el) => el.sessionKey == sessionKey).toList();
    for (final calItem in calItems) {
      await deleteCalAscMatSessionItem(sessionKey, calItem.position);
    }
  }

  @override
  Future<void> deleteAllCalAscMatSession() async {
    //First we clear the used items in the inventory (if any)
    await _inventory.deleteAllUsedInventoryItems();

    //Then we delete all the child items inside each session
    final childrenItemKeys = _calcItemBox.values.map((e) => e.key).toList();
    await _calcItemSkillBox.deleteAll(childrenItemKeys);

    //Including skills
    final skillsKeys = _calcItemSkillBox.values.map((e) => e.key).toList();
    await _calcItemBox.delete(skillsKeys);

    //Finally, we delete all the sessions
    final keys = _sessionBox.values.map((e) => e.key).toList();
    await _sessionBox.deleteAll(keys);
  }

  @override
  Future<void> addCalAscMatSessionItems(int sessionKey, List<ItemAscensionMaterials> items, {bool redistributeAtTheEnd = true}) async {
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final redistribute = i + 1 == items.length && redistributeAtTheEnd;
      await addCalAscMatSessionItem(sessionKey, item, redistribute: redistribute);
    }
  }

  @override
  Future<ItemAscensionMaterials> addCalAscMatSessionItem(int sessionKey, ItemAscensionMaterials item, {bool redistribute = true}) async {
    final mappedItem = _toCalculatorItem(sessionKey, item);

    final calculatorItemKey = await _calcItemBox.add(mappedItem);
    final skills = item.skills.map((e) => CalculatorCharacterSkill(calculatorItemKey, e.key, e.currentLevel, e.desiredLevel, e.position)).toList();
    await _calcItemSkillBox.addAll(skills);

    if (!mappedItem.useMaterialsFromInventory || item.materials.isEmpty || !item.isActive) {
      return item;
    }

    //Here we created a used inventory item for each material
    for (final material in item.materials) {
      final mat = _genshinService.materials.getMaterial(material.key);
      await _inventory.useItemFromInventory(calculatorItemKey, mat.key, ItemType.material, material.quantity);
    }

    if (!redistribute) {
      return item;
    }
    //Since we added a new item, we need to redistribute
    //the materials because the priority of this item could be higher than the others
    await redistributeAllInventoryMaterials();

    //And finally update the material quantity based on the used inventory items
    //This is quite similar to what the _considerMaterialsInInventory does
    final updatedMaterials = item.materials.map((e) {
      final remaining = _inventory.getRemainingQuantity(calculatorItemKey, e.key, e.quantity, ItemType.material);
      return e.copyWith.call(quantity: remaining);
    }).toList();

    return item.copyWith.call(materials: updatedMaterials);
  }

  @override
  Future<ItemAscensionMaterials> updateCalAscMatSessionItem(
    int sessionKey,
    int newItemPosition,
    ItemAscensionMaterials item, {
    bool redistribute = true,
  }) async {
    await deleteCalAscMatSessionItem(sessionKey, item.position, redistribute: false);
    return addCalAscMatSessionItem(sessionKey, item.copyWith.call(position: newItemPosition), redistribute: redistribute);
  }

  @override
  Future<void> deleteCalAscMatSessionItem(int sessionKey, int position, {bool redistribute = true}) async {
    final calcItem = _calcItemBox.values.firstWhereOrNull((el) => el.sessionKey == sessionKey && el.position == position);
    if (calcItem == null) {
      return;
    }
    final calcItemKey = calcItem.key as int;
    final skillsKeys = _calcItemSkillBox.values.where((el) => el.calculatorItemKey == calcItemKey).map((e) => e.key).toList();
    await _calcItemSkillBox.deleteAll(skillsKeys);

    //Make sure we delete the item before redistributing
    await _calcItemBox.delete(calcItemKey);

    await _inventory.clearUsedInventoryItems(calcItemKey, redistributeAllInventoryMaterials, redistribute: redistribute);
  }

  @override
  Future<void> deleteAllCalAscMatSessionItems(int sessionKey) async {
    final calcItems = _calcItemBox.values.where((el) => el.sessionKey == sessionKey).map((e) => e.key as int).toList();

    if (calcItems.isEmpty) {
      return;
    }

    for (final calcItemKey in calcItems) {
      final skillsKeys = _calcItemSkillBox.values.where((el) => el.calculatorItemKey == calcItemKey).map((e) => e.key).toList();
      await _calcItemSkillBox.deleteAll(skillsKeys);

      //Make sure we delete the item before redistributing
      await _calcItemBox.delete(calcItemKey);

      await _inventory.clearUsedInventoryItems(calcItemKey, redistributeAllInventoryMaterials);
    }

    //Only redistribute at the end of the process
    await redistributeAllInventoryMaterials();
  }

  @override
  Future<void> redistributeAllInventoryMaterials() async {
    //Here we just redistribute what we got based on what we have
    final materialsInInventory = _inventory.getItemsForRedistribution(ItemType.material);
    for (final material in materialsInInventory) {
      await redistributeInventoryMaterial(material.key, material.quantity);
    }
  }

  @override
  Future<void> redistributeInventoryMaterial(String itemKey, int newQuantity) async {
    int currentQuantity = newQuantity;
    final sessions = _sessionBox.values.toList()..sort((x, y) => x.position.compareTo(y.position));
    for (final session in sessions) {
      final calcItems = _calcItemBox.values.where((el) => el.sessionKey == session.key).toList()..sort((x, y) => x.position.compareTo(y.position));
      for (final calItem in calcItems) {
        if (!calItem.useMaterialsFromInventory || !calItem.isActive) {
          continue;
        }

        //If we hit this point, that means that itemKey COULD be being used, so we need to update the used values accordingly
        final item = calItem.isCharacter ? _buildForCharacter(calItem) : _buildForWeapon(calItem);
        currentQuantity = await _inventory.redistributeMaterial(calItem.key as int, item, itemKey, currentQuantity);
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
              .where((el) => el.calculatorItemKey == calcItem.key as int)
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
      final id = await createCalAscMatSession(session.name, session.position);
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
      await addCalAscMatSessionItems(id, items, redistributeAtTheEnd: false);
    }

    await redistributeAllInventoryMaterials();
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
      isCurrentDecEnabled: enableTuple.item1,
      isCurrentIncEnabled: enableTuple.item2,
      isDesiredDecEnabled: enableTuple.item3,
      isDesiredIncEnabled: enableTuple.item4,
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

      final remaining = _inventory.getRemainingQuantity(calculatorItemKey, e.key, e.quantity, ItemType.material);
      return e.copyWith.call(quantity: remaining);
    }).toList();
  }
}
