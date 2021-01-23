import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../models.dart';

part 'item_ascention_materials.freezed.dart';

@freezed
abstract class ItemAscentionMaterials with _$ItemAscentionMaterials {
 const factory ItemAscentionMaterials.forCharacters({
   @required String key,
   @required String name,
   @required String image,
   @required int rarity,
   @required List<ItemAscentionMaterialModel> materials,
   @required int currentLevel,
   @required int desiredLevel,
   @required List<CharacterSkill> skills,
   @Default(true) bool isCharacter
  }) = _ForCharacter;

  const factory ItemAscentionMaterials.forWeapons({
    @required String key,
    @required String name,
    @required String image,
    @required int rarity,
    @required List<ItemAscentionMaterialModel> materials,
    @required int currentLevel,
    @required int desiredLevel,
    //This are here just for convenience
    @Default([]) List<CharacterSkill> skills,
    @Default(false) bool isCharacter
  })  = _ForWeapon;
}
