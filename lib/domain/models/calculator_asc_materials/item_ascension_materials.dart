import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../models.dart';

part 'item_ascension_materials.freezed.dart';

@freezed
abstract class ItemAscensionMaterials with _$ItemAscensionMaterials {
  const factory ItemAscensionMaterials.forCharacters({
    @required String key,
    @required String name,
    @required String image,
    @required int rarity,
    @required List<ItemAscensionMaterialModel> materials,
    @required int currentLevel,
    @required int desiredLevel,
    @required int currentAscensionLevel,
    @required int desiredAscensionLevel,
    @required List<CharacterSkill> skills,
    @Default(true) bool isCharacter,
  }) = _ForCharacter;

  const factory ItemAscensionMaterials.forWeapons({
    @required String key,
    @required String name,
    @required String image,
    @required int rarity,
    @required List<ItemAscensionMaterialModel> materials,
    @required int currentLevel,
    @required int desiredLevel,
    @required int currentAscensionLevel,
    @required int desiredAscensionLevel,
    //This are here just for convenience
    @Default([]) List<CharacterSkill> skills,
    @Default(false) bool isCharacter,
  }) = _ForWeapon;
}
