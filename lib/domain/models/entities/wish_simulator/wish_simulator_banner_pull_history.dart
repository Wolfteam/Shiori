import 'package:hive/hive.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'wish_simulator_banner_pull_history.g.dart';

@HiveType(typeId: 24)
class WishSimulatorBannerPullHistory extends HiveObject {
  @HiveField(0)
  final int bannerType;

  @HiveField(1)
  final int itemType;

  @HiveField(2)
  final String itemKey;

  @HiveField(4)
  DateTime pulledOnDate;

  WishSimulatorBannerPullHistory(this.bannerType, this.itemType, this.itemKey, this.pulledOnDate);

  WishSimulatorBannerPullHistory.newOne(BannerItemType bannerType, ItemType itemType, this.itemKey)
      : bannerType = bannerType.index,
        itemType = itemType.index,
        pulledOnDate = DateTime.now().toUtc();

  factory WishSimulatorBannerPullHistory.character(BannerItemType bannerType, String itemKey) =>
      WishSimulatorBannerPullHistory.newOne(bannerType, ItemType.character, itemKey);

  factory WishSimulatorBannerPullHistory.weapon(BannerItemType bannerType, String itemKey) =>
      WishSimulatorBannerPullHistory.newOne(bannerType, ItemType.weapon, itemKey);
}
