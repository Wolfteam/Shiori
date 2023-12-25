import 'dart:async';

import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/persistence/base_data_service.dart';

typedef RedistributeInventoryMaterial = Future<void> Function(String, int);

abstract class InventoryDataService implements BaseDataService {
  StreamController<ItemType> get itemAddedToInventory;

  StreamController<ItemType> get itemUpdatedInInventory;

  StreamController<ItemType> get itemDeletedFromInventory;

  List<CharacterCardModel> getAllCharactersInInventory();

  List<WeaponCardModel> getAllWeaponsInInventory();

  List<MaterialCardModel> getAllMaterialsInInventory();

  int getItemQuantityFromInventory(String key, ItemType type);

  Future<void> addCharacterToInventory(String key, {bool raiseEvent = true});

  Future<void> deleteCharacterFromInventory(String key, {bool raiseEvent = true});

  Future<void> addWeaponToInventory(String key, {bool raiseEvent = true});

  Future<void> deleteWeaponFromInventory(String key, {bool raiseEvent = true});

  Future<void> addMaterialToInventory(String key, int quantity, {RedistributeInventoryMaterial? redistribute, bool raiseEvent = true});

  Future<void> deleteItemsFromInventory(ItemType type, {bool raiseEvent = true});

  Future<void> deleteAllUsedMaterialItems();

  Future<void> deleteAllUsedInventoryItems();

  bool isItemInInventory(String key, ItemType type);

  int getUsedMaterialQuantity(String itemKey);

  Future<int> redistributeMaterial(
    int calcItemKey,
    List<ItemAscensionMaterialModel> materials,
    String itemKey,
    int currentQuantity, {
    bool checkUsed = false,
  });

  Future<void> useMaterialFromInventory(int calculatorItemKey, String itemKey, int quantityToUse);

  Future<void> clearUsedInventoryItems(int calculatorItemKey, {String? onlyItemKey});

  int getUsedMaterialQuantityByCalcKeyAndItemKey(int calculatorItemKey, String itemKey);

  List<ItemCommonWithQuantity> getItemsForRedistribution(ItemType type);

  List<BackupInventoryModel> getDataForBackup();

  Future<void> restoreFromBackup(List<BackupInventoryModel> data);

  List<String> getUsedMaterialKeysByCalcKey(int calculatorItemKey);
}
