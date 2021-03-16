import 'package:flutter/foundation.dart';
import 'package:genshindb/domain/enums/material_type.dart';

class MaterialCardModel {
  final String key;
  final String name;
  final int rarity;
  final String image;
  final MaterialType type;

  MaterialCardModel({
    @required this.key,
    @required this.name,
    @required this.rarity,
    @required this.image,
    @required this.type,
  });
}
