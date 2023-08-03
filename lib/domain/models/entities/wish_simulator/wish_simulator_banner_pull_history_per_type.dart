import 'dart:math';

import 'package:hive/hive.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'wish_simulator_banner_pull_history_per_type.g.dart';

@HiveType(typeId: 23)
class WishSimulatorBannerPullHistoryPerType extends HiveObject {
  @HiveField(0)
  final int type;

  @HiveField(1)
  int totalWishCount;

  @HiveField(2)
  Map<int, int> totalXStarCount;

  @HiveField(3)
  Map<int, int> currentXStarCount;

  @HiveField(4)
  Map<int, bool> fiftyFiftyXStarGuaranteed;

  WishSimulatorBannerPullHistoryPerType(
    this.type,
    this.totalWishCount,
    this.totalXStarCount,
    this.currentXStarCount,
    this.fiftyFiftyXStarGuaranteed,
  );

  WishSimulatorBannerPullHistoryPerType.newOne(BannerItemType type)
      : type = type.index,
        totalWishCount = 0,
        totalXStarCount = {},
        currentXStarCount = {},
        fiftyFiftyXStarGuaranteed = {};

  bool isItemGuaranteed(int rarity, int guaranteedAt) {
    if (rarity <= 0) {
      throw Exception('The provided rarity = $rarity is not valid');
    }

    if (guaranteedAt <= 0) {
      throw Exception('The provided guaranteedAt = $guaranteedAt is not valid');
    }

    int current = 0;
    if (currentXStarCount.containsKey(rarity)) {
      current = currentXStarCount[rarity]!;
    }
    return current + 1 >= guaranteedAt;
  }

  Future<void> pull(int rarity, bool? gotFeaturedItem) {
    if (rarity <= 0) {
      throw Exception('The provided rarity = $rarity is not valid');
    }

    totalWishCount++;
    currentXStarCount[rarity] = 0;

    int totalCountPerRarity = totalXStarCount[rarity] ?? 0;
    totalXStarCount[rarity] = totalCountPerRarity++;

    if (gotFeaturedItem != null) {
      //this means that we may have won the 50/50
      fiftyFiftyXStarGuaranteed[rarity] = !gotFeaturedItem;
    }

    return save();
  }

  bool shouldWinFiftyFifty(int rarity) {
    if (fiftyFiftyXStarGuaranteed[rarity] == true) {
      return true;
    }

    return Random().nextBool();
  }
}
