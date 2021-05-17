import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/utils/date_utils.dart' as utils;

part 'notification_item.freezed.dart';

@freezed
abstract class NotificationItem with _$NotificationItem {
  @late
  String get createdAtString => utils.DateUtils.formatDateWithoutLocale(createdAt);

  @late
  String get completesAtString => utils.DateUtils.formatDateWithoutLocale(completesAt);

  @late
  Duration get duration => scheduledDate.difference(createdAt);

  @late
  Duration get remaining => completesAt.difference(DateTime.now());

  factory NotificationItem({
    @required int key,
    @required String title,
    @required String body,
    @required String image,
    @required DateTime createdAt,
    @required DateTime scheduledDate,
    @required DateTime completesAt,
    @required AppNotificationType type,
    String note,
    @Default(true) bool showNotification,
    //Resin specific
    @Default(0) int currentResinValue,
    //Expedition specific
    ExpeditionTimeType expeditionTimeType,
    @Default(false) bool withTimeReduction,
    //Item specific
    AppNotificationItemType notificationItemType,
    //Farming Artifact specific
    ArtifactFarmingTimeType artifactFarmingTimeType,
    //Furniture specific
    FurnitureCraftingTimeType furnitureCraftingTimeType,
  }) = _NotificationItem;
}
