import 'dart:async';

import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/persistence/base_data_service.dart';

abstract class CalculatorAscMaterialsDataService implements BaseDataService {
  StreamController<CalculatorAscMaterialSessionItemEvent> get itemAdded;

  StreamController<CalculatorAscMaterialSessionItemEvent> get itemDeleted;

  List<CalculatorSessionModel> getAllSessions();

  CalculatorSessionModel getSession(int sessionKey);

  Future<CalculatorSessionModel> createSession(String name, int position);

  Future<CalculatorSessionModel> updateSession(int sessionKey, String name, int position, {bool redistributeMaterials = false});

  Future<void> deleteSession(int sessionKey);

  Future<void> deleteAllSessions();

  List<ItemAscensionMaterials> getAllSessionItems(int sessionKey);

  Future<void> addSessionItems(int sessionKey, List<ItemAscensionMaterials> items, {bool redistributeAtTheEnd = true});

  /// Adds a new calc. item to the provided session by using the [sessionKey].
  ///
  /// If [item.useMaterialsFromInventory] is set to false, the same item will be returned without changes.
  /// Otherwise, it will be returned with [item.materials] property updated.
  Future<ItemAscensionMaterials> addSessionItem(
    int sessionKey,
    ItemAscensionMaterials item,
    List<String> allPossibleItemMaterialsKeys, {
    bool redistribute = true,
  });

  /// Updates the provided item associated to the session [sessionKey]
  ///
  /// The item will be retrieved using the current value of [item.position]
  /// and it will also be updated to the new position provided by [newItemPosition]
  ///
  /// If [item.useMaterialsFromInventory] is set to false, the same item will be returned without changes.
  /// Otherwise, it will be returned with [item.materials] property updated.
  Future<ItemAscensionMaterials> updateSessionItem(
    int sessionKey,
    int newItemPosition,
    ItemAscensionMaterials item,
    List<String> allPossibleItemMaterialsKeys, {
    bool redistribute = true,
  });

  Future<void> deleteSessionItem(int sessionKey, int itemIndex, {bool redistribute = true});

  Future<void> deleteAllSessionItems(int sessionKey);

  /// This method redistributes all the materials in the inventory by calling [redistributeInventoryMaterial]
  /// for each of the available sessions.
  ///
  /// This method should only be called when the priority of a session or calc. session changes
  Future<void> redistributeAllInventoryMaterials({List<String> onlyMaterialKeys = const <String>[]});

  /// This method redistributes the material associated to [itemKey] based on the [newQuantity]
  ///
  /// This method should only be called when the quantity of a material changes
  ///
  ///
  /// E.g: If we now have more, we may update the used quantity in a [InventoryUsedItem] to use more,
  /// otherwise we may reduce the used quantity or even delete the whole thing
  Future<void> redistributeInventoryMaterial(String itemKey, int newQuantity);

  Future<void> redistributeInventoryMaterialsFromSessionPosition(
    int sessionKey, {
    List<String> onlyMaterialKeys = const <String>[],
  });

  List<BackupCalculatorAscMaterialsSessionModel> getDataForBackup();

  Future<void> restoreFromBackup(List<BackupCalculatorAscMaterialsSessionModel> data);

  Future<void> reorderSessions(List<CalculatorSessionModel> updated);

  Future<void> reorderItems(int sessionKey, List<ItemAscensionMaterials> updatedItems);
}
