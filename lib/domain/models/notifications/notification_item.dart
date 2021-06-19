import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/enums/enums.dart';

part 'notification_item.freezed.dart';

@freezed
class NotificationItem with _$NotificationItem {
  Duration get duration => scheduledDate.difference(createdAt);

  Duration get remaining => completesAt.difference(DateTime.now());

  factory NotificationItem({
    required int key,
    required String itemKey,
    required String title,
    required String body,
    required String image,
    required DateTime createdAt,
    required DateTime scheduledDate,
    required DateTime completesAt,
    required AppNotificationType type,
    String? note,
    @Default(true) bool showNotification,
    //Resin specific
    @Default(0) int currentResinValue,
    //Expedition specific
    ExpeditionTimeType? expeditionTimeType,
    @Default(false) bool withTimeReduction,
    //Item specific
    AppNotificationItemType? notificationItemType,
    //Farming Artifact specific
    ArtifactFarmingTimeType? artifactFarmingTimeType,
    //Furniture specific
    FurnitureCraftingTimeType? furnitureCraftingTimeType,
    //Realm Currency specific
    int? realmTrustRank,
    RealmRankType? realmRankType,
    int? realmCurrency,
  }) = _NotificationItem;

  NotificationItem._();
}
