import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

part 'item_ascension_materials.freezed.dart';

@freezed
sealed class ItemAscensionMaterials with _$ItemAscensionMaterials {
  const factory ItemAscensionMaterials.forCharacters({
    required String key,
    required String name,
    required int position,
    required String image,
    required int rarity,
    required List<ItemAscensionMaterialModel> materials,
    required int currentLevel,
    required int desiredLevel,
    required int currentAscensionLevel,
    required int desiredAscensionLevel,
    required List<CharacterSkill> skills,
    required bool useMaterialsFromInventory,
    @Default(true) bool isCharacter,
    @Default(false) bool isWeapon,
    @Default(true) bool isActive,
    ElementType? elementType,
  }) = _ForCharacter;

  const factory ItemAscensionMaterials.forWeapons({
    required String key,
    required String name,
    required String image,
    required int position,
    required int rarity,
    required List<ItemAscensionMaterialModel> materials,
    required int currentLevel,
    required int desiredLevel,
    required int currentAscensionLevel,
    required int desiredAscensionLevel,
    required bool useMaterialsFromInventory,
    //This are here just for convenience
    @Default([]) List<CharacterSkill> skills,
    @Default(false) bool isCharacter,
    @Default(true) bool isWeapon,
    @Default(true) bool isActive,
    ElementType? elementType,
  }) = _ForWeapon;
}
