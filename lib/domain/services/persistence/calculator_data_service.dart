import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/persistence/base_data_service.dart';

abstract class CalculatorDataService implements BaseDataService {
  List<CalculatorSessionModel> getAllCalAscMatSessions();

  CalculatorSessionModel getCalcAscMatSession(int sessionKey);

  Future<int> createCalAscMatSession(String name, int position);

  Future<void> updateCalAscMatSession(int sessionKey, String name, int position, {bool redistributeMaterials = false});

  Future<void> deleteCalAscMatSession(int sessionKey);

  Future<void> deleteAllCalAscMatSession();

  Future<void> addCalAscMatSessionItems(int sessionKey, List<ItemAscensionMaterials> items);

  /// Adds a new calc. item to the provided session by using the [sessionKey].
  ///
  /// If [item.useMaterialsFromInventory] is set to false, the same item will be returned without changes.
  /// Otherwise, it will be returned with [item.materials] property updated.
  Future<ItemAscensionMaterials> addCalAscMatSessionItem(int sessionKey, ItemAscensionMaterials item, {bool redistribute = true});

  /// Updates the provided item associated to the session [sessionKey]
  ///
  /// The item will be retrieved using the current value of [item.position]
  /// and it will also be updated to the new position provided by [newItemPosition]
  ///
  /// If [item.useMaterialsFromInventory] is set to false, the same item will be returned without changes.
  /// Otherwise, it will be returned with [item.materials] property updated.
  Future<ItemAscensionMaterials> updateCalAscMatSessionItem(
    int sessionKey,
    int newItemPosition,
    ItemAscensionMaterials item, {
    bool redistribute = true,
  });

  Future<void> deleteCalAscMatSessionItem(int sessionKey, int itemIndex, {bool redistribute = true});

  Future<void> deleteAllCalAscMatSessionItems(int sessionKey);

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
}
