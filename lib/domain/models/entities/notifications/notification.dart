import 'package:flutter/foundation.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:hive/hive.dart';

part 'notification.g.dart';

@HiveType(typeId: 8)
class Notification extends HiveObject {
  @HiveField(0)
  final int type;

  @HiveField(1)
  String itemKey;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime originalScheduledDate;

  @HiveField(4)
  DateTime completesAt;

  @HiveField(5)
  bool showNotification;

  @HiveField(6)
  String note;

  //Expedition specific
  @HiveField(7)
  int expeditionTimeType;

  @HiveField(8)
  bool withTimeReduction;

  //Resin specific
  @HiveField(9)
  int currentResinValue;

  //Item specific
  @HiveField(10)
  int notificationItemType;

  @HiveField(11)
  String title;

  @HiveField(12)
  String body;

  //Farming - artifact specific
  @HiveField(13)
  int artifactFarmingTimeType;

  //Furniture specific
  @HiveField(14)
  int furnitureCraftingTimeType;

  //Realm currency specific
  @HiveField(15)
  int realmTrustRank;

  @HiveField(16)
  int realmRankType;

  @HiveField(17)
  int realmCurrency;

  Notification({
    @required this.itemKey,
    @required this.type,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
    @required this.showNotification,
    @required this.currentResinValue,
    this.expeditionTimeType,
    @required this.withTimeReduction,
    this.notificationItemType,
    @required this.title,
    @required this.body,
    this.furnitureCraftingTimeType,
    this.artifactFarmingTimeType,
    this.realmTrustRank,
    this.realmRankType,
    this.realmCurrency,
  }) : originalScheduledDate = completesAt;

  Notification.resin({
    @required this.itemKey,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
    @required this.showNotification,
    @required this.currentResinValue,
    @required this.title,
    @required this.body,
  })  : type = AppNotificationType.resin.index,
        expeditionTimeType = null,
        withTimeReduction = false,
        notificationItemType = null,
        furnitureCraftingTimeType = null,
        artifactFarmingTimeType = null,
        realmTrustRank = null,
        realmRankType = null,
        realmCurrency = null,
        originalScheduledDate = completesAt;

  Notification.expedition({
    @required this.itemKey,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
    @required this.showNotification,
    @required this.expeditionTimeType,
    @required this.withTimeReduction,
    @required this.title,
    @required this.body,
  })  : type = AppNotificationType.expedition.index,
        currentResinValue = 0,
        notificationItemType = null,
        furnitureCraftingTimeType = null,
        artifactFarmingTimeType = null,
        originalScheduledDate = completesAt;

  Notification.farmingArtifact({
    @required this.itemKey,
    @required this.artifactFarmingTimeType,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
    @required this.showNotification,
    @required this.title,
    @required this.body,
  })  : type = AppNotificationType.farmingArtifacts.index,
        currentResinValue = 0,
        notificationItemType = null,
        expeditionTimeType = null,
        withTimeReduction = false,
        furnitureCraftingTimeType = null,
        realmTrustRank = null,
        realmRankType = null,
        realmCurrency = null,
        originalScheduledDate = completesAt;

  Notification.farmingMaterials({
    @required this.itemKey,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
    @required this.showNotification,
    @required this.title,
    @required this.body,
  })  : type = AppNotificationType.farmingMaterials.index,
        currentResinValue = 0,
        notificationItemType = null,
        expeditionTimeType = null,
        withTimeReduction = false,
        furnitureCraftingTimeType = null,
        artifactFarmingTimeType = null,
        realmTrustRank = null,
        realmRankType = null,
        realmCurrency = null,
        originalScheduledDate = completesAt;

  Notification.gadget({
    @required this.itemKey,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
    @required this.showNotification,
    @required this.title,
    @required this.body,
  })  : type = AppNotificationType.gadget.index,
        currentResinValue = 0,
        notificationItemType = null,
        expeditionTimeType = null,
        withTimeReduction = false,
        furnitureCraftingTimeType = null,
        artifactFarmingTimeType = null,
        realmTrustRank = null,
        realmRankType = null,
        realmCurrency = null,
        originalScheduledDate = completesAt;

  Notification.furniture({
    @required this.itemKey,
    @required this.furnitureCraftingTimeType,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
    @required this.showNotification,
    @required this.title,
    @required this.body,
  })  : type = AppNotificationType.furniture.index,
        currentResinValue = 0,
        notificationItemType = null,
        expeditionTimeType = null,
        withTimeReduction = false,
        artifactFarmingTimeType = null,
        realmTrustRank = null,
        realmRankType = null,
        realmCurrency = null,
        originalScheduledDate = completesAt;

  Notification.realmCurrency({
    @required this.itemKey,
    @required this.createdAt,
    @required this.completesAt,
    @required this.realmCurrency,
    @required this.realmRankType,
    @required this.realmTrustRank,
    this.note,
    @required this.showNotification,
    @required this.title,
    @required this.body,
  })  : type = AppNotificationType.realmCurrency.index,
        currentResinValue = 0,
        notificationItemType = null,
        expeditionTimeType = null,
        withTimeReduction = false,
        furnitureCraftingTimeType = null,
        artifactFarmingTimeType = null,
        originalScheduledDate = completesAt;

  Notification.weeklyBoss({
    @required this.itemKey,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
    @required this.showNotification,
    @required this.title,
    @required this.body,
  })  : type = AppNotificationType.weeklyBoss.index,
        currentResinValue = 0,
        notificationItemType = null,
        expeditionTimeType = null,
        withTimeReduction = false,
        furnitureCraftingTimeType = null,
        artifactFarmingTimeType = null,
        realmTrustRank = null,
        realmRankType = null,
        realmCurrency = null,
        originalScheduledDate = completesAt;

  Notification.custom({
    @required this.itemKey,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
    @required this.showNotification,
    @required this.notificationItemType,
    @required this.title,
    @required this.body,
  })  : type = AppNotificationType.custom.index,
        currentResinValue = 0,
        expeditionTimeType = null,
        withTimeReduction = false,
        artifactFarmingTimeType = null,
        originalScheduledDate = completesAt;
}
