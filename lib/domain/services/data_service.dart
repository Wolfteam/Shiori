import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/entities.dart';
import 'package:genshindb/domain/models/models.dart';

abstract class DataService {
  List<CalculatorSessionModel> getAllCalAscMatSessions();

  CalculatorSessionModel getCalcAscMatSession(int sessionKey);

  Future<int> createCalAscMatSession(String name, int position);

  Future<void> updateCalAscMatSession(int sessionKey, String name, int position, {bool redistributeMaterials = false});

  Future<void> deleteCalAscMatSession(int sessionKey);

  Future<void> addCalAscMatSessionItems(int sessionKey, List<ItemAscensionMaterials> items);

  /// Adds a new calc. item to the provided session by using the [sessionKey].
  ///
  /// If [item.useMaterialsFromInventory] is set to false, the same item will be returned without changes.
  /// Otherwise, it will be returned with [item.materials] property updated.
  Future<ItemAscensionMaterials> addCalAscMatSessionItem(int sessionKey, ItemAscensionMaterials item);

  /// Updates the provided item in the specified [itemIndex] associated to the session [sessionKey]
  ///
  /// If [item.useMaterialsFromInventory] is set to false, the same item will be returned without changes.
  /// Otherwise, it will be returned with [item.materials] property updated.
  Future<ItemAscensionMaterials> updateCalAscMatSessionItem(int sessionKey, int itemIndex, ItemAscensionMaterials item);

  Future<void> deleteCalAscMatSessionItem(int sessionKey, int itemIndex);

  List<CharacterCardModel> getAllCharactersInInventory();

  List<WeaponCardModel> getAllWeaponsInInventory();

  List<MaterialCardModel> getAllMaterialsInInventory();

  Future<void> addItemToInventory(String key, ItemType type, int quantity);

  Future<void> updateItemInInventory(String key, ItemType type, int quantity);

  Future<void> deleteItemFromInventory(String key, ItemType type);

  bool isItemInInventory(String key, ItemType type);

  /// This method redistributes all the materials in the inventory by calling [redistributeInventoryMaterial]
  /// for each of the available sessions.
  ///
  /// This method should only be called when the priority of a session or calc. session changes
  Future<void> redistributeAllInventoryMaterials();

  /// This method redistributes the material associated to [itemKey] based on the [newQuantity]
  ///
  /// This method should only be called when the quantity of a material changes
  ///
  ///
  /// E.g: If we now have more, we may update the used quantity in a [InventoryUsedItem] to use more,
  /// otherwise we may reduce the used quantity or even delete the whole thing
  Future<void> redistributeInventoryMaterial(String itemKey, int newQuantity);

  List<GameCodeModel> getAllGameCodes();

  List<String> getAllUsedGameCodes();

  Future<void> markCodeAsUsed(String code, {bool wasUsed = true});

  List<TierListRowModel> getTierList();

  Future<void> saveTierList(List<TierListRowModel> tierList);

  Future<void> deleteTierList();
}
