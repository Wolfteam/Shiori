import 'package:collection/collection.dart' show IterableExtension;
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
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DataServiceImpl implements DataService {
  final GenshinService _genshinService;
  final CalculatorService _calculatorService;

  late Box<CalculatorSession> _sessionBox;
  late Box<CalculatorItem> _calcItemBox;
  late Box<CalculatorCharacterSkill> _calcItemSkillBox;
  late Box<InventoryItem> _inventoryBox;
  late Box<InventoryUsedItem> _inventoryUsedItemsBox;
  late Box<GameCode> _gameCodesBox;
  late Box<GameCodeReward> _gameCodeRewardsBox;
  late Box<TierListItem> _tierListBox;

  late Box<NotificationCustom> _notificationsCustomBox;
  late Box<NotificationExpedition> _notificationsExpeditionBox;
  late Box<NotificationFarmingArtifact> _notificationsFarmingArtifactBox;
  late Box<NotificationFarmingMaterial> _notificationsFarmingMaterialBox;
  late Box<NotificationFurniture> _notificationsFurnitureBox;
  late Box<NotificationGadget> _notificationsGadgetBox;
  late Box<NotificationRealmCurrency> _notificationsRealmCurrencyBox;
  late Box<NotificationResin> _notificationsResinBox;
  late Box<NotificationWeeklyBoss> _notificationsWeeklyBossBox;

  DataServiceImpl(this._genshinService, this._calculatorService);

  Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();
    _sessionBox = await Hive.openBox<CalculatorSession>('calculatorSessions');
    _calcItemBox = await Hive.openBox<CalculatorItem>('calculatorSessionsItems');
    _calcItemSkillBox = await Hive.openBox<CalculatorCharacterSkill>('calculatorSessionsItemsSkills');
    _inventoryBox = await Hive.openBox<InventoryItem>('inventory');
    _inventoryUsedItemsBox = await Hive.openBox<InventoryUsedItem>('inventoryUsedItems');
    _gameCodesBox = await Hive.openBox<GameCode>('gameCodes');
    _gameCodeRewardsBox = await Hive.openBox<GameCodeReward>('gameCodeRewards');
    _tierListBox = await Hive.openBox<TierListItem>('tierList');

    _notificationsCustomBox = await Hive.openBox('notificationsCustom');
    _notificationsExpeditionBox = await Hive.openBox('notificationsExpedition');
    _notificationsFarmingArtifactBox = await Hive.openBox('notificationsFarmingArtifact');
    _notificationsFarmingMaterialBox = await Hive.openBox('notificationsFarmingMaterial');
    _notificationsFurnitureBox = await Hive.openBox('notificationsFurniture');
    _notificationsGadgetBox = await Hive.openBox('notificationsGadget');
    _notificationsRealmCurrencyBox = await Hive.openBox('notificationsRealmCurrency');
    _notificationsResinBox = await Hive.openBox('notificationsResin');
    _notificationsWeeklyBossBox = await Hive.openBox('notificationsWeeklyBoss');
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
              .firstWhereOrNull(
                (el) => el.calculatorItemKey == calculatorItemKey && el.itemKey == material.key && el.type == ItemType.material.index,
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
  Future<void> deleteCalAscMatSessionItem(int sessionKey, int? position, {bool redistribute = true}) async {
    final calcItem = _calcItemBox.values.firstWhereOrNull((el) => el.sessionKey == sessionKey && el.position == position);
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
  Future<void> deleteItemsFromInventory(ItemType type) async {
    switch (type) {
      case ItemType.character:
      case ItemType.weapon:
      case ItemType.artifact:
        final toDeleteKeys = _inventoryBox.values.where((el) => el.type == type.index).map((e) => e.key).toList();
        if (toDeleteKeys.isNotEmpty) {
          await _inventoryBox.deleteAll(toDeleteKeys);
        }
        break;
      case ItemType.material:
        final materialsInInventory = _inventoryBox.values.where((el) => el.type == ItemType.material.index && el.quantity > 0).toList();
        for (final material in materialsInInventory) {
          material.quantity = 0;
          await material.save();
        }
        final usedItemKeys = _inventoryUsedItemsBox.values.map((e) => e.key).toList();
        _inventoryUsedItemsBox.deleteAll(usedItemKeys);
        break;
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
        final desiredQuantityToUse = item.materials.firstWhereOrNull((el) => el.fullImagePath == material.fullImagePath)?.quantity ?? 0;

        //Next, we check if there is a used item for this calculator item
        var usedInInventory = _inventoryUsedItemsBox.values.firstWhereOrNull((el) => el.calculatorItemKey == calItem.key && el.itemKey == itemKey);

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
    return _gameCodesBox.values.map((e) {
      final rewards = _gameCodeRewardsBox.values.where((el) => el.gameCodeKey == e.key).map((reward) {
        final material = _genshinService.getMaterial(reward.itemKey);
        return ItemAscensionMaterialModel(quantity: reward.quantity, image: material.image, materialType: material.type);
      }).toList();
      return GameCodeModel(
        code: e.code,
        isExpired: e.isExpired,
        expiredOn: e.expiredOn,
        discoveredOn: e.discoveredOn,
        isUsed: e.usedOn != null,
        rewards: rewards,
        region: e.region != null ? AppServerResetTimeType.values[e.region!] : null,
      );
    }).toList();
  }

  @override
  Future<void> saveGameCodes(List<GameCodeModel> itemsFromApi) async {
    final itemsOnDb = _gameCodesBox.values.toList();

    for (final item in itemsFromApi) {
      final gcOnDb = itemsOnDb.firstWhereOrNull((el) => el.code == item.code);
      if (gcOnDb != null) {
        gcOnDb.isExpired = item.isExpired;
        gcOnDb.expiredOn = item.expiredOn;
        gcOnDb.discoveredOn = item.discoveredOn;
        gcOnDb.region = item.region?.index;
        await gcOnDb.save();
        await deleteAllGameCodeRewards(gcOnDb.key as int);
        await saveGameCodeRewards(gcOnDb.key as int, item.rewards);
      } else {
        final gc = GameCode(item.code, null, item.discoveredOn, item.expiredOn, item.isExpired, item.region?.index);
        await _gameCodesBox.add(gc);
        //This line shouldn't be necessary, though for testing purposes I'll leave it here
        await deleteAllGameCodeRewards(gc.key as int);
        await saveGameCodeRewards(gc.key as int, item.rewards);
      }
    }
  }

  @override
  Future<void> saveGameCodeRewards(int gameCodeKey, List<ItemAscensionMaterialModel> rewards) {
    final rewardsToSave = rewards
        .map(
          (e) => GameCodeReward(gameCodeKey, _genshinService.getMaterialByImage(e.fullImagePath).key, e.quantity),
        )
        .toList();
    return _gameCodeRewardsBox.addAll(rewardsToSave);
  }

  @override
  Future<void> deleteAllGameCodeRewards(int gameCodeKey) {
    final keys = _gameCodeRewardsBox.values.where((el) => el.gameCodeKey == gameCodeKey).map((e) => e.key).toList();
    return _gameCodeRewardsBox.deleteAll(keys);
  }

  @override
  Future<void> markCodeAsUsed(String code, {bool wasUsed = true}) async {
    final usedGameCode = _gameCodesBox.values.firstWhereOrNull((el) => el.code == code)!;
    usedGameCode.usedOn = wasUsed ? DateTime.now() : null;
    await usedGameCode.save();
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
    final notifications = _notificationsCustomBox.values.map((e) => _mapToNotificationItem(e)).toList() +
        _notificationsExpeditionBox.values.map((e) => _mapToNotificationItem(e)).toList() +
        _notificationsFarmingArtifactBox.values.map((e) => _mapToNotificationItem(e)).toList() +
        _notificationsFarmingMaterialBox.values.map((e) => _mapToNotificationItem(e)).toList() +
        _notificationsFurnitureBox.values.map((e) => _mapToNotificationItem(e)).toList() +
        _notificationsGadgetBox.values.map((e) => _mapToNotificationItem(e)).toList() +
        _notificationsRealmCurrencyBox.values.map((e) => _mapToNotificationItem(e)).toList() +
        _notificationsResinBox.values.map((e) => _mapToNotificationItem(e)).toList() +
        _notificationsWeeklyBossBox.values.map((e) => _mapToNotificationItem(e)).toList();
    return notifications.orderBy((el) => el.createdAt).toList();
  }

  @override
  NotificationItem getNotification(int key, AppNotificationType type) {
    final item = _getNotification(key, type);
    return _mapToNotificationItem(item);
  }

  @override
  Future<NotificationItem> saveResinNotification(
    String itemKey,
    String title,
    String body,
    int currentResinValue, {
    String? note,
    bool showNotification = true,
  }) async {
    final now = DateTime.now();
    final notification = NotificationResin(
      itemKey: itemKey,
      createdAt: now,
      completesAt: getNotificationDateForResin(currentResinValue),
      showNotification: showNotification,
      currentResinValue: currentResinValue,
      note: note?.trim(),
      title: title.trim(),
      body: body.trim(),
    );
    final key = await _notificationsResinBox.add(notification);
    return getNotification(key, AppNotificationType.resin);
  }

  @override
  Future<NotificationItem> saveExpeditionNotification(
    String itemKey,
    String title,
    String body,
    ExpeditionTimeType expeditionTimeType, {
    String? note,
    bool showNotification = true,
    bool withTimeReduction = false,
  }) async {
    final now = DateTime.now();
    final notification = NotificationExpedition(
      itemKey: itemKey,
      createdAt: now,
      completesAt: now.add(getExpeditionDuration(expeditionTimeType, withTimeReduction)),
      showNotification: showNotification,
      withTimeReduction: withTimeReduction,
      expeditionTimeType: expeditionTimeType.index,
      note: note?.trim(),
      title: title.trim(),
      body: body.trim(),
    );
    final key = await _notificationsExpeditionBox.add(notification);
    return getNotification(key, AppNotificationType.expedition);
  }

  @override
  Future<NotificationItem> saveGadgetNotification(
    String itemKey,
    String title,
    String body, {
    String? note,
    bool showNotification = true,
  }) async {
    final now = DateTime.now();
    final gadget = _genshinService.getGadget(itemKey);
    final completesAt = now.add(gadget.cooldownDuration!);
    final notification = NotificationGadget(
      itemKey: itemKey,
      createdAt: now,
      completesAt: completesAt,
      showNotification: showNotification,
      note: note?.trim(),
      title: title.trim(),
      body: body.trim(),
    );
    final key = await _notificationsGadgetBox.add(notification);
    return getNotification(key, AppNotificationType.gadget);
  }

  @override
  Future<NotificationItem> saveFurnitureNotification(
    String itemKey,
    FurnitureCraftingTimeType type,
    String title,
    String body, {
    String? note,
    bool showNotification = true,
  }) async {
    final now = DateTime.now();
    final notification = NotificationFurniture(
      itemKey: itemKey,
      createdAt: now,
      completesAt: now.add(getFurnitureDuration(type)),
      showNotification: showNotification,
      note: note?.trim(),
      title: title.trim(),
      body: body.trim(),
      furnitureCraftingTimeType: type.index,
    );
    final key = await _notificationsFurnitureBox.add(notification);
    return getNotification(key, AppNotificationType.furniture);
  }

  @override
  Future<NotificationItem> saveFarmingArtifactNotification(
    String itemKey,
    ArtifactFarmingTimeType type,
    String title,
    String body, {
    String? note,
    bool showNotification = true,
  }) async {
    final now = DateTime.now();
    final completesAt = now.add(getArtifactFarmingCooldownDuration(type));
    final notification = NotificationFarmingArtifact(
      itemKey: itemKey,
      createdAt: now,
      completesAt: completesAt,
      showNotification: showNotification,
      note: note?.trim(),
      title: title.trim(),
      body: body.trim(),
      artifactFarmingTimeType: type.index,
    );
    final key = await _notificationsFarmingArtifactBox.add(notification);
    return getNotification(key, AppNotificationType.farmingArtifacts);
  }

  @override
  Future<NotificationItem> saveFarmingMaterialNotification(
    String itemKey,
    String title,
    String body, {
    String? note,
    bool showNotification = true,
  }) async {
    final now = DateTime.now();
    final completesAt = now.add(_genshinService.getMaterial(itemKey).farmingRespawnDuration!);
    final notification = NotificationFarmingMaterial(
      itemKey: itemKey,
      createdAt: now,
      completesAt: completesAt,
      showNotification: showNotification,
      note: note?.trim(),
      title: title.trim(),
      body: body.trim(),
    );
    final key = await _notificationsFarmingMaterialBox.add(notification);
    return getNotification(key, AppNotificationType.farmingMaterials);
  }

  @override
  Future<NotificationItem> saveRealmCurrencyNotification(
    String itemKey,
    RealmRankType realmRankType,
    int currentTrustRankLevel,
    int currentRealmCurrency,
    String title,
    String body, {
    String? note,
    bool showNotification = true,
  }) async {
    final now = DateTime.now();
    final completesAt = now.add(getRealmCurrencyDuration(currentRealmCurrency, currentTrustRankLevel, realmRankType));
    final notification = NotificationRealmCurrency(
      itemKey: itemKey,
      createdAt: now,
      completesAt: completesAt,
      realmCurrency: currentRealmCurrency,
      realmRankType: realmRankType.index,
      realmTrustRank: currentTrustRankLevel,
      showNotification: showNotification,
      note: note?.trim(),
      title: title.trim(),
      body: body.trim(),
    );
    final key = await _notificationsRealmCurrencyBox.add(notification);
    return getNotification(key, AppNotificationType.realmCurrency);
  }

  @override
  Future<NotificationItem> saveWeeklyBossNotification(
    String itemKey,
    AppServerResetTimeType serverResetTimeType,
    String title,
    String body, {
    String? note,
    bool showNotification = true,
  }) async {
    final now = DateTime.now();
    final completesAt = _genshinService.getNextDateForWeeklyBoss(serverResetTimeType);
    final notification = NotificationWeeklyBoss(
      itemKey: itemKey,
      createdAt: now,
      completesAt: completesAt,
      showNotification: showNotification,
      note: note?.trim(),
      title: title.trim(),
      body: body.trim(),
    );
    final key = await _notificationsWeeklyBossBox.add(notification);
    return getNotification(key, AppNotificationType.weeklyBoss);
  }

  @override
  Future<NotificationItem> saveCustomNotification(
    String itemKey,
    String title,
    String body,
    DateTime completesAt,
    AppNotificationItemType notificationItemType, {
    String? note,
    bool showNotification = true,
  }) async {
    final now = DateTime.now();
    final notification = NotificationCustom.custom(
      itemKey: itemKey,
      createdAt: now,
      completesAt: completesAt,
      showNotification: showNotification,
      notificationItemType: notificationItemType.index,
      note: note?.trim(),
      title: title.trim(),
      body: body.trim(),
    );
    final key = await _notificationsCustomBox.add(notification);
    return getNotification(key, AppNotificationType.custom);
  }

  @override
  Future<NotificationItem> saveDailyCheckInNotification(
    String itemKey,
    String title,
    String body, {
    String? note,
    bool showNotification = true,
  }) async {
    final now = DateTime.now();
    final notification = NotificationCustom.forDailyCheckIn(
      itemKey: itemKey,
      createdAt: now,
      completesAt: now.add(dailyCheckInResetDuration),
      showNotification: showNotification,
      note: note?.trim(),
      title: title.trim(),
      body: body.trim(),
    );
    final key = await _notificationsCustomBox.add(notification);
    return getNotification(key, AppNotificationType.dailyCheckIn);
  }

  @override
  Future<void> deleteNotification(int key, AppNotificationType type) {
    switch (type) {
      case AppNotificationType.resin:
        return _notificationsResinBox.delete(key);
      case AppNotificationType.expedition:
        return _notificationsExpeditionBox.delete(key);
      case AppNotificationType.farmingMaterials:
        return _notificationsFarmingMaterialBox.delete(key);
      case AppNotificationType.farmingArtifacts:
        return _notificationsFarmingArtifactBox.delete(key);
      case AppNotificationType.gadget:
        return _notificationsGadgetBox.delete(key);
      case AppNotificationType.furniture:
        return _notificationsFurnitureBox.delete(key);
      case AppNotificationType.realmCurrency:
        return _notificationsRealmCurrencyBox.delete(key);
      case AppNotificationType.weeklyBoss:
        return _notificationsWeeklyBossBox.delete(key);
      case AppNotificationType.custom:
      case AppNotificationType.dailyCheckIn:
        return _notificationsCustomBox.delete(key);
      default:
        throw Exception('Invalid notification type = $type');
    }
  }

  @override
  Future<NotificationItem> resetNotification(int key, AppNotificationType type, AppServerResetTimeType serverResetTimeType) async {
    switch (type) {
      case AppNotificationType.resin:
        final item = _getNotification<NotificationResin>(key, type);
        item.currentResinValue = 0;
        item.completesAt = getNotificationDateForResin(item.currentResinValue);
        await item.save();
        return _mapToNotificationItem(item);
      case AppNotificationType.expedition:
        final item = _getNotification<NotificationExpedition>(key, type);
        final duration = getExpeditionDuration(ExpeditionTimeType.values[item.expeditionTimeType], item.withTimeReduction);
        item.completesAt = DateTime.now().add(duration);
        await item.save();
        return _mapToNotificationItem(item);
      case AppNotificationType.farmingMaterials:
        final item = _getNotification<NotificationFarmingMaterial>(key, type);
        item.completesAt = DateTime.now().add(_genshinService.getMaterial(item.itemKey).farmingRespawnDuration!);
        await item.save();
        return _mapToNotificationItem(item);
      case AppNotificationType.farmingArtifacts:
        final item = _getNotification<NotificationFarmingArtifact>(key, type);
        item.completesAt = DateTime.now().add(getArtifactFarmingCooldownDuration(ArtifactFarmingTimeType.values[item.artifactFarmingTimeType]));
        await item.save();
        return _mapToNotificationItem(item);
      case AppNotificationType.gadget:
        final item = _getNotification<NotificationGadget>(key, type);
        item.completesAt = DateTime.now().add(_genshinService.getGadget(item.itemKey).cooldownDuration!);
        await item.save();
        return _mapToNotificationItem(item);
      case AppNotificationType.furniture:
        final item = _getNotification<NotificationFurniture>(key, type);
        item.completesAt = DateTime.now().add(getFurnitureDuration(FurnitureCraftingTimeType.values[item.furnitureCraftingTimeType]));
        await item.save();
        return _mapToNotificationItem(item);
      case AppNotificationType.realmCurrency:
        final item = _getNotification<NotificationRealmCurrency>(key, type);
        item.realmCurrency = 0;
        item.completesAt = DateTime.now().add(getRealmCurrencyDuration(
          item.realmCurrency,
          item.realmTrustRank,
          RealmRankType.values[item.realmRankType],
        ));
        await item.save();
        return _mapToNotificationItem(item);
      case AppNotificationType.weeklyBoss:
        final item = _getNotification<NotificationWeeklyBoss>(key, type);
        item.completesAt = _genshinService.getNextDateForWeeklyBoss(serverResetTimeType);
        await item.save();
        return _mapToNotificationItem(item);
      case AppNotificationType.custom:
        break;
      case AppNotificationType.dailyCheckIn:
        final item = _getNotification<NotificationCustom>(key, type);
        item.completesAt = DateTime.now().add(const Duration(hours: 24));
        await item.save();
        return _mapToNotificationItem(item);
    }

    throw Exception('The provided app notification type = $type is not valid for a reset');
  }

  @override
  Future<NotificationItem> stopNotification(int key, AppNotificationType type) async {
    final item = _getNotification(key, type);
    item.completesAt = DateTime.now();

    await (item as HiveObject).save();
    return _mapToNotificationItem(item);
  }

  @override
  Future<NotificationItem> updateResinNotification(
    int key,
    String itemKey,
    String title,
    String body,
    int currentResinValue,
    bool showNotification, {
    String? note,
  }) {
    final item = _notificationsResinBox.values.firstWhere((el) => el.key == key);
    final isCompleted = item.completesAt.isBefore(DateTime.now());
    if (currentResinValue != item.currentResinValue || isCompleted) {
      item.completesAt = getNotificationDateForResin(currentResinValue);
    }
    item.itemKey = itemKey;
    item.currentResinValue = currentResinValue;
    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> updateExpeditionNotification(
    int key,
    String itemKey,
    ExpeditionTimeType expeditionTimeType,
    String title,
    String body,
    bool showNotification,
    bool withTimeReduction, {
    String? note,
  }) {
    final item = _notificationsExpeditionBox.values.firstWhere((el) => el.key == key);
    final isCompleted = item.completesAt.isBefore(DateTime.now());
    if (item.expeditionTimeType != expeditionTimeType.index || item.withTimeReduction != withTimeReduction || isCompleted) {
      final now = DateTime.now();
      item.completesAt = now.add(getExpeditionDuration(expeditionTimeType, withTimeReduction));
    }
    item.expeditionTimeType = expeditionTimeType.index;
    item.withTimeReduction = withTimeReduction;
    item.itemKey = itemKey;

    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> updateFarmingMaterialNotification(
    int key,
    String itemKey,
    String title,
    String body,
    bool showNotification, {
    String? note,
  }) {
    final item = _notificationsFarmingMaterialBox.values.firstWhere((el) => el.key == key);
    final isCompleted = item.completesAt.isBefore(DateTime.now());
    if (item.itemKey != itemKey || isCompleted) {
      final newDuration = _genshinService.getMaterial(itemKey).farmingRespawnDuration!;
      item.completesAt = DateTime.now().add(newDuration);
    }

    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> updateFarmingArtifactNotification(
    int key,
    String itemKey,
    ArtifactFarmingTimeType type,
    String title,
    String body,
    bool showNotification, {
    String? note,
  }) {
    final item = _notificationsFarmingArtifactBox.values.firstWhere((el) => el.key == key);
    final isCompleted = item.completesAt.isBefore(DateTime.now());
    if (type.index != item.artifactFarmingTimeType || isCompleted) {
      final newDuration = getArtifactFarmingCooldownDuration(type);
      item.completesAt = DateTime.now().add(newDuration);
    }
    item.artifactFarmingTimeType = type.index;
    item.itemKey = itemKey;

    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> updateGadgetNotification(
    int key,
    String itemKey,
    String title,
    String body,
    bool showNotification, {
    String? note,
  }) {
    final item = _notificationsGadgetBox.values.firstWhere((el) => el.key == key);
    final isCompleted = item.completesAt.isBefore(DateTime.now());
    if (item.itemKey != itemKey || isCompleted) {
      final gadget = _genshinService.getGadget(item.itemKey);
      final now = DateTime.now();
      item.completesAt = now.add(gadget.cooldownDuration!);
      item.itemKey = itemKey;
    }

    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> updateFurnitureNotification(
    int key,
    String itemKey,
    FurnitureCraftingTimeType type,
    String title,
    String body,
    bool showNotification, {
    String? note,
  }) {
    final item = _notificationsFurnitureBox.values.firstWhere((el) => el.key == key);
    final isCompleted = item.completesAt.isBefore(DateTime.now());
    item.itemKey = itemKey;
    if (item.furnitureCraftingTimeType != type.index || isCompleted) {
      item.furnitureCraftingTimeType = type.index;
      item.completesAt = DateTime.now().add(getFurnitureDuration(type));
    }

    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> updateRealmCurrencyNotification(
    int key,
    String itemKey,
    RealmRankType realmRankType,
    int currentTrustRankLevel,
    int currentRealmCurrency,
    String title,
    String body,
    bool showNotification, {
    String? note,
  }) {
    final item = _notificationsRealmCurrencyBox.values.firstWhere((el) => el.key == key);
    final isCompleted = item.completesAt.isBefore(DateTime.now());
    item.itemKey = itemKey;
    if (item.realmRankType != realmRankType.index ||
        item.realmTrustRank != currentTrustRankLevel ||
        item.realmCurrency != currentRealmCurrency ||
        isCompleted) {
      final duration = getRealmCurrencyDuration(currentRealmCurrency, currentTrustRankLevel, realmRankType);
      item.completesAt = DateTime.now().add(duration);
      item.realmRankType = realmRankType.index;
      item.realmTrustRank = currentTrustRankLevel;
      item.realmCurrency = currentRealmCurrency;
    }

    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> updateWeeklyBossNotification(
    int key,
    AppServerResetTimeType serverResetTimeType,
    String itemKey,
    String title,
    String body,
    bool showNotification, {
    String? note,
  }) {
    final item = _notificationsWeeklyBossBox.values.firstWhere((el) => el.key == key);
    final isCompleted = item.completesAt.isBefore(DateTime.now());
    if (item.itemKey != itemKey) {
      item.itemKey = itemKey;
    }
    if (isCompleted) {
      item.completesAt = _genshinService.getNextDateForWeeklyBoss(serverResetTimeType);
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
    String? note,
  }) async {
    final item = _notificationsCustomBox.values.firstWhere((el) => el.key == key);
    item
      ..itemKey = itemKey
      ..notificationItemType = notificationItemType.index;

    if (item.completesAt != completesAt) {
      item.completesAt = completesAt;
    }

    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> updateDailyCheckInNotification(
    int key,
    String itemKey,
    String title,
    String body,
    bool showNotification, {
    String? note,
  }) async {
    final item = _notificationsCustomBox.values.firstWhere((el) => el.key == key);
    final isCompleted = item.completesAt.isBefore(DateTime.now());
    item.itemKey = itemKey;

    if (isCompleted) {
      item.completesAt = DateTime.now().add(dailyCheckInResetDuration);
    }

    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> reduceNotificationHours(int key, AppNotificationType type, int hours) {
    final notSupportedTypes = [AppNotificationType.realmCurrency, AppNotificationType.resin];
    assert(!notSupportedTypes.contains(type));

    final item = _getNotification(key, type);
    final now = DateTime.now();
    var completesAt = item.completesAt.subtract(Duration(hours: hours));

    if (completesAt.isBefore(now)) {
      completesAt = now;
    }

    item.completesAt = completesAt;
    return _updateNotification(item, item.title, item.body, item.note, item.showNotification);
  }

  void _registerAdapters() {
    Hive.registerAdapter(CalculatorCharacterSkillAdapter());
    Hive.registerAdapter(CalculatorItemAdapter());
    Hive.registerAdapter(CalculatorSessionAdapter());
    Hive.registerAdapter(InventoryItemAdapter());
    Hive.registerAdapter(InventoryUsedItemAdapter());
    Hive.registerAdapter(GameCodeAdapter());
    Hive.registerAdapter(GameCodeRewardAdapter());
    Hive.registerAdapter(TierListItemAdapter());
    Hive.registerAdapter(NotificationCustomAdapter());
    Hive.registerAdapter(NotificationExpeditionAdapter());
    Hive.registerAdapter(NotificationFarmingArtifactAdapter());
    Hive.registerAdapter(NotificationFarmingMaterialAdapter());
    Hive.registerAdapter(NotificationFurnitureAdapter());
    Hive.registerAdapter(NotificationGadgetAdapter());
    Hive.registerAdapter(NotificationRealmCurrencyAdapter());
    Hive.registerAdapter(NotificationResinAdapter());
    Hive.registerAdapter(NotificationWeeklyBossAdapter());
  }

  ItemAscensionMaterials _buildForCharacter(CalculatorItem item, {int? calculatorItemKey, bool includeInventory = false}) {
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

  ItemAscensionMaterials _buildForWeapon(CalculatorItem item, {int? calculatorItemKey, bool includeInventory = false}) {
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
              .firstWhereOrNull(
                (el) => el.calculatorItemKey == calculatorItemKey && el.itemKey == material.key && el.type == ItemType.material.index,
              )
              ?.usedQuantity ??
          0;

      final remaining = e.quantity - usedQuantity;

      return e.copyWith.call(quantity: remaining);
    }).toList();
  }

  InventoryItem? _getItemFromInventory(String key, ItemType type) {
    return _inventoryBox.values.firstWhereOrNull((el) => el.itemKey == key && el.type == type.index);
  }

  Future<void> _useItemFromInventory(int calculatorItemKey, String itemKey, ItemType type, int quantityToUse) async {
    if (!isItemInInventory(itemKey, type)) {
      return;
    }

    final used = getNumberOfItemsUsed(itemKey, type);

    final item = _getItemFromInventory(itemKey, type)!;
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

  Future<void> _clearUsedInventoryItems(int calculatorItemKey, {String? onlyItemKey, bool redistribute = false}) async {
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

  T _getNotification<T extends NotificationBase>(int key, AppNotificationType type) {
    switch (type) {
      case AppNotificationType.resin:
        return _notificationsResinBox.values.firstWhere((el) => el.key == key) as T;
      case AppNotificationType.expedition:
        return _notificationsExpeditionBox.values.firstWhere((el) => el.key == key) as T;
      case AppNotificationType.farmingMaterials:
        return _notificationsFarmingMaterialBox.values.firstWhere((el) => el.key == key) as T;
      case AppNotificationType.farmingArtifacts:
        return _notificationsFarmingArtifactBox.values.firstWhere((el) => el.key == key) as T;
      case AppNotificationType.gadget:
        return _notificationsGadgetBox.values.firstWhere((el) => el.key == key) as T;
      case AppNotificationType.furniture:
        return _notificationsFurnitureBox.values.firstWhere((el) => el.key == key) as T;
      case AppNotificationType.realmCurrency:
        return _notificationsRealmCurrencyBox.values.firstWhere((el) => el.key == key) as T;
      case AppNotificationType.weeklyBoss:
        return _notificationsWeeklyBossBox.values.firstWhere((el) => el.key == key) as T;
      case AppNotificationType.custom:
      case AppNotificationType.dailyCheckIn:
        return _notificationsCustomBox.values.firstWhere((el) => el.key == key) as T;
      default:
        throw Exception('Invalid notification type = $type');
    }
  }

  NotificationItem _mapToNotificationItem(NotificationBase e) {
    final type = AppNotificationType.values[e.type];
    switch (type) {
      case AppNotificationType.resin:
        return _mapToNotificationItemFromResin(e as NotificationResin);
      case AppNotificationType.expedition:
        return _mapToNotificationItemFromExpedition(e as NotificationExpedition);
      case AppNotificationType.farmingMaterials:
        return _mapToNotificationItemFromFarmingMaterial(e as NotificationFarmingMaterial);
      case AppNotificationType.farmingArtifacts:
        return _mapToNotificationItemFromFarmingArtifact(e as NotificationFarmingArtifact);
      case AppNotificationType.gadget:
        return _mapToNotificationItemFromGadget(e as NotificationGadget);
      case AppNotificationType.furniture:
        return _mapToNotificationItemFromFurniture(e as NotificationFurniture);
      case AppNotificationType.realmCurrency:
        return _mapToNotificationItemFromRealmCurrency(e as NotificationRealmCurrency);
      case AppNotificationType.weeklyBoss:
        return _mapToNotificationItemFromWeeklyBoss(e as NotificationWeeklyBoss);
      case AppNotificationType.custom:
      case AppNotificationType.dailyCheckIn:
        return _mapToNotificationItemFromCustom(e as NotificationCustom);
      default:
        throw Exception('Invalid notification type = $type');
    }
  }

  NotificationItem _mapToNotificationItemFromCustom(NotificationCustom e) {
    final itemType = AppNotificationItemType.values[e.notificationItemType];
    return _mapToNotificationItemFromBase(e, notificationItemType: itemType).copyWith.call(notificationItemType: itemType);
  }

  NotificationItem _mapToNotificationItemFromExpedition(NotificationExpedition e) {
    final expeditionType = ExpeditionTimeType.values[e.expeditionTimeType];
    return _mapToNotificationItemFromBase(e).copyWith.call(expeditionTimeType: expeditionType, withTimeReduction: e.withTimeReduction);
  }

  NotificationItem _mapToNotificationItemFromFarmingArtifact(NotificationFarmingArtifact e) {
    final artifactFarmingType = ArtifactFarmingTimeType.values[e.artifactFarmingTimeType];
    return _mapToNotificationItemFromBase(e).copyWith.call(artifactFarmingTimeType: artifactFarmingType);
  }

  NotificationItem _mapToNotificationItemFromFarmingMaterial(NotificationFarmingMaterial e) {
    return _mapToNotificationItemFromBase(e);
  }

  NotificationItem _mapToNotificationItemFromFurniture(NotificationFurniture e) {
    return _mapToNotificationItemFromBase(e).copyWith.call(furnitureCraftingTimeType: FurnitureCraftingTimeType.values[e.furnitureCraftingTimeType]);
  }

  NotificationItem _mapToNotificationItemFromGadget(NotificationGadget e) {
    return _mapToNotificationItemFromBase(e);
  }

  NotificationItem _mapToNotificationItemFromRealmCurrency(NotificationRealmCurrency e) {
    final realmRankType = RealmRankType.values[e.realmRankType];
    return _mapToNotificationItemFromBase(e).copyWith.call(
          realmTrustRank: e.realmTrustRank,
          realmRankType: realmRankType,
          realmCurrency: e.realmCurrency,
        );
  }

  NotificationItem _mapToNotificationItemFromResin(NotificationResin e) {
    return _mapToNotificationItemFromBase(e).copyWith.call(currentResinValue: e.currentResinValue);
  }

  NotificationItem _mapToNotificationItemFromWeeklyBoss(NotificationWeeklyBoss e) {
    return _mapToNotificationItemFromBase(e);
  }

  NotificationItem _mapToNotificationItemFromBase(NotificationBase e, {AppNotificationItemType? notificationItemType}) {
    final type = AppNotificationType.values[e.type];
    final hiveObject = e as HiveObject;
    return NotificationItem(
      key: hiveObject.key as int,
      itemKey: e.itemKey,
      image: _genshinService.getItemImageFromNotificationType(e.itemKey, type, notificationItemType: notificationItemType),
      createdAt: e.createdAt,
      completesAt: e.completesAt,
      type: type,
      showNotification: e.showNotification,
      note: e.note,
      title: e.title,
      body: e.body,
      scheduledDate: e.originalScheduledDate,
    );
  }

  Future<NotificationItem> _updateNotification(NotificationBase notification, String title, String body, String? note, bool showNotification) async {
    notification.title = title.trim();
    notification.note = note?.trim();
    notification.body = body.trim();
    notification.showNotification = showNotification;

    final hiveObject = notification as HiveObject;
    await hiveObject.save();
    return getNotification(hiveObject.key as int, AppNotificationType.values[notification.type]);
  }
}
