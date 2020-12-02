import 'package:flutter/widgets.dart';

import '../../common/enums/weapon_type.dart';

class WepaonCardModel {
  final String image;
  final String name;
  final int rarity;
  final int baseAtk;
  final WeaponType type;
  WepaonCardModel({
    @required this.image,
    @required this.name,
    @required this.rarity,
    @required this.baseAtk,
    @required this.type,
  });
}
