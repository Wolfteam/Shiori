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
  final DateTime scheduledDate;

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
  }) : scheduledDate = completesAt;

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
        scheduledDate = completesAt;

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
        scheduledDate = completesAt;

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
        scheduledDate = completesAt;
}
