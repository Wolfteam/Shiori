import 'dart:math';

import 'package:darq/darq.dart';
import 'package:hive/hive.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'wish_simulator_banner_pull_history.g.dart';

@HiveType(typeId: 23)
class WishSimulatorBannerPullHistory extends HiveObject {
  @HiveField(0)
  final int type;

  @HiveField(1)
  Map<int, int> currentXStarCount;

  @HiveField(2)
  Map<int, bool> fiftyFiftyXStarGuaranteed;

  WishSimulatorBannerPullHistory(
    this.type,
    this.currentXStarCount,
    this.fiftyFiftyXStarGuaranteed,
  );

  WishSimulatorBannerPullHistory.newOne(BannerItemType type, Map<int, int>? defaultXStarCount)
      : type = type.index,
        currentXStarCount = defaultXStarCount ?? {},
        fiftyFiftyXStarGuaranteed = defaultXStarCount?.keys.toMap((rarity) => MapEntry(rarity, false), modifiable: true) ?? {};

  void initXStarCountIfNeeded(int rarity) {
    if (currentXStarCount.containsKey(rarity)) {
      return;
    }

    currentXStarCount[rarity] = 0;
  }

  bool isItemGuaranteed(int rarity, int guaranteedAt) {
    if (rarity <= 0) {
      throw Exception('The provided rarity = $rarity is not valid');
    }

    if (guaranteedAt <= 0) {
      throw Exception('The provided guaranteedAt = $guaranteedAt is not valid');
    }

    final int current = currentXStarCount[rarity] ?? 0;
    return current + 1 >= guaranteedAt;
  }

  Future<void> pull(int rarity, bool? gotFeaturedItem) {
    if (rarity <= 0) {
      throw Exception('The provided rarity = $rarity is not valid');
    }

    _increaseCurrentXStarCount();

    if (gotFeaturedItem != null) {
      currentXStarCount[rarity] = 0;
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

  void _increaseCurrentXStarCount() {
    for (final key in currentXStarCount.keys) {
      final int currentCount = currentXStarCount[key] ?? 0;
      currentXStarCount[key] = currentCount + 1;
    }
  }
}
