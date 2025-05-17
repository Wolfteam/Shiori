import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/check.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/persistence/inventory_data_service.dart';

class InventoryDataServiceImpl implements InventoryDataService {
  final GenshinService _genshinService;

  late Box<InventoryItem> _inventoryBox;
  late Box<InventoryUsedItem> _inventoryUsedItemsBox;

  @override
  final StreamController<ItemType> itemAddedToInventory = StreamController.broadcast();

  @override
  final StreamController<ItemType> itemUpdatedInInventory = StreamController.broadcast();

  @override
  final StreamController<ItemType> itemDeletedFromInventory = StreamController.broadcast();

  InventoryDataServiceImpl(this._genshinService);

  @override
  Future<void> init() async {
    _inventoryBox = await Hive.openBox<InventoryItem>('inventory');
    _inventoryUsedItemsBox = await Hive.openBox<InventoryUsedItem>('inventoryUsedItems');
  }

  @override
  Future<void> deleteThemAll() async {
    await _inventoryBox.clear();
    await _inventoryUsedItemsBox.clear();
  }

  @override
  Future<void> addCharacterToInventory(String key, {bool raiseEvent = true}) => _addNonMaterialToInventory(key, ItemType.character);

  @override
  Future<void> deleteCharacterFromInventory(String key, {bool raiseEvent = true}) => _deleteNonMaterialFromInventory(key, ItemType.character);

  @override
  Future<void> addWeaponToInventory(String key, {bool raiseEvent = true}) => _addNonMaterialToInventory(key, ItemType.weapon);

  @override
  Future<void> deleteWeaponFromInventory(String key, {bool raiseEvent = true}) => _deleteNonMaterialFromInventory(key, ItemType.weapon);

  @override
  Future<void> deleteItemsFromInventory(ItemType type, {bool raiseEvent = true}) async {
    switch (type) {
      case ItemType.character:
      case ItemType.weapon:
      case ItemType.artifact:
        await _deleteAllItemsInInventoryExceptMaterials(type);
      case ItemType.material:
        deleteAllUsedMaterialItems();
    }

    if (raiseEvent) {
      itemDeletedFromInventory.add(type);
    }
  }

  @override
  Future<void> deleteAllUsedMaterialItems() async {
    final materialsInInventory = _inventoryBox.values.where((el) => el.type == ItemType.material.index && el.quantity > 0).toList();
    for (final material in materialsInInventory) {
      material.quantity = 0;
      await material.save();
    }
    await deleteAllUsedInventoryItems();
  }

  @override
  Future<void> deleteAllUsedInventoryItems() async {
    final usedItemKeys = _inventoryUsedItemsBox.values.map((e) => e.key).toList();
    if (usedItemKeys.isNotEmpty) {
      await _inventoryUsedItemsBox.deleteAll(usedItemKeys);
    }
  }

  @override
  List<CharacterCardModel> getAllCharactersInInventory() {
    final characters =
        _inventoryBox.values
            .where((el) => el.type == ItemType.character.index)
            .map((e) => _genshinService.characters.getCharacterForCard(e.itemKey))
            .toList();

    return characters..sort((x, y) => x.name.compareTo(y.name));
  }

  @override
  List<MaterialCardModel> getAllMaterialsInInventory() {
    final allMaterials = <MaterialCardModel>[];
    final List<MaterialCardModel> materials = _genshinService.materials.getAllMaterialsForCard();
    final List<InventoryItem> inInventory = _inventoryBox.values.where((el) => el.type == ItemType.material.index).toList();
    for (final MaterialCardModel material in materials) {
      final InventoryItem? dbItem = inInventory.firstWhereOrNull((el) => el.itemKey == material.key);
      if (dbItem == null) {
        allMaterials.add(material);
        continue;
      }
      final int usedQuantity = getUsedMaterialQuantity(material.key);
      allMaterials.add(material.copyWith(quantity: dbItem.quantity, usedQuantity: usedQuantity));
    }

    return sortMaterialsByGrouping(allMaterials, SortDirectionType.asc);
  }

  @override
  int getItemQuantityFromInventory(String key, ItemType type) {
    Check.notEmpty(key, 'key');
    final InventoryItem? item = _inventoryBox.values.firstWhereOrNull((m) => m.itemKey == key && m.type == type.index);
    return item?.quantity ?? 0;
  }

  @override
  List<WeaponCardModel> getAllWeaponsInInventory() {
    final weapons =
        _inventoryBox.values.where((el) => el.type == ItemType.weapon.index).map((e) => _genshinService.weapons.getWeaponForCard(e.itemKey)).toList();

    return weapons..sort((x, y) => x.name.compareTo(y.name));
  }

  @override
  Future<void> addMaterialToInventory(String key, int quantity, {RedistributeInventoryMaterial? redistribute, bool raiseEvent = true}) async {
    Check.notEmpty(key, 'key');
    Check.greaterThanOrEqualToZero(quantity, 'quantity');

    const type = ItemType.material;
    InventoryItem? item = _getItemFromInventory(key, type);
    if (item == null) {
      item = InventoryItem(key, quantity, type.index);
      await _inventoryBox.add(item);
    } else {
      if (quantity == item.quantity) {
        return;
      }
      item.quantity = quantity;
      await item.save();
    }
    if (redistribute != null) {
      await redistribute(key, quantity);
    }
    if (raiseEvent) {
      itemUpdatedInInventory.add(type);
    }
  }

  @override
  bool isItemInInventory(String key, ItemType type) {
    Check.notEmpty(key, 'key');
    return _inventoryBox.values.any((el) => el.itemKey == key && el.type == type.index && el.quantity > 0);
  }

  @override
  int getUsedMaterialQuantity(String itemKey) {
    Check.notEmpty(itemKey, 'itemKey');
    return _inventoryUsedItemsBox.values
        .where((el) => el.itemKey == itemKey && el.type == ItemType.material.index)
        .fold(0, (previousValue, element) => previousValue + element.usedQuantity);
  }

  @override
  Future<int> redistributeMaterial(
    int calcItemKey,
    List<ItemAscensionMaterialModel> materials,
    String itemKey,
    int currentQuantity, {
    bool checkUsed = false,
  }) async {
    Check.greaterThanOrEqualToZero(calcItemKey, 'calcItemKey');
    Check.notEmpty(itemKey, 'itemKey');
    Check.greaterThanOrEqualToZero(currentQuantity, 'currentQuantity');

    int currentQty = currentQuantity;

    //Check if there is a used item for this calculator item
    InventoryUsedItem? usedInInventory = _inventoryUsedItemsBox.values.firstWhereOrNull(
      (el) => el.calculatorItemKey == calcItemKey && el.itemKey == itemKey,
    );
    final int desiredQuantityToUse = materials.firstWhereOrNull((el) => el.key == itemKey)?.requiredQuantity ?? 0;

    //If no used item was found, lets check if this calc. item could benefit from this itemKey
    if (usedInInventory == null) {
      //If itemKey is not in the used materials, then this item does not use this material
      if (!materials.any((el) => el.key == itemKey)) {
        return currentQty;
      }

      //otherwise, since we don't have a used inventory item, we need to create one, that will later get updated
      usedInInventory = InventoryUsedItem(calcItemKey, itemKey, desiredQuantityToUse, ItemType.material.index);
      await _inventoryUsedItemsBox.add(usedInInventory);
    }

    final int available = currentQty - desiredQuantityToUse;
    final bool canBeSatisfied = available >= 0;

    //If we can satisfy the desired quantity, reduce the current quantity and also update the used qty in the inventory item
    if (canBeSatisfied) {
      currentQty -= desiredQuantityToUse;
      usedInInventory.usedQuantity = desiredQuantityToUse;
      await usedInInventory.save();
      return currentQty;
    }

    //If we ended up using all the available material,
    //we must delete the previously used item since we cannot satisfy the required material quantity
    if (currentQty == 0) {
      await _inventoryUsedItemsBox.delete(usedInInventory.key);
      return currentQty;
    }

    //Finally, if we can't satisfy all the desired quantity, and we still have a little bit left
    //then, use the remaining
    usedInInventory.usedQuantity = currentQty;
    await usedInInventory.save();
    return 0;
  }

  @override
  Future<void> useMaterialFromInventory(int calculatorItemKey, String itemKey, int quantityToUse) async {
    Check.greaterThanOrEqualToZero(calculatorItemKey, 'calculatorItemKey');
    Check.notEmpty(itemKey, 'itemKey');
    Check.greaterThanOrEqualToZero(quantityToUse, 'quantityToUse');

    const type = ItemType.material;
    if (!isItemInInventory(itemKey, type)) {
      return;
    }

    final item = _getItemFromInventory(itemKey, type)!;
    final int used = getUsedMaterialQuantity(itemKey);
    final int available = item.quantity - used;
    final int toUse = available - quantityToUse < 0 ? available : quantityToUse;
    if (toUse == 0) {
      return;
    }

    final usedItem = InventoryUsedItem(calculatorItemKey, itemKey, toUse, type.index);
    await _inventoryUsedItemsBox.add(usedItem);
  }

  @override
  Future<void> clearUsedInventoryItems(int calculatorItemKey, {String? onlyItemKey}) async {
    Check.greaterThanOrEqualToZero(calculatorItemKey, 'calculatorItemKey');
    final usedItems =
        onlyItemKey.isNullEmptyOrWhitespace
            ? _inventoryUsedItemsBox.values.where((el) => el.calculatorItemKey == calculatorItemKey).map((e) => e.key).toList()
            : _inventoryUsedItemsBox.values
                .where((el) => el.calculatorItemKey == calculatorItemKey && el.itemKey == onlyItemKey)
                .map((e) => e.key)
                .toList();
    await _inventoryUsedItemsBox.deleteAll(usedItems);
  }

  @override
  int getUsedMaterialQuantityByCalcKeyAndItemKey(int calculatorItemKey, String itemKey) {
    Check.greaterThanOrEqualToZero(calculatorItemKey, 'calculatorItemKey');
    Check.notEmpty(itemKey, 'itemKey');

    final InventoryUsedItem? usedItem = _inventoryUsedItemsBox.values.firstWhereOrNull(
      (el) => el.calculatorItemKey == calculatorItemKey && el.itemKey == itemKey && el.type == ItemType.material.index,
    );

    return usedItem?.usedQuantity ?? 0;
  }

  @override
  List<ItemCommonWithQuantity> getItemsForRedistribution(ItemType type) {
    return _inventoryBox.values
        .where((el) => el.type == type.index && el.quantity > 0)
        .map((e) => ItemCommonWithQuantity(e.itemKey, '', '', e.quantity))
        .toList();
  }

  @override
  List<BackupInventoryModel> getDataForBackup() {
    return _inventoryBox.values
        .where((e) => e.quantity > 0)
        .map((e) => BackupInventoryModel(itemKey: e.itemKey, type: e.type, quantity: e.quantity))
        .toList();
  }

  @override
  Future<void> restoreFromBackup(List<BackupInventoryModel> data) async {
    await deleteThemAll();
    for (final item in data) {
      final type = ItemType.values[item.type];
      switch (type) {
        case ItemType.character:
          await addCharacterToInventory(item.itemKey, raiseEvent: false);
        case ItemType.weapon:
          await addWeaponToInventory(item.itemKey, raiseEvent: false);
        case ItemType.material:
          await addMaterialToInventory(item.itemKey, item.quantity, raiseEvent: false);
        default:
          continue;
      }
    }
  }

  @override
  List<String> getUsedMaterialKeysByCalcKey(int calculatorItemKey) {
    Check.greaterThanOrEqualToZero(calculatorItemKey, 'calculatorItemKey');
    return _inventoryUsedItemsBox.values
        .where((el) => el.calculatorItemKey == calculatorItemKey && el.type == ItemType.material.index)
        .map((e) => e.itemKey)
        .toList();
  }

  InventoryItem? _getItemFromInventory(String key, ItemType type) {
    Check.notEmpty(key, 'key');
    return _inventoryBox.values.firstWhereOrNull((el) => el.itemKey == key && el.type == type.index);
  }

  Future<void> _addNonMaterialToInventory(String key, ItemType type, {bool raiseEvent = true}) async {
    Check.notEmpty(key, 'key');
    Check.inList(type, [ItemType.character, ItemType.weapon], 'type');

    if (isItemInInventory(key, type)) {
      return;
    }

    const int quantity = 1;
    await _inventoryBox.add(InventoryItem(key, quantity, type.index));
    if (raiseEvent) {
      itemAddedToInventory.add(type);
    }
  }

  Future<void> _deleteNonMaterialFromInventory(String key, ItemType type, {bool raiseEvent = true}) async {
    Check.notEmpty(key, 'key');
    Check.inList(type, [ItemType.character, ItemType.weapon], 'type');
    final InventoryItem? item = _getItemFromInventory(key, type);

    if (item != null) {
      await _inventoryBox.delete(item.key);
    }

    if (raiseEvent) {
      itemDeletedFromInventory.add(type);
    }
  }

  Future<void> _deleteAllItemsInInventoryExceptMaterials(ItemType? type) async {
    if (type == ItemType.material) {
      throw ArgumentError.value(type, 'type', 'Value type is not allowed here');
    }
    final toDeleteKeys =
        type == null
            ? _inventoryBox.values.where((el) => el.type != ItemType.material.index).map((e) => e.key).toList()
            : _inventoryBox.values.where((el) => el.type == type.index).map((e) => e.key).toList();
    if (toDeleteKeys.isNotEmpty) {
      await _inventoryBox.deleteAll(toDeleteKeys);
    }
  }
}
