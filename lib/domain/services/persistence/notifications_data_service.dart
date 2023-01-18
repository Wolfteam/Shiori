import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/persistence/base_data_service.dart';

abstract class NotificationsDataService implements BaseDataService {
  List<NotificationItem> getAllNotifications();

  NotificationItem getNotification(int key, AppNotificationType type);

  Future<NotificationItem> saveResinNotification(
    String itemKey,
    String title,
    String body,
    int currentResinValue, {
    String? note,
    bool showNotification = true,
  });

  Future<NotificationItem> saveExpeditionNotification(
    String itemKey,
    String title,
    String body,
    ExpeditionTimeType expeditionTimeType, {
    String? note,
    bool showNotification = true,
    bool withTimeReduction = false,
  });

  Future<NotificationItem> saveGadgetNotification(
    String itemKey,
    String title,
    String body, {
    String? note,
    bool showNotification = true,
  });

  Future<NotificationItem> saveFurnitureNotification(
    String itemKey,
    FurnitureCraftingTimeType type,
    String title,
    String body, {
    String? note,
    bool showNotification = true,
  });

  Future<NotificationItem> saveFarmingArtifactNotification(
    String itemKey,
    ArtifactFarmingTimeType type,
    String title,
    String body, {
    String? note,
    bool showNotification = true,
  });

  Future<NotificationItem> saveFarmingMaterialNotification(
    String itemKey,
    String title,
    String body, {
    String? note,
    bool showNotification = true,
  });

  Future<NotificationItem> saveRealmCurrencyNotification(
    String itemKey,
    RealmRankType realmRankType,
    int currentTrustRankLevel,
    int currentRealmCurrency,
    String title,
    String body, {
    String? note,
    bool showNotification = true,
  });

  Future<NotificationItem> saveWeeklyBossNotification(
    String itemKey,
    AppServerResetTimeType serverResetTimeType,
    String title,
    String body, {
    String? note,
    bool showNotification = true,
  });

  Future<NotificationItem> saveCustomNotification(
    String itemKey,
    String title,
    String body,
    DateTime completesAt,
    AppNotificationItemType notificationItemType, {
    String? note,
    bool showNotification = true,
  });

  Future<NotificationItem> saveDailyCheckInNotification(
    String itemKey,
    String title,
    String body, {
    String? note,
    bool showNotification = true,
  });

  Future<void> deleteNotification(int key, AppNotificationType type);

  Future<NotificationItem> resetNotification(int key, AppNotificationType type, AppServerResetTimeType serverResetTimeType);

  Future<NotificationItem> stopNotification(int key, AppNotificationType type);

  Future<NotificationItem> updateResinNotification(
    int key,
    String itemKey,
    String title,
    String body,
    int currentResinValue,
    bool showNotification, {
    String? note,
  });

  Future<NotificationItem> updateExpeditionNotification(
    int key,
    String itemKey,
    ExpeditionTimeType expeditionTimeType,
    String title,
    String body,
    bool showNotification,
    bool withTimeReduction, {
    String? note,
  });

  Future<NotificationItem> updateFurnitureNotification(
    int key,
    String itemKey,
    FurnitureCraftingTimeType type,
    String title,
    String body,
    bool showNotification, {
    String? note,
  });

  Future<NotificationItem> updateFarmingMaterialNotification(
    int key,
    String itemKey,
    String title,
    String body,
    bool showNotification, {
    String? note,
  });

  Future<NotificationItem> updateFarmingArtifactNotification(
    int key,
    String itemKey,
    ArtifactFarmingTimeType type,
    String title,
    String body,
    bool showNotification, {
    String? note,
  });

  Future<NotificationItem> updateGadgetNotification(
    int key,
    String itemKey,
    String title,
    String body,
    bool showNotification, {
    String? note,
  });

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
  });

  Future<NotificationItem> updateWeeklyBossNotification(
    int key,
    AppServerResetTimeType serverResetTimeType,
    String itemKey,
    String title,
    String body,
    bool showNotification, {
    String? note,
  });

  Future<NotificationItem> updateCustomNotification(
    int key,
    String itemKey,
    String title,
    String body,
    DateTime completesAt,
    bool showNotification,
    AppNotificationItemType notificationItemType, {
    String? note,
  });

  Future<NotificationItem> updateDailyCheckInNotification(
    int key,
    String itemKey,
    String title,
    String body,
    bool showNotification, {
    String? note,
  });

  Future<NotificationItem> reduceNotificationHours(int key, AppNotificationType type, int hours);

  BackupNotificationsModel getDataForBackup();
}
