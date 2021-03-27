import 'package:genshindb/domain/app_constants.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/enums/item_type.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/domain/models/entities.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/calculator_service.dart';
import 'package:genshindb/domain/services/data_service.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DataServiceImpl implements DataService {
  final GenshinService _genshinService;
  final CalculatorService _calculatorService;
  Box<CalculatorSession> _sessionBox;
  Box<CalculatorItem> _calcItemBox;
  Box<CalculatorCharacterSkill> _calcItemSkillBox;
  Box<InventoryItem> _inventoryBox;
  Box<InventoryUsedItem> _inventoryUsedItemsBox;

  DataServiceImpl(this._genshinService, this._calculatorService);

  Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();
    _sessionBox = await Hive.openBox<CalculatorSession>('calculatorSessions');
    _calcItemBox = await Hive.openBox<CalculatorItem>('calculatorSessionsItems');
    _calcItemSkillBox = await Hive.openBox<CalculatorCharacterSkill>('calculatorSessionsItemsSkills');
    _inventoryBox = await Hive.openBox<InventoryItem>('inventory');
    _inventoryUsedItemsBox = await Hive.openBox<InventoryUsedItem>('inventoryUsedItems');

    //TODO: REMOVE THIS
    // await _sessionBox.clear();
    // await _calcItemBox.clear();
    // await _calcItemSkillBox.clear();
    // await _inventoryUsedItemsBox.clear();
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
    final session = _sessionBox.get(sessionKey);
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
  Future<void> addCalAscMatSessionItems(int sessionKey, List<ItemAscensionMaterials> items) async {
    for (final item in items) {
      await addCalAscMatSessionItem(sessionKey, item);
    }
  }

  @override
  Future<ItemAscensionMaterials> addCalAscMatSessionItem(int sessionKey, ItemAscensionMaterials item) async {
    final mappedItem = CalculatorItem(
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

    final calculatorItemKey = await _calcItemBox.add(mappedItem);
    final skills = item.skills.map((e) => CalculatorCharacterSkill(calculatorItemKey, e.key, e.currentLevel, e.desiredLevel, e.position)).toList();
    await _calcItemSkillBox.addAll(skills);

    if (!mappedItem.useMaterialsFromInventory || item.materials.isEmpty || !item.isActive) {
      return item;
    }

    //Here we created a used inventory item for each material
    for (final material in item.materials) {
      final mat = _genshinService.getMaterialByImage(material.fullImagePath);
      await _useItemFromInventory(calculatorItemKey, mat.key, ItemType.material, material.quantity);
    }

    //Since we added a new item, we need to redistribute
    //the materials because the priority of this item could be higher than the others
    await redistributeAllInventoryMaterials();

    //Then we retrieve the used items created before
    final usedInventoryItems = _inventoryUsedItemsBox.values
        .where(
          (el) => el.calculatorItemKey == calculatorItemKey && el.type == ItemType.material.index,
        )
        .toList();

    //And finally update the material quantity based on the used inventory items
    //This is quite similar to what the _considerMaterialsInInventory does
    final updatedMaterials = item.materials.map((e) {
      final material = _genshinService.getMaterialByImage(e.fullImagePath);
      if (!usedInventoryItems.any((el) => el.itemKey == material.key)) {
        return e;
      }
      final usedQuantity = usedInventoryItems
              .firstWhere(
                (el) => el.calculatorItemKey == calculatorItemKey && el.itemKey == material.key && el.type == ItemType.material.index,
                orElse: () => null,
              )
              ?.usedQuantity ??
          e.quantity;

      final remaining = e.quantity - usedQuantity;
      return e.copyWith.call(quantity: remaining);
    }).toList();

    return item.copyWith.call(materials: updatedMaterials);
  }

  @override
  Future<ItemAscensionMaterials> updateCalAscMatSessionItem(int sessionKey, int position, ItemAscensionMaterials item) async {
    await deleteCalAscMatSessionItem(sessionKey, item.position);
    return addCalAscMatSessionItem(sessionKey, item);
  }

  @override
  Future<void> deleteCalAscMatSessionItem(int sessionKey, int position) async {
    final calcItem = _calcItemBox.values.firstWhere((el) => el.sessionKey == sessionKey && el.position == position, orElse: () => null);
    if (calcItem == null) {
      return;
    }
    final calcItemKey = calcItem.key as int;
    final skillsKeys = _calcItemSkillBox.values.where((el) => el.calculatorItemKey == calcItemKey).map((e) => e.key).toList();
    await _calcItemSkillBox.deleteAll(skillsKeys);

    //Make sure we delete the item before redistributing
    await _calcItemBox.delete(calcItemKey);

    await _clearUsedInventoryItems(calcItemKey, redistribute: true);
  }

  @override
  Future<void> addItemToInventory(String key, ItemType type, int quantity) {
    if (isItemInInventory(key, type)) {
      return Future.value();
    }
    return _inventoryBox.add(InventoryItem(key, quantity, type.index));
  }

  @override
  Future<void> deleteItemFromInventory(String key, ItemType type) async {
    final item = _getItemFromInventory(key, type);

    if (item != null) {
      await _inventoryBox.delete(item.key);
    }
  }

  @override
  List<CharacterCardModel> getAllCharactersInInventory() {
    final characters = _inventoryBox.values
        .where((el) => el.type == ItemType.character.index)
        .map(
          (e) => _genshinService.getCharacterForCard(e.itemKey),
        )
        .toList();

    return characters..sort((x, y) => x.name.compareTo(y.name));
  }

  @override
  List<MaterialCardModel> getAllMaterialsInInventory() {
    final materials = _genshinService.getAllMaterialsForCard();
    final inInventory = _inventoryBox.values.where((el) => el.type == ItemType.material.index).map((e) {
      final material = _genshinService.getMaterialForCard(e.itemKey);
      return material.copyWith.call(quantity: e.quantity);
    }).toList();

    final allMaterials = <MaterialCardModel>[];
    for (final material in materials) {
      if (inInventory.any((m) => m.key == material.key)) {
        //The one in db has the quantity
        final inDb = inInventory.firstWhere((m) => m.key == material.key);
        final usedQuantity = getNumberOfItemsUsed(material.key, ItemType.material);
        allMaterials.add(inDb.copyWith.call(usedQuantity: usedQuantity));
      } else {
        allMaterials.add(material);
      }
    }

    return sortMaterialsByGrouping(allMaterials, SortDirectionType.asc);
  }

  @override
  List<WeaponCardModel> getAllWeaponsInInventory() {
    final weapons = _inventoryBox.values
        .where((el) => el.type == ItemType.weapon.index)
        .map(
          (e) => _genshinService.getWeaponForCard(e.itemKey),
        )
        .toList();

    return weapons..sort((x, y) => x.name.compareTo(y.name));
  }

  @override
  Future<void> updateItemInInventory(String key, ItemType type, int quantity) async {
    var item = _getItemFromInventory(key, type);
    if (item == null) {
      item = InventoryItem(key, quantity, type.index);
      await _inventoryBox.add(item);
    } else {
      if (quantity == item.quantity) {
        return;
      }
//TODO: IF THE QUANTITY IS 0 SHOULD I DELETE THE ITEM ?
      item.quantity = quantity;
      await item.save();
    }
    await redistributeInventoryMaterial(key, quantity);
  }

  @override
  bool isItemInInventory(String key, ItemType type) {
    return _inventoryBox.values.any((el) => el.itemKey == key && el.type == type.index && el.quantity > 0);
  }

  int getNumberOfItemsUsed(String byItemKey, ItemType type) {
    return _inventoryUsedItemsBox.values
        .where((el) => el.itemKey == byItemKey && el.type == type.index)
        .fold(0, (previousValue, element) => previousValue + element.usedQuantity);
  }

  @override
  Future<void> redistributeAllInventoryMaterials() async {
    //Here we just redistribute what we got based on what we have
    //This method should only be called
    final materialsInInventory = _inventoryBox.values.where((el) => el.type == ItemType.material.index && el.quantity > 0).toList();
    for (final material in materialsInInventory) {
      await redistributeInventoryMaterial(material.itemKey, material.quantity);
    }
  }

  @override
  Future<void> redistributeInventoryMaterial(String itemKey, int newQuantity) async {
    var currentQuantity = newQuantity;
    final sessions = _sessionBox.values.toList()..sort((x, y) => x.position.compareTo(y.position));
    for (final session in sessions) {
      final calcItems = _calcItemBox.values.where((el) => el.sessionKey == session.key).toList()..sort((x, y) => x.position.compareTo(y.position));
      for (final calItem in calcItems) {
        if (!calItem.useMaterialsFromInventory) {
          continue;
        }

        //If we hit this point, that means that itemKey COULD be being used, so we need to update the used values accordingly
        final item = calItem.isCharacter ? _buildForCharacter(calItem) : _buildForWeapon(calItem);
        final material = _genshinService.getMaterial(itemKey);
        final desiredQuantityToUse = item.materials.firstWhere((el) => el.fullImagePath == material.fullImagePath, orElse: () => null)?.quantity ?? 0;

        //Next, we check if there is a used item for this calculator item
        var usedInInventory =
            _inventoryUsedItemsBox.values.firstWhere((el) => el.calculatorItemKey == calItem.key && el.itemKey == itemKey, orElse: () => null);

        //If no used item was found, lets check if this calc. item could benefit from this itemKey
        if (usedInInventory == null) {
          //If itemKey is not in the used materials, then this item does not use this material
          if (!item.materials.any((el) => el.fullImagePath == material.fullImagePath)) {
            continue;
          }

          //otherwise, since we don't have a used inventory item, we need to create one, that will later get updated
          usedInInventory = InventoryUsedItem(calItem.key as int, itemKey, desiredQuantityToUse, ItemType.material.index);
          await _inventoryUsedItemsBox.add(usedInInventory);
        }

        final available = currentQuantity - desiredQuantityToUse;
        final canBeSatisfied = available >= 0;

        //If we can satisfy the desired quantity, reduce the current quantity and also update the used qty in the inventory item
        if (canBeSatisfied) {
          currentQuantity -= desiredQuantityToUse;
          usedInInventory.usedQuantity = desiredQuantityToUse;
          await usedInInventory.save();
          continue;
        }

        //If we ended up using all the available material,
        //we must delete the previously used item since we cannot satisfy the required material quantity
        if (currentQuantity == 0) {
          await _inventoryUsedItemsBox.delete(usedInInventory.key);
          continue;
        }

        //Finally, if we can't satisfy all the desired quantity, and we still have a little bit left
        //then, use the remaining
        usedInInventory.usedQuantity = currentQuantity;
        await usedInInventory.save();
        currentQuantity = 0;
      }
    }
  }

  void _registerAdapters() {
    Hive.registerAdapter(CalculatorCharacterSkillAdapter());
    Hive.registerAdapter(CalculatorItemAdapter());
    Hive.registerAdapter(CalculatorSessionAdapter());
    Hive.registerAdapter(InventoryItemAdapter());
    Hive.registerAdapter(InventoryUsedItemAdapter());
  }

  ItemAscensionMaterials _buildForCharacter(CalculatorItem item, {int calculatorItemKey, bool includeInventory = false}) {
    final character = _genshinService.getCharacter(item.itemKey);
    final translation = _genshinService.getCharacterTranslation(item.itemKey);
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

    if (item.useMaterialsFromInventory && includeInventory && calculatorItemKey != null) {
      materials = _considerMaterialsInInventory(calculatorItemKey, materials);
    }

    return ItemAscensionMaterials.forCharacters(
      key: item.itemKey,
      name: translation.name,
      image: Assets.getCharacterPath(character.image),
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

  ItemAscensionMaterials _buildForWeapon(CalculatorItem item, {int calculatorItemKey, bool includeInventory = false}) {
    final weapon = _genshinService.getWeapon(item.itemKey);
    final translation = _genshinService.getWeaponTranslation(item.itemKey);
    var materials = _calculatorService.getWeaponMaterialsToUse(
      weapon,
      item.currentLevel,
      item.desiredLevel,
      item.currentAscensionLevel,
      item.desiredAscensionLevel,
    );

    if (item.useMaterialsFromInventory && includeInventory && calculatorItemKey != null) {
      materials = _considerMaterialsInInventory(calculatorItemKey, materials);
    }

    return ItemAscensionMaterials.forWeapons(
      key: item.itemKey,
      name: translation.name,
      image: weapon.fullImagePath,
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

  /// This method checks if the [calculatorItemKey] has used inventory items, it it does, it will update the quantity
  /// of each used material passed, otherwise it will return the same material unchanged
  ///
  /// Keep in mind that this method must be called in order based on the [calculatorItemKey]
  List<ItemAscensionMaterialModel> _considerMaterialsInInventory(int calculatorItemKey, List<ItemAscensionMaterialModel> materials) {
    return materials.map((e) {
      final material = _genshinService.getMaterialByImage(e.fullImagePath);
      if (!isItemInInventory(material.key, ItemType.material)) {
        return e;
      }

      final usedQuantity = _inventoryUsedItemsBox.values
              .firstWhere(
                (el) => el.calculatorItemKey == calculatorItemKey && el.itemKey == material.key && el.type == ItemType.material.index,
                orElse: () => null,
              )
              ?.usedQuantity ??
          0;

      final remaining = e.quantity - usedQuantity;

      return e.copyWith.call(quantity: remaining);
    }).toList();
  }

  InventoryItem _getItemFromInventory(String key, ItemType type) {
    return _inventoryBox.values.firstWhere((el) => el.itemKey == key && el.type == type.index, orElse: () => null);
  }

  Future<void> _useItemFromInventory(int calculatorItemKey, String itemKey, ItemType type, int quantityToUse) async {
    if (!isItemInInventory(itemKey, type)) {
      return;
    }

    final used = getNumberOfItemsUsed(itemKey, type);

    final item = _getItemFromInventory(itemKey, type);
    final available = item.quantity - used;
    final toUse = available - quantityToUse < 0 ? available : quantityToUse;
    if (toUse == 0) {
      return;
    }

    final usedItem = InventoryUsedItem(calculatorItemKey, itemKey, toUse, type.index);
    await _inventoryUsedItemsBox.add(usedItem);
  }

  Future<void> _clearUsedInventoryItemsInSession(int sessionKey) async {
    final calcItems = _calcItemBox.values.where((el) => el.sessionKey == sessionKey).toList();
    for (final calcItem in calcItems) {
      if (calcItem.useMaterialsFromInventory) {
        await _clearUsedInventoryItems(calcItem.key as int);
      }
    }

    await redistributeAllInventoryMaterials();
  }

  Future<void> _clearUsedInventoryItems(int calculatorItemKey, {String onlyItemKey, bool redistribute = false}) async {
    final usedItems = onlyItemKey.isNullEmptyOrWhitespace
        ? _inventoryUsedItemsBox.values.where((el) => el.calculatorItemKey == calculatorItemKey).map((e) => e.key).toList()
        : _inventoryUsedItemsBox.values
            .where((el) => el.calculatorItemKey == calculatorItemKey && el.itemKey == onlyItemKey)
            .map((e) => e.key)
            .toList();
    await _inventoryUsedItemsBox.deleteAll(usedItems);
    if (redistribute) {
      await redistributeAllInventoryMaterials();
    }
  }
}
