import 'package:genshindb/domain/enums/enums.dart';

import '../../enums/stat_type.dart';
import '../../enums/weapon_type.dart';

class WeaponCardModel {
  final String key;
  final String image;
  final String name;
  final int rarity;
  final int baseAtk;
  final WeaponType type;
  final StatType subStatType;
  final double subStatValue;
  final bool isComingSoon;
  final ItemLocationType locationType;

  const WeaponCardModel({
    required this.key,
    required this.image,
    required this.name,
    required this.rarity,
    required this.baseAtk,
    required this.type,
    required this.subStatType,
    required this.subStatValue,
    required this.isComingSoon,
    required this.locationType,
  });
}
