import 'package:flutter/foundation.dart';

import '../models.dart';

class ItemAscentionMaterials {
  final String key;
  final String name;
  final String image;
  final int rarity;
  final bool isCharacter;
  final List<ItemAscentionMaterialModel> materials;

  ItemAscentionMaterials({
    @required this.key,
    @required this.name,
    @required this.image,
    @required this.rarity,
    @required this.isCharacter,
    @required this.materials,
  });

  ItemAscentionMaterials.forCharacters({
    @required this.key,
    @required this.name,
    @required this.image,
    @required this.rarity,
    @required this.materials,
  }) : isCharacter = true;

  ItemAscentionMaterials.forWeapons({
    @required this.key,
    @required this.name,
    @required this.image,
    @required this.rarity,
    @required this.materials,
  }) : isCharacter = false;
}
