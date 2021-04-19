import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/enums/enums.dart';

class NotificationItem {
  final int key;
  final String notificationId;
  final AppNotificationType type;
  final String image;
  final Duration remaining;
  final String createdAt;
  final String completesAt;
  final String note;
  final bool showNotification;

  final ExpeditionType expeditionType;
  final ExpeditionTimeType expeditionTimeType;
  final bool withTimeReduction;

  final int currentResinValue;

  NotificationItem.resin({
    @required this.key,
    @required this.notificationId,
    @required this.type,
    @required this.image,
    @required this.remaining,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
    @required this.showNotification,
    @required this.currentResinValue,
  })  : expeditionType = null,
        expeditionTimeType = null,
        withTimeReduction = false;

  NotificationItem.expedition({
    @required this.key,
    @required this.notificationId,
    @required this.type,
    @required this.image,
    @required this.remaining,
    @required this.createdAt,
    @required this.completesAt,
    this.note,
    @required this.showNotification,
    @required this.expeditionType,
    @required this.expeditionTimeType,
    @required this.withTimeReduction,
  }) : currentResinValue = 0;
}
