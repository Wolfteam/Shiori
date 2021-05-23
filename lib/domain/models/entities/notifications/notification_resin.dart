import 'package:flutter/foundation.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/entities.dart';
import 'package:hive/hive.dart';

part 'notification_resin.g.dart';

@HiveType(typeId: 16)
class NotificationResin extends HiveObject implements NotificationBase {
  @override
  @HiveField(0)
  final int type;

  @override
  @HiveField(1)
  String itemKey;

  @override
  @HiveField(2)
  final DateTime createdAt;

  @override
  @HiveField(3)
  final DateTime originalScheduledDate;

  @override
  @HiveField(4)
  DateTime completesAt;

  @override
  @HiveField(5)
  bool showNotification;

  @override
  @HiveField(6)
  String note;

  @override
  @HiveField(7)
  String title;

  @override
  @HiveField(8)
  String body;

  @HiveField(9)
  int currentResinValue;

  NotificationResin({
    @required this.itemKey,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
    @required this.showNotification,
    @required this.currentResinValue,
    @required this.title,
    @required this.body,
  })  : type = AppNotificationType.resin.index,
        originalScheduledDate = completesAt;

  @override
  Future<void> updateNotification(String title, String body, String note, bool showNotification) {
    this.title = title;
    this.note = note;
    this.body = body;
    this.showNotification = showNotification;

    return save();
  }
}
