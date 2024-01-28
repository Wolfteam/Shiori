import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_notifications_model.freezed.dart';
part 'backup_notifications_model.g.dart';

abstract class BaseBackupNotificationModel {
  int get type;

  String get itemKey;

  DateTime get completesAt;

  bool get showNotification;

  String? get note;

  String get title;

  String get body;
}

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
class BackupNotificationModel with _$BackupNotificationModel {
  @Implements<BaseBackupNotificationModel>()
  const factory BackupNotificationModel.custom({
    required String itemKey,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
    required int notificationItemType,
  }) = BackupCustomNotificationModel;

  @Implements<BaseBackupNotificationModel>()
  const factory BackupNotificationModel.expedition({
    required String itemKey,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
    required int expeditionTimeType,
    required bool withTimeReduction,
  }) = BackupExpeditionNotificationModel;

  @Implements<BaseBackupNotificationModel>()
  const factory BackupNotificationModel.farmingArtifact({
    required String itemKey,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
    required int artifactFarmingTimeType,
  }) = BackupFarmingArtifactNotificationModel;

  @Implements<BaseBackupNotificationModel>()
  const factory BackupNotificationModel.farmingMaterial({
    required String itemKey,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
  }) = BackupFarmingMaterialNotificationModel;

  @Implements<BaseBackupNotificationModel>()
  const factory BackupNotificationModel.furniture({
    required String itemKey,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
    required int furnitureCraftingTimeType,
  }) = BackupFurnitureNotificationModel;

  @Implements<BaseBackupNotificationModel>()
  const factory BackupNotificationModel.gadget({
    required String itemKey,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
  }) = BackupGadgetNotificationModel;

  @Implements<BaseBackupNotificationModel>()
  const factory BackupNotificationModel.realmCurrency({
    required String itemKey,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
    required int realmTrustRank,
    required int realmRankType,
    required int realmCurrency,
  }) = BackupRealmCurrencyNotificationModel;

  @Implements<BaseBackupNotificationModel>()
  const factory BackupNotificationModel.resin({
    required String itemKey,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
    required int currentResinValue,
  }) = BackupResinNotificationModel;

  @Implements<BaseBackupNotificationModel>()
  const factory BackupNotificationModel.weeklyBoss({
    required String itemKey,
    required DateTime completesAt,
    String? note,
    required bool showNotification,
    required String title,
    required String body,
    required int type,
  }) = BackupWeeklyBossNotificationModel;

  factory BackupNotificationModel.fromJson(Map<String, dynamic> json) => _$BackupNotificationModelFromJson(json);
}
