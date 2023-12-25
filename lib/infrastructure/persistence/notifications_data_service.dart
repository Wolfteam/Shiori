import 'package:darq/darq.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/check.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/entities/base_entity.dart';
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
    Check.greaterThanOrEqualTo(key, 'key');

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
    _commonCheck(itemKey, title, body);
    Check.greaterThanOrEqualToZero(currentResinValue, 'currentResinValue');

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
    _commonCheck(itemKey, title, body);

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
    _commonCheck(itemKey, title, body);

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
    _commonCheck(itemKey, title, body);

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
    _commonCheck(itemKey, title, body);

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
    _commonCheck(itemKey, title, body);

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
    _commonCheck(itemKey, title, body);
    Check.between(currentTrustRankLevel, 'currentTrustRankLevel', realmTrustRank.keys.first, realmTrustRank.keys.last);
    Check.greaterThanOrEqualToZero(currentRealmCurrency, 'currentRealmCurrency');

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
    _commonCheck(itemKey, title, body);

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
    _commonCheck(itemKey, title, body);

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
    _commonCheck(itemKey, title, body);

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
  Future<void> deleteNotification(int key, AppNotificationType type) async {
    Check.greaterThanOrEqualToZero(key, 'key');

    await switch (type) {
      AppNotificationType.resin => _notificationsResinBox.delete(key),
      AppNotificationType.expedition => _notificationsExpeditionBox.delete(key),
      AppNotificationType.farmingMaterials => _notificationsFarmingMaterialBox.delete(key),
      AppNotificationType.farmingArtifacts => _notificationsFarmingArtifactBox.delete(key),
      AppNotificationType.gadget => _notificationsGadgetBox.delete(key),
      AppNotificationType.furniture => _notificationsFurnitureBox.delete(key),
      AppNotificationType.realmCurrency => _notificationsRealmCurrencyBox.delete(key),
      AppNotificationType.weeklyBoss => _notificationsWeeklyBossBox.delete(key),
      AppNotificationType.custom || AppNotificationType.dailyCheckIn => _notificationsCustomBox.delete(key),
    };
  }

  @override
  Future<NotificationItem> resetNotification(int key, AppNotificationType type, AppServerResetTimeType serverResetTimeType) async {
    Check.greaterThanOrEqualToZero(key, 'key');

    final now = DateTime.now();
    final notification = _getNotification(key, type);
    switch (notification) {
      case final NotificationResin item:
        item.currentResinValue = 0;
        item.completesAt = getNotificationDateForResin(item.currentResinValue);
      case final NotificationExpedition item:
        final duration = getExpeditionDuration(ExpeditionTimeType.values[item.expeditionTimeType], item.withTimeReduction);
        item.completesAt = now.add(duration);
      case final NotificationFarmingMaterial item:
        item.completesAt = now.add(_genshinService.materials.getMaterial(item.itemKey).farmingRespawnDuration!);
      case final NotificationFarmingArtifact item:
        item.completesAt = now.add(getArtifactFarmingCooldownDuration(ArtifactFarmingTimeType.values[item.artifactFarmingTimeType]));
      case final NotificationGadget item:
        item.completesAt = now.add(_genshinService.gadgets.getGadget(item.itemKey).cooldownDuration!);
      case final NotificationFurniture item:
        item.completesAt = now.add(getFurnitureDuration(FurnitureCraftingTimeType.values[item.furnitureCraftingTimeType]));
      case final NotificationRealmCurrency item:
        final duration = getRealmCurrencyDuration(item.realmCurrency, item.realmTrustRank, RealmRankType.values[item.realmRankType]);
        item.realmCurrency = 0;
        item.completesAt = now.add(duration);
      case final NotificationWeeklyBoss item:
        item.completesAt = _genshinService.getNextDateForWeeklyBoss(serverResetTimeType);
      case final NotificationCustom item:
        if (type == AppNotificationType.dailyCheckIn) {
          item.completesAt = now.add(const Duration(hours: 24));
        }
      default:
        throw ArgumentError.value(type, 'type', 'The provided app notification type is not valid for a reset');
    }

    await notification.save();
    return _mapToNotificationItem(notification);
  }

  @override
  Future<NotificationItem> stopNotification(int key, AppNotificationType type) async {
    Check.greaterThanOrEqualToZero(key, 'key');

    final item = _getNotification(key, type);
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
    String? note,
  }) async {
    Check.greaterThanOrEqualToZero(key, 'key');
    Check.notEmpty(title, 'title');
    Check.notEmpty(body, 'body');
    Check.greaterThanOrEqualToZero(currentResinValue, 'currentResinValue');

    final item = _getNotification<NotificationResin>(key, AppNotificationType.resin);
    final isCompleted = item.completesAt.isBefore(DateTime.now());
    if (currentResinValue != item.currentResinValue || isCompleted) {
      item.completesAt = getNotificationDateForResin(currentResinValue);
    }

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
  }) async {
    Check.greaterThanOrEqualToZero(key, 'key');
    _commonCheck(itemKey, title, body);

    final item = _getNotification<NotificationExpedition>(key, AppNotificationType.expedition);
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
  }) async {
    Check.greaterThanOrEqualToZero(key, 'key');
    _commonCheck(itemKey, title, body);

    final item = _getNotification<NotificationFarmingMaterial>(key, AppNotificationType.farmingMaterials);
    final isCompleted = item.completesAt.isBefore(DateTime.now());
    if (item.itemKey != itemKey || isCompleted) {
      final newDuration = _genshinService.materials.getMaterial(itemKey).farmingRespawnDuration!;
      item.completesAt = DateTime.now().add(newDuration);
    }
    item.itemKey = itemKey;
    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> updateFarmingArtifactNotification(
    int key,
    ArtifactFarmingTimeType type,
    String title,
    String body,
    bool showNotification, {
    String? note,
  }) async {
    Check.greaterThanOrEqualToZero(key, 'key');
    Check.notEmpty(title, 'title');
    Check.notEmpty(body, 'body');

    final item = _getNotification<NotificationFarmingArtifact>(key, AppNotificationType.farmingArtifacts);
    final isCompleted = item.completesAt.isBefore(DateTime.now());
    if (type.index != item.artifactFarmingTimeType || isCompleted) {
      final newDuration = getArtifactFarmingCooldownDuration(type);
      item.completesAt = DateTime.now().add(newDuration);
    }
    item.artifactFarmingTimeType = type.index;

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
  }) async {
    Check.greaterThanOrEqualToZero(key, 'key');
    _commonCheck(itemKey, title, body);

    final item = _getNotification<NotificationGadget>(key, AppNotificationType.gadget);
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
    FurnitureCraftingTimeType type,
    String title,
    String body,
    bool showNotification, {
    String? note,
  }) async {
    Check.greaterThanOrEqualToZero(key, 'key');
    Check.notEmpty(title, 'title');
    Check.notEmpty(body, 'body');

    final item = _getNotification<NotificationFurniture>(key, AppNotificationType.furniture);
    final isCompleted = item.completesAt.isBefore(DateTime.now());
    if (item.furnitureCraftingTimeType != type.index || isCompleted) {
      item.furnitureCraftingTimeType = type.index;
      item.completesAt = DateTime.now().add(getFurnitureDuration(type));
    }

    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> updateRealmCurrencyNotification(
    int key,
    RealmRankType realmRankType,
    int currentTrustRankLevel,
    int currentRealmCurrency,
    String title,
    String body,
    bool showNotification, {
    String? note,
  }) async {
    Check.greaterThanOrEqualToZero(key, 'key');
    Check.notEmpty(title, 'title');
    Check.notEmpty(body, 'body');
    Check.between(currentTrustRankLevel, 'currentTrustRankLevel', realmTrustRank.keys.first, realmTrustRank.keys.last);
    Check.greaterThanOrEqualToZero(currentRealmCurrency, 'currentRealmCurrency');

    final item = _getNotification<NotificationRealmCurrency>(key, AppNotificationType.realmCurrency);
    final isCompleted = item.completesAt.isBefore(DateTime.now());

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
  }) async {
    Check.greaterThanOrEqualToZero(key, 'key');
    _commonCheck(itemKey, title, body);

    final item = _getNotification<NotificationWeeklyBoss>(key, AppNotificationType.weeklyBoss);
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
    Check.greaterThanOrEqualToZero(key, 'key');
    _commonCheck(itemKey, title, body);

    final item = _getNotification<NotificationCustom>(key, AppNotificationType.custom);
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
    String title,
    String body,
    bool showNotification, {
    String? note,
  }) async {
    Check.greaterThanOrEqualToZero(key, 'key');
    Check.notEmpty(title, 'title');
    Check.notEmpty(body, 'body');

    final item = _getNotification<NotificationCustom>(key, AppNotificationType.dailyCheckIn);
    final isCompleted = item.completesAt.isBefore(DateTime.now());

    if (isCompleted) {
      item.completesAt = DateTime.now().add(dailyCheckInResetDuration);
    }

    return _updateNotification(item, title, body, note, showNotification);
  }

  @override
  Future<NotificationItem> reduceNotificationHours(int key, AppNotificationType type, int hours) async {
    Check.greaterThanOrEqualToZero(key, 'key');
    Check.notEmpty(hours, 'hours');
    const notSupportedTypes = [AppNotificationType.realmCurrency, AppNotificationType.resin];
    final supportedTypes = AppNotificationType.values.where((el) => !notSupportedTypes.contains(el)).toList();
    Check.inList(type, supportedTypes, 'type');

    final item = _getNotification(key, type);
    final now = DateTime.now();
    var completesAt = item.completesAt.subtract(Duration(hours: hours));

    if (completesAt.isBefore(now)) {
      completesAt = now;
    }

    item.completesAt = completesAt;
    return _updateNotification(item, item.title, item.body, item.note, item.showNotification);
  }

  @override
  BackupNotificationsModel getDataForBackup() {
    final custom = _notificationsCustomBox.values
        .map(
          (e) => BackupCustomNotificationModel(
            itemKey: e.itemKey,
            type: e.type,
            title: e.title,
            body: e.body,
            note: e.note,
            completesAt: e.completesAt,
            showNotification: e.showNotification,
            notificationItemType: e.notificationItemType,
          ),
        )
        .toList();
    final expedition = _notificationsExpeditionBox.values
        .map(
          (e) => BackupExpeditionNotificationModel(
            itemKey: e.itemKey,
            type: e.type,
            title: e.title,
            body: e.body,
            note: e.note,
            completesAt: e.completesAt,
            showNotification: e.showNotification,
            expeditionTimeType: e.expeditionTimeType,
            withTimeReduction: e.withTimeReduction,
          ),
        )
        .toList();
    final farmingArtifact = _notificationsFarmingArtifactBox.values
        .map(
          (e) => BackupFarmingArtifactNotificationModel(
            itemKey: e.itemKey,
            type: e.type,
            title: e.title,
            body: e.body,
            note: e.note,
            completesAt: e.completesAt,
            showNotification: e.showNotification,
            artifactFarmingTimeType: e.artifactFarmingTimeType,
          ),
        )
        .toList();
    final farmingMaterial = _notificationsFarmingMaterialBox.values
        .map(
          (e) => BackupFarmingMaterialNotificationModel(
            itemKey: e.itemKey,
            type: e.type,
            title: e.title,
            body: e.body,
            note: e.note,
            completesAt: e.completesAt,
            showNotification: e.showNotification,
          ),
        )
        .toList();
    final furniture = _notificationsFurnitureBox.values
        .map(
          (e) => BackupFurnitureNotificationModel(
            itemKey: e.itemKey,
            type: e.type,
            title: e.title,
            body: e.body,
            note: e.note,
            completesAt: e.completesAt,
            showNotification: e.showNotification,
            furnitureCraftingTimeType: e.furnitureCraftingTimeType,
          ),
        )
        .toList();
    final gadget = _notificationsGadgetBox.values
        .map(
          (e) => BackupGadgetNotificationModel(
            itemKey: e.itemKey,
            type: e.type,
            title: e.title,
            body: e.body,
            note: e.note,
            completesAt: e.completesAt,
            showNotification: e.showNotification,
          ),
        )
        .toList();
    final realmCurrency = _notificationsRealmCurrencyBox.values
        .map(
          (e) => BackupRealmCurrencyNotificationModel(
            itemKey: e.itemKey,
            type: e.type,
            title: e.title,
            body: e.body,
            note: e.note,
            completesAt: e.completesAt,
            showNotification: e.showNotification,
            realmCurrency: e.realmCurrency,
            realmRankType: e.realmRankType,
            realmTrustRank: e.realmTrustRank,
          ),
        )
        .toList();
    final resin = _notificationsResinBox.values
        .map(
          (e) => BackupResinNotificationModel(
            itemKey: e.itemKey,
            type: e.type,
            title: e.title,
            body: e.body,
            note: e.note,
            completesAt: e.completesAt,
            showNotification: e.showNotification,
            currentResinValue: e.currentResinValue,
          ),
        )
        .toList();
    final weeklyBoss = _notificationsWeeklyBossBox.values
        .map(
          (e) => BackupWeeklyBossNotificationModel(
            itemKey: e.itemKey,
            type: e.type,
            title: e.title,
            body: e.body,
            note: e.note,
            completesAt: e.completesAt,
            showNotification: e.showNotification,
          ),
        )
        .toList();
    return BackupNotificationsModel(
      custom: custom,
      expeditions: expedition,
      farmingArtifact: farmingArtifact,
      farmingMaterial: farmingMaterial,
      furniture: furniture,
      gadgets: gadget,
      realmCurrency: realmCurrency,
      resin: resin,
      weeklyBosses: weeklyBoss,
    );
  }

  @override
  Future<void> restoreFromBackup(BackupNotificationsModel data, AppServerResetTimeType serverResetTimeType) async {
    await deleteThemAll();
    for (final notif in data.custom) {
      final isDailyCheckIn = AppNotificationType.values[notif.type] == AppNotificationType.dailyCheckIn;
      if (isDailyCheckIn) {
        await saveDailyCheckInNotification(
          notif.itemKey,
          notif.title,
          notif.body,
          note: notif.note,
          showNotification: notif.showNotification,
        );
      } else {
        await saveCustomNotification(
          notif.itemKey,
          notif.title,
          notif.body,
          notif.completesAt,
          AppNotificationItemType.values[notif.notificationItemType],
          note: notif.note,
          showNotification: notif.showNotification,
        );
      }
    }

    for (final notif in data.expeditions) {
      await saveExpeditionNotification(
        notif.itemKey,
        notif.title,
        notif.body,
        ExpeditionTimeType.values[notif.expeditionTimeType],
        note: notif.note,
        showNotification: notif.showNotification,
        withTimeReduction: notif.withTimeReduction,
      );
    }

    for (final notif in data.farmingArtifact) {
      await saveFarmingArtifactNotification(
        notif.itemKey,
        ArtifactFarmingTimeType.values[notif.artifactFarmingTimeType],
        notif.title,
        notif.body,
        note: notif.note,
        showNotification: notif.showNotification,
      );
    }

    for (final notif in data.farmingMaterial) {
      await saveFarmingMaterialNotification(
        notif.itemKey,
        notif.title,
        notif.body,
        note: notif.note,
        showNotification: notif.showNotification,
      );
    }

    for (final notif in data.furniture) {
      await saveFurnitureNotification(
        notif.itemKey,
        FurnitureCraftingTimeType.values[notif.furnitureCraftingTimeType],
        notif.title,
        notif.body,
        note: notif.note,
        showNotification: notif.showNotification,
      );
    }

    for (final notif in data.gadgets) {
      await saveGadgetNotification(
        notif.itemKey,
        notif.title,
        notif.body,
        note: notif.note,
        showNotification: notif.showNotification,
      );
    }

    for (final notif in data.realmCurrency) {
      await saveRealmCurrencyNotification(
        notif.itemKey,
        RealmRankType.values[notif.realmRankType],
        notif.realmTrustRank,
        notif.realmCurrency,
        notif.title,
        notif.body,
        note: notif.note,
        showNotification: notif.showNotification,
      );
    }

    for (final notif in data.resin) {
      await saveResinNotification(
        notif.itemKey,
        notif.title,
        notif.body,
        notif.currentResinValue,
        note: notif.note,
        showNotification: notif.showNotification,
      );
    }

    for (final notif in data.weeklyBosses) {
      await saveWeeklyBossNotification(
        notif.itemKey,
        serverResetTimeType,
        notif.title,
        notif.body,
        note: notif.note,
        showNotification: notif.showNotification,
      );
    }
  }

  T _getNotification<T extends NotificationBase>(int key, AppNotificationType type) {
    final Iterable<BaseEntity> box = switch (type) {
      AppNotificationType.resin => _notificationsResinBox.values,
      AppNotificationType.expedition => _notificationsExpeditionBox.values,
      AppNotificationType.farmingMaterials => _notificationsFarmingMaterialBox.values,
      AppNotificationType.farmingArtifacts => _notificationsFarmingArtifactBox.values,
      AppNotificationType.gadget => _notificationsGadgetBox.values,
      AppNotificationType.furniture => _notificationsFurnitureBox.values,
      AppNotificationType.realmCurrency => _notificationsRealmCurrencyBox.values,
      AppNotificationType.weeklyBoss => _notificationsWeeklyBossBox.values,
      AppNotificationType.custom || AppNotificationType.dailyCheckIn => _notificationsCustomBox.values,
    };

    final BaseEntity? item = box.firstWhereOrDefault((el) => el.id == key);
    if (item == null) {
      throw NotFoundError(key, 'key', 'Notification does not exist');
    }

    if (item is T) {
      return item;
    }

    throw NotFoundError(key, 'key', 'Notification is not of expected type');
  }

  Future<NotificationItem> _updateNotification<T extends NotificationBase>(
    T notification,
    String title,
    String body,
    String? note,
    bool showNotification,
  ) async {
    notification.title = title.trim();
    notification.note = note?.trim();
    notification.body = body.trim();
    notification.showNotification = showNotification;

    await notification.save();
    return getNotification(notification.id, AppNotificationType.values[notification.type]);
  }

  NotificationItem _mapToNotificationItem(NotificationBase e) {
    return switch (e) {
      final NotificationResin item => _mapToNotificationItemFromResin(item),
      final NotificationExpedition item => _mapToNotificationItemFromExpedition(item),
      final NotificationFarmingMaterial item => _mapToNotificationItemFromFarmingMaterial(item),
      final NotificationFarmingArtifact item => _mapToNotificationItemFromFarmingArtifact(item),
      final NotificationGadget item => _mapToNotificationItemFromGadget(item),
      final NotificationFurniture item => _mapToNotificationItemFromFurniture(item),
      final NotificationRealmCurrency item => _mapToNotificationItemFromRealmCurrency(item),
      final NotificationWeeklyBoss item => _mapToNotificationItemFromWeeklyBoss(item),
      final NotificationCustom item => _mapToNotificationItemFromCustom(item),
      _ => throw ArgumentError.value(AppNotificationType.values[e.type], 'type', 'The provided app notification type is not valid'),
    };
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
    return NotificationItem(
      key: e.id,
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

  void _commonCheck(String itemKey, String title, String body) {
    Check.notEmpty(itemKey, 'itemKey');
    Check.notEmpty(title, 'title');
    Check.notEmpty(body, 'body');
  }
}
