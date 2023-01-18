import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_notifications_model.freezed.dart';
part 'backup_notifications_model.g.dart';

@freezed
class BackupNotificationsModel with _$BackupNotificationsModel {
  const factory BackupNotificationsModel({
    required List<BackupCustomNotificationModel> custom,
    required List<BackupExpeditionNotificationModel> expeditions,
    required List<BackupFarmingArtifactNotificationModel> farmingArtifact,
    required List<BackupFarmingMaterialNotificationModel> farmingMaterial,
    required List<BackupFurnitureNotificationModel> furniture,
    required List<BackupGadgetNotificationModel> gadgets,
    required List<BackupRealmCurrencyNotificationModel> realmCurrency,
    required List<BackupResinNotificationModel> resin,
    required List<BackupWeeklyBossNotificationModel> weeklyBosses,
  }) = _BackupNotificationsModel;

  factory BackupNotificationsModel.fromJson(Map<String, dynamic> json) => _$BackupNotificationsModelFromJson(json);
}

@freezed
class BackupCustomNotificationModel with _$BackupCustomNotificationModel {
  const factory BackupCustomNotificationModel({
    required String itemKey,
    required DateTime createdAt,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int notificationItemType,
    required int type,
    required DateTime originalScheduledDate,
  }) = _BackupCustomNotificationModel;

  factory BackupCustomNotificationModel.fromJson(Map<String, dynamic> json) => _$BackupCustomNotificationModelFromJson(json);
}

@freezed
class BackupExpeditionNotificationModel with _$BackupExpeditionNotificationModel {
  const factory BackupExpeditionNotificationModel({
    required String itemKey,
    required DateTime createdAt,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
    required DateTime originalScheduledDate,
    required int expeditionTimeType,
    required bool withTimeReduction,
  }) = _BackupExpeditionNotificationModel;

  factory BackupExpeditionNotificationModel.fromJson(Map<String, dynamic> json) => _$BackupExpeditionNotificationModelFromJson(json);
}

@freezed
class BackupFarmingArtifactNotificationModel with _$BackupFarmingArtifactNotificationModel {
  const factory BackupFarmingArtifactNotificationModel({
    required String itemKey,
    required DateTime createdAt,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
    required DateTime originalScheduledDate,
    required int artifactFarmingTimeType,
  }) = _BackupFarmingArtifactNotificationModel;

  factory BackupFarmingArtifactNotificationModel.fromJson(Map<String, dynamic> json) => _$BackupFarmingArtifactNotificationModelFromJson(json);
}

@freezed
class BackupFarmingMaterialNotificationModel with _$BackupFarmingMaterialNotificationModel {
  const factory BackupFarmingMaterialNotificationModel({
    required String itemKey,
    required DateTime createdAt,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
    required DateTime originalScheduledDate,
  }) = _BackupFarmingMaterialNotificationModel;

  factory BackupFarmingMaterialNotificationModel.fromJson(Map<String, dynamic> json) => _$BackupFarmingMaterialNotificationModelFromJson(json);
}

@freezed
class BackupFurnitureNotificationModel with _$BackupFurnitureNotificationModel {
  const factory BackupFurnitureNotificationModel({
    required String itemKey,
    required DateTime createdAt,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
    required DateTime originalScheduledDate,
    required int furnitureCraftingTimeType,
  }) = _BackupFurnitureNotificationModel;

  factory BackupFurnitureNotificationModel.fromJson(Map<String, dynamic> json) => _$BackupFurnitureNotificationModelFromJson(json);
}

@freezed
class BackupGadgetNotificationModel with _$BackupGadgetNotificationModel {
  const factory BackupGadgetNotificationModel({
    required String itemKey,
    required DateTime createdAt,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
    required DateTime originalScheduledDate,
  }) = _BackupGadgetNotificationModel;

  factory BackupGadgetNotificationModel.fromJson(Map<String, dynamic> json) => _$BackupGadgetNotificationModelFromJson(json);
}

@freezed
class BackupRealmCurrencyNotificationModel with _$BackupRealmCurrencyNotificationModel {
  const factory BackupRealmCurrencyNotificationModel({
    required String itemKey,
    required DateTime createdAt,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
    required DateTime originalScheduledDate,
    required int realmTrustRank,
    required int realmRankType,
    required int realmCurrency,
  }) = _BackupRealmCurrencyNotificationModel;

  factory BackupRealmCurrencyNotificationModel.fromJson(Map<String, dynamic> json) => _$BackupRealmCurrencyNotificationModelFromJson(json);
}

@freezed
class BackupResinNotificationModel with _$BackupResinNotificationModel {
  const factory BackupResinNotificationModel({
    required String itemKey,
    required DateTime createdAt,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
    required DateTime originalScheduledDate,
    required int currentResinValue,
  }) = _BackupResinNotificationModel;

  factory BackupResinNotificationModel.fromJson(Map<String, dynamic> json) => _$BackupResinNotificationModelFromJson(json);
}

@freezed
class BackupWeeklyBossNotificationModel with _$BackupWeeklyBossNotificationModel {
  const factory BackupWeeklyBossNotificationModel({
    required String itemKey,
    required DateTime createdAt,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
    required DateTime originalScheduledDate,
  }) = _BackupWeeklyBossNotificationModel;

  factory BackupWeeklyBossNotificationModel.fromJson(Map<String, dynamic> json) => _$BackupWeeklyBossNotificationModelFromJson(json);
}
