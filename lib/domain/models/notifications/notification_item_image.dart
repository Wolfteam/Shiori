import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_item_image.freezed.dart';

@freezed
class NotificationItemImage with _$NotificationItemImage {
  const factory NotificationItemImage({
    required String itemKey,
    required String image,
    @Default(false) bool isSelected,
  }) = _NotificationItemImage;
}
