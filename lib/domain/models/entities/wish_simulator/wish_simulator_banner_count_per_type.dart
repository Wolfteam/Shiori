import 'package:hive/hive.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'wish_simulator_banner_count_per_type.g.dart';

@HiveType(typeId: 23)
class WishSimulatorBannerCountPerType extends HiveObject {
  @HiveField(0)
  final int type;

  @HiveField(1)
  int totalWishCount = 0;
  
  @HiveField(2)
  Map<int, int> totalXStarCount = {};

  @HiveField(3)
  Map<int, int> currentXStarCount = {};

  WishSimulatorBannerCountPerType({required BannerItemType type})
      : type = type.index;

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

  void pull(int rarity) {
    if (rarity <= 0) {
      throw Exception('The provided rarity = $rarity is not valid');
    }

    totalWishCount++;
    currentXStarCount[rarity] = 0;

    int totalCountPerRarity = totalXStarCount[rarity] ?? 0;
    totalXStarCount[rarity] = totalCountPerRarity++;
  }
}
