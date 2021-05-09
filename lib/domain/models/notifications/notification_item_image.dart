import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_item_image.freezed.dart';

@freezed
abstract class NotificationItemImage with _$NotificationItemImage {
  const factory NotificationItemImage({
    @required String image,
    @Default(false) bool isSelected,
  }) = _NotificationItemImage;
}
