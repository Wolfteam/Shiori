import 'package:hive_ce/hive.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/entities/base_entity.dart';

part 'wish_simulator_banner_item_pull_history.g.dart';

@HiveType(typeId: 24)
class WishSimulatorBannerItemPullHistory extends BaseEntity {
  @HiveField(0)
  final int bannerType;

  @HiveField(1)
  final int itemType;

  @HiveField(2)
  final String itemKey;

  @HiveField(4)
  DateTime pulledOnDate;

  WishSimulatorBannerItemPullHistory(this.bannerType, this.itemType, this.itemKey, this.pulledOnDate);

  WishSimulatorBannerItemPullHistory.newOne(BannerItemType bannerType, ItemType itemType, this.itemKey)
    : bannerType = bannerType.index,
      itemType = itemType.index,
      pulledOnDate = DateTime.now().toUtc();

  factory WishSimulatorBannerItemPullHistory.character(BannerItemType bannerType, String itemKey) =>
      WishSimulatorBannerItemPullHistory.newOne(bannerType, ItemType.character, itemKey);

  factory WishSimulatorBannerItemPullHistory.weapon(BannerItemType bannerType, String itemKey) =>
      WishSimulatorBannerItemPullHistory.newOne(bannerType, ItemType.weapon, itemKey);
}
