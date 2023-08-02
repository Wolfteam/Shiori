import 'package:hive/hive.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'wish_simulator_banner_pull_history.g.dart';

@HiveType(typeId: 24)
class WishSimulatorBannerPullHistory extends HiveObject {
  @HiveField(0)
  final String bannerKey;

  @HiveField(1)
  final int itemType;

  @HiveField(2)
  final String itemKey;

  @HiveField(3)
  int itemCount;

  @HiveField(4)
  List<DateTime> pulledOnDates;

  WishSimulatorBannerPullHistory(this.bannerKey, this.itemType, this.itemKey, this.itemCount, this.pulledOnDates);

  WishSimulatorBannerPullHistory.newOne(this.bannerKey, ItemType itemType, this.itemKey)
      : itemCount = 1,
        itemType = itemType.index,
        pulledOnDates = [DateTime.now().toUtc()];

  factory WishSimulatorBannerPullHistory.character(String bannerKey, String itemKey) =>
      WishSimulatorBannerPullHistory.newOne(bannerKey, ItemType.character, itemKey);

  factory WishSimulatorBannerPullHistory.weapon(String bannerKey, String itemKey) =>
      WishSimulatorBannerPullHistory.newOne(bannerKey, ItemType.weapon, itemKey);
}
