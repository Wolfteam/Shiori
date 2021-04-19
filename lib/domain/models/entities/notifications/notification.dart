import 'package:flutter/foundation.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:hive/hive.dart';

part 'notification.g.dart';

@HiveType(typeId: 8)
class Notification extends HiveObject {
  @HiveField(0)
  final String notificationId;

  @HiveField(1)
  final AppNotificationType type;

  @HiveField(2)
  final String image;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime completesAt;

  @HiveField(5)
  final bool showNotification;

  @HiveField(6)
  final String note;

  @HiveField(7)
  final ExpeditionType expeditionType;

  @HiveField(8)
  final ExpeditionTimeType expeditionTimeType;

  @HiveField(9)
  final bool withTimeReduction;

  @HiveField(10)
  final int currentResinValue;

  Notification({
    @required this.notificationId,
    @required this.type,
    @required this.image,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
    @required this.showNotification,
    @required this.currentResinValue,
    @required this.expeditionType,
    @required this.expeditionTimeType,
    @required this.withTimeReduction,
  });

  Notification.resin({
    @required this.notificationId,
    @required this.type,
    @required this.image,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
    @required this.showNotification,
    @required this.currentResinValue,
  })  : expeditionType = null,
        expeditionTimeType = null,
        withTimeReduction = false;

  Notification.expedition({
    @required this.notificationId,
    @required this.type,
    @required this.image,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
    @required this.showNotification,
    @required this.expeditionType,
    @required this.expeditionTimeType,
    @required this.withTimeReduction,
  }) : currentResinValue = 0;
}
