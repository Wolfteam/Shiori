import 'package:darq/darq.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/persistence/notifications_data_service.dart';

class NotificationsDataServiceImpl implements NotificationsDataService {
  final GenshinService _genshinService;

  late Box<NotificationCustom> _notificationsCustomBox;
  late Box<NotificationExpedition> _notificationsExpeditionBox;
  late Box<NotificationFarmingArtifact> _notificationsFarmingArtifactBox;
  late Box<NotificationFarmingMaterial> _notificationsFarmingMaterialBox;
  late Box<NotificationFurniture> _notificationsFurnitureBox;
  late Box<NotificationGadget> _notificationsGadgetBox;
  late Box<NotificationRealmCurrency> _notificationsRealmCurrencyBox;
  late Box<NotificationResin> _notificationsResinBox;
  late Box<NotificationWeeklyBoss> _notificationsWeeklyBossBox;

  NotificationsDataServiceImpl(this._genshinService);

  @override
  Future<void> init() async {
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
  Future<void> deleteThemAll() async {
    await _notificationsCustomBox.clear();
    await _notificationsExpeditionBox.clear();
    await _notificationsFarmingArtifactBox.clear();
    await _notificationsFarmingMaterialBox.clear();
    await _notificationsFurnitureBox.clear();
    await _notificationsGadgetBox.clear();
    await _notificationsRealmCurrencyBox.clear();
    await _notificationsResinBox.clear();
    await _notificationsWeeklyBossBox.clear();
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
    final gadget = _genshinService.gadgets.getGadget(itemKey);
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
    final completesAt = now.add(_genshinService.materials.getMaterial(itemKey).farmingRespawnDuration!);
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
        item.completesAt = DateTime.now().add(_genshinService.materials.getMaterial(item.itemKey).farmingRespawnDuration!);
        await item.save();
        return _mapToNotificationItem(item);
      case AppNotificationType.farmingArtifacts:
        final item = _getNotification<NotificationFarmingArtifact>(key, type);
        item.completesAt = DateTime.now().add(getArtifactFarmingCooldownDuration(ArtifactFarmingTimeType.values[item.artifactFarmingTimeType]));
        await item.save();
        return _mapToNotificationItem(item);
      case AppNotificationType.gadget:
        final item = _getNotification<NotificationGadget>(key, type);
        item.completesAt = DateTime.now().add(_genshinService.gadgets.getGadget(item.itemKey).cooldownDuration!);
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
        item.completesAt = DateTime.now().add(
          getRealmCurrencyDuration(item.realmCurrency, item.realmTrustRank, RealmRankType.values[item.realmRankType]),
        );
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
      final newDuration = _genshinService.materials.getMaterial(itemKey).farmingRespawnDuration!;
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
      final gadget = _genshinService.gadgets.getGadget(item.itemKey);
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

  Future<NotificationItem> _updateNotification(NotificationBase notification, String title, String body, String? note, bool showNotification) async {
    notification.title = title.trim();
    notification.note = note?.trim();
    notification.body = body.trim();
    notification.showNotification = showNotification;

    final hiveObject = notification as HiveObject;
    await hiveObject.save();
    return getNotification(hiveObject.key as int, AppNotificationType.values[notification.type]);
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
}
