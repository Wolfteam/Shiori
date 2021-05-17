import 'package:darq/darq.dart';
import 'package:genshindb/domain/app_constants.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/enums/item_type.dart';
import 'package:genshindb/domain/extensions/iterable_extensions.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/domain/models/entities.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/calculator_service.dart';
import 'package:genshindb/domain/services/data_service.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/locale_service.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DataServiceImpl implements DataService {
  final GenshinService _genshinService;
  final CalculatorService _calculatorService;
  final LocaleService _localeService;

  Box<CalculatorSession> _sessionBox;
  Box<CalculatorItem> _calcItemBox;
  Box<CalculatorCharacterSkill> _calcItemSkillBox;
  Box<InventoryItem> _inventoryBox;
  Box<InventoryUsedItem> _inventoryUsedItemsBox;
  Box<UsedGameCode> _usedGameCodesBox;
  Box<TierListItem> _tierListBox;
  Box<Notification> _notificationsBox;

  DataServiceImpl(this._genshinService, this._calculatorService, this._localeService);

  Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();
    _sessionBox = await Hive.openBox<CalculatorSession>('calculatorSessions');
    _calcItemBox = await Hive.openBox<CalculatorItem>('calculatorSessionsItems');
    _calcItemSkillBox = await Hive.openBox<CalculatorCharacterSkill>('calculatorSessionsItemsSkills');
    _inventoryBox = await Hive.openBox<InventoryItem>('inventory');
    _inventoryUsedItemsBox = await Hive.openBox<InventoryUsedItem>('inventoryUsedItems');
    _usedGameCodesBox = await Hive.openBox<UsedGameCode>('usedGameCodes');
    _tierListBox = await Hive.openBox<TierListItem>('tierList');
    _notificationsBox = await Hive.openBox<Notification>('notifications');
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
      final mat = _genshinService.getMaterialByImage(material.fullImagePath);
      await _useItemFromInventory(calculatorItemKey, mat.key, ItemType.material, material.quantity);
    }

    if (!redistribute) {
      return item;
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
    final calcItem = _calcItemBox.values.firstWhere((el) => el.sessionKey == sessionKey && el.position == position, orElse: () => null);
    if (calcItem == null) {
      return;
    }
    final calcItemKey = calcItem.key as int;
    final skillsKeys = _calcItemSkillBox.values.where((el) => el.calculatorItemKey == calcItemKey).map((e) => e.key).toList();
    await _calcItemSkillBox.deleteAll(skillsKeys);

    //Make sure we delete the item before redistributing
    await _calcItemBox.delete(calcItemKey);

    await _clearUsedInventoryItems(calcItemKey, redistribute: redistribute);
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
        if (!calItem.useMaterialsFromInventory || !calItem.isActive) {
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

  @override
  List<GameCodeModel> getAllGameCodes() {
    final usedCodes = getAllUsedGameCodes();
    return _genshinService.getAllGameCodes().map((e) {
      final isUsed = usedCodes.contains(e.code);
      return GameCodeModel(code: e.code, isExpired: e.isExpired, isUsed: isUsed, rewards: e.rewards);
    }).toList();
  }

  @override
  List<String> getAllUsedGameCodes() {
    return _usedGameCodesBox.values.map((e) => e.code).toList();
  }

  @override
  Future<void> markCodeAsUsed(String code, {bool wasUsed = true}) async {
    final usedGameCode = _usedGameCodesBox.values.firstWhere((el) => el.code == code, orElse: () => null);
    if (usedGameCode != null) {
      await _usedGameCodesBox.delete(usedGameCode.key);
    }

    if (wasUsed) {
      await _usedGameCodesBox.add(UsedGameCode(code, DateTime.now()));
    }
  }

  @override
  List<TierListRowModel> getTierList() {
    final values = _tierListBox.values.toList()..sort((x, y) => x.position.compareTo(y.position));
    return values.map((e) => TierListRowModel.row(tierText: e.text, charImgs: e.charsImgs, tierColor: e.color)).toList();
  }

  @override
  Future<void> saveTierList(List<TierListRowModel> tierList) async {
    await deleteTierList();
    final toSave = tierList.mapIndex((e, i) => TierListItem(e.tierText, e.tierColor, i, e.charImgs)).toList();
    await _tierListBox.addAll(toSave);
  }

  @override
  Future<void> deleteTierList() async {
    final keys = _tierListBox.values.map((e) => e.key);
    await _tierListBox.deleteAll(keys);
  }

  @override
  List<NotificationItem> getAllNotifications() {
    return _notificationsBox.values.map((e) => _mapToNotificationItem(e)).orderBy((el) => el.createdAt).toList();
  }

  @override
  NotificationItem getNotification(int key) {
    final item = _notificationsBox.values.firstWhere((el) => el.key == key);
    return _mapToNotificationItem(item);
  }

  @override
  Future<NotificationItem> saveResinNotification(
    String itemKey,
    String title,
    String body,
    int currentResinValue, {
    String note,
    bool showNotification = true,
  }) async {
    final now = DateTime.now();
    final notification = Notification.resin(
      itemKey: itemKey,
      createdAt: now,
      completesAt: _getNotificationDateForResin(currentResinValue),
      showNotification: showNotification,
      currentResinValue: currentResinValue,
      note: note,
      title: title,
      body: body,
    );
    final key = await _notificationsBox.add(notification);
    return getNotification(key);
  }

  @override
  Future<NotificationItem> saveExpeditionNotification(
    String itemKey,
    String title,
    String body,
    ExpeditionTimeType expeditionTimeType, {
    String note,
    bool showNotification = true,
    bool withTimeReduction = false,
  }) async {
    final now = DateTime.now();
    final notification = Notification.expedition(
      itemKey: itemKey,
      createdAt: now,
      completesAt: now.add(getExpeditionDuration(expeditionTimeType, withTimeReduction)),
      showNotification: showNotification,
      withTimeReduction: withTimeReduction,
      expeditionTimeType: expeditionTimeType.index,
      note: note,
      title: title,
      body: body,
    );
    final key = await _notificationsBox.add(notification);
    return getNotification(key);
  }

  @override
  Future<NotificationItem> saveGadgetNotification(
    String itemKey,
    Duration gadgetCooldownDuration,
    String title,
    String body, {
    String note,
    bool showNotification = true,
  }) async {
    final now = DateTime.now();
    final completesAt = now.add(gadgetCooldownDuration);
    final notification = Notification.gadget(
      itemKey: itemKey,
      createdAt: now,
      completesAt: completesAt,
      showNotification: showNotification,
      note: note,
      title: title,
      body: body,
    );
    final key = await _notificationsBox.add(notification);
    return getNotification(key);
  }

  @override
  Future<NotificationItem> saveFurnitureNotification(
    String itemKey,
    FurnitureCraftingTimeType type,
    String title,
    String body, {
    String note,
    bool showNotification = true,
  }) async {
    final now = DateTime.now();
    final notification = Notification.gadget(
      itemKey: itemKey,
      createdAt: now,
      completesAt: now.add(getFurnitureDuration(type)),
      showNotification: showNotification,
      note: note,
      title: title,
      body: body,
    );
    final key = await _notificationsBox.add(notification);
    return getNotification(key);
  }

  @override
  Future<NotificationItem> saveFarmingArtifactNotification(
    String itemKey,
    ArtifactFarmingTimeType type,
    String title,
    String body, {
    String note,
    bool showNotification = true,
  }) async {
    final now = DateTime.now();
    final completesAt = now.add(getArtifactFarmingCooldownDuration(type));
    final notification = Notification.farmingArtifact(
      itemKey: itemKey,
      createdAt: now,
      completesAt: completesAt,
      showNotification: showNotification,
      note: note,
      title: title,
      body: body,
      artifactFarmingTimeType: type.index,
    );
    final key = await _notificationsBox.add(notification);
    return getNotification(key);
  }

  @override
  Future<NotificationItem> saveFarmingMaterialNotification(
    String itemKey,
    String title,
    String body, {
    String note,
    bool showNotification = true,
  }) async {
    final now = DateTime.now();
    final completesAt = now.add(_genshinService.getMaterial(itemKey).farmingRespawnDuration);
    final notification = Notification.farmingMaterials(
      itemKey: itemKey,
      createdAt: now,
      completesAt: completesAt,
      showNotification: showNotification,
      note: note,
      title: title,
      body: body,
    );
    final key = await _notificationsBox.add(notification);
    return getNotification(key);
  }

  @override
  Future<NotificationItem> saveCustomNotification(
    String itemKey,
    String title,
    String body,
    DateTime createdAt,
    DateTime completesAt,
    AppNotificationItemType notificationItemType, {
    String note,
    bool showNotification = true,
  }) async {
    final notification = Notification.custom(
      itemKey: itemKey,
      createdAt: createdAt,
      completesAt: completesAt,
      showNotification: showNotification,
      note: note,
      notificationItemType: notificationItemType.index,
      title: title,
      body: body,
    );
    final key = await _notificationsBox.add(notification);
    return getNotification(key);
  }

  @override
  Future<void> deleteNotification(int key) {
    return _notificationsBox.delete(key);
  }

  @override
  Future<NotificationItem> resetNotification(int key) async {
    final item = _notificationsBox.values.firstWhere((el) => el.key == key);
    final duration = item.originalScheduledDate.difference(item.createdAt);
    item.completesAt = DateTime.now().add(duration);

    await item.save();
    return _mapToNotificationItem(item);
  }

  @override
  Future<NotificationItem> stopNotification(int key) async {
    final item = _notificationsBox.values.firstWhere((el) => el.key == key);
    item.completesAt = DateTime.now();

    await item.save();
    return _mapToNotificationItem(item);
  }

  @override
  Future<NotificationItem> updateResinNotification(
    int key,
    String title,
    String body,
    int currentResinValue,
    bool showNotification, {
    String note,
  }) {
    final item = _notificationsBox.values.firstWhere((el) => el.key == key);
    item.currentResinValue = currentResinValue;
    if (currentResinValue != item.currentResinValue) {
      item.completesAt = _getNotificationDateForResin(currentResinValue);
    }

    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> updateExpeditionNotification(
    int key,
    ExpeditionTimeType expeditionTimeType,
    String title,
    String body,
    bool showNotification,
    bool withTimeReduction, {
    String note,
  }) {
    final item = _notificationsBox.values.firstWhere((el) => el.key == key);
    if (item.expeditionTimeType != expeditionTimeType.index || item.withTimeReduction != withTimeReduction) {
      final now = DateTime.now();
      item.completesAt = now.add(getExpeditionDuration(expeditionTimeType, withTimeReduction));
    }
    item.expeditionTimeType = expeditionTimeType.index;
    item.withTimeReduction = withTimeReduction;

    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> updateFarmingMaterialNotification(
    int key,
    String itemKey,
    String title,
    String body,
    bool showNotification, {
    String note,
  }) {
    final item = _notificationsBox.values.firstWhere((el) => el.key == key);
    if (item.itemKey != itemKey) {
      final newDuration = _genshinService.getMaterial(itemKey).farmingRespawnDuration;
      item.completesAt = DateTime.now().add(newDuration);
    }

    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> updateFarmingArtifactNotification(
    int key,
    ArtifactFarmingTimeType type,
    String title,
    String body,
    bool showNotification, {
    String note,
  }) {
    final item = _notificationsBox.values.firstWhere((el) => el.key == key);
    if (type.index != item.artifactFarmingTimeType) {
      final newDuration = getArtifactFarmingCooldownDuration(type);
      item.completesAt = DateTime.now().add(newDuration);
    }
    item.artifactFarmingTimeType = type.index;

    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> updateGadgetNotification(
    int key,
    String title,
    String body,
    bool showNotification, {
    String note,
  }) {
    //TODO: SHOULD I ALLOW UPDATING THE GADGET ITEM?
    final item = _notificationsBox.values.firstWhere((el) => el.key == key);
    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> updateFurnitureNotification(
    int key,
    FurnitureCraftingTimeType type,
    String title,
    String body,
    bool showNotification, {
    String note,
  }) {
    final item = _notificationsBox.values.firstWhere((el) => el.key == key);
    if (item.furnitureCraftingTimeType != type.index) {
      item.furnitureCraftingTimeType = type.index;
      item.completesAt = DateTime.now().add(getFurnitureDuration(type));
    }

    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> updateCustomNotification(
    int key,
    String itemKey,
    String title,
    String body,
    DateTime completesAt,
    bool showNotification,
    AppNotificationItemType notificationItemType, {
    String note,
  }) async {
    final item = _notificationsBox.values.firstWhere((el) => el.key == key);
    item
      ..itemKey = itemKey
      ..notificationItemType = notificationItemType.index;

    if (item.completesAt != completesAt) {
      item.completesAt = completesAt;
    }

    return _updateNotification(item, title, body, note, showNotification);
  }

  void _registerAdapters() {
    Hive.registerAdapter(CalculatorCharacterSkillAdapter());
    Hive.registerAdapter(CalculatorItemAdapter());
    Hive.registerAdapter(CalculatorSessionAdapter());
    Hive.registerAdapter(InventoryItemAdapter());
    Hive.registerAdapter(InventoryUsedItemAdapter());
    Hive.registerAdapter(UsedGameCodeAdapter());
    Hive.registerAdapter(TierListItemAdapter());
    Hive.registerAdapter(NotificationAdapter());
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

    if (item.useMaterialsFromInventory && item.isActive && includeInventory && calculatorItemKey != null) {
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

    if (item.useMaterialsFromInventory && item.isActive && includeInventory && calculatorItemKey != null) {
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

  NotificationItem _mapToNotificationItem(Notification e) {
    final type = AppNotificationType.values[e.type];
    final itemType = e.notificationItemType == null ? null : AppNotificationItemType.values[e.notificationItemType];
    final expeditionType = e.expeditionTimeType == null ? null : ExpeditionTimeType.values[e.expeditionTimeType];
    final furnitureCraftingType = e.furnitureCraftingTimeType == null ? null : FurnitureCraftingTimeType.values[e.furnitureCraftingTimeType];
    return NotificationItem(
      key: e.key as int,
      image: _genshinService.getItemImageFromNotificationType(e.itemKey, type, notificationItemType: itemType),
      createdAt: e.createdAt,
      completesAt: e.completesAt,
      type: type,
      showNotification: e.showNotification,
      currentResinValue: e.currentResinValue,
      withTimeReduction: e.withTimeReduction,
      notificationItemType: itemType,
      expeditionTimeType: expeditionType,
      note: e.note,
      title: e.title,
      body: e.body,
      scheduledDate: e.originalScheduledDate,
      furnitureCraftingTimeType: furnitureCraftingType,
    );
  }

  DateTime _getNotificationDateForResin(int currentResinValue) {
    final now = DateTime.now();
    final diff = maxResinValue - currentResinValue;
    return now.add(Duration(minutes: diff * resinRefillsEach));
  }

  Future<NotificationItem> _updateNotification(Notification notification, String title, String body, String note, bool showNotification) async {
    notification
      ..title = title
      ..note = note
      ..body = body
      ..showNotification = showNotification;
    await notification.save();
    return getNotification(notification.key as int);
  }
}
