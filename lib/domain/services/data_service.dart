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

  List<NotificationItem> getAllNotifications();

  NotificationItem getNotification(int key);

  Future<NotificationItem> saveResinNotification(
    String itemKey,
    String title,
    String body,
    int currentResinValue, {
    String note,
    bool showNotification = true,
  });

  Future<NotificationItem> saveExpeditionNotification(
    String itemKey,
    String title,
    String body,
    ExpeditionTimeType expeditionTimeType, {
    String note,
    bool showNotification = true,
    bool withTimeReduction = false,
  });

  Future<NotificationItem> saveCustomNotification(
    String itemKey,
    String title,
    String body,
    DateTime createdAt,
    DateTime completesAt,
    AppNotificationItemType notificationItemType, {
    String note,
    bool showNotification = true,
  });

  Future<void> deleteNotification(int key);

  Future<NotificationItem> resetNotification(int key);

  Future<NotificationItem> stopNotification(int key);

  Future<NotificationItem> updateResinNotification(
    int key,
    String title,
    String body,
    int currentResinValue,
    bool showNotification, {
    String note,
  });

  Future<NotificationItem> updateExpeditionNotification(
    int key,
    ExpeditionTimeType expeditionTimeType,
    String title,
    String body,
    bool showNotification,
    bool withTimeReduction, {
    String note,
  });

  Future<NotificationItem> updateCustomNotification(
    int key,
    String itemKey,
    String title,
    String body,
    DateTime completesAt,
    bool showNotification,
    AppNotificationItemType notificationItemType, {
    String note,
  });
}
