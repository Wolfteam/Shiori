import 'package:flutter/widgets.dart';

import '../../common/enums/stat_type.dart';
import '../../common/enums/weapon_type.dart';

class WeaponCardModel {
  final String key;
  final String image;
  final String name;
  final int rarity;
  final int baseAtk;
  final WeaponType type;
  final StatType subStatType;
  final double subStatValue;

  const WeaponCardModel({
    @required this.key,
    @required this.image,
    @required this.name,
    @required this.rarity,
    @required this.baseAtk,
    @required this.type,
    @required this.subStatType,
    @required this.subStatValue,
  });
}
