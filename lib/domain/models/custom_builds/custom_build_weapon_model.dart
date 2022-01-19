import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'custom_build_weapon_model.freezed.dart';

@freezed
class CustomBuildWeaponModel with _$CustomBuildWeaponModel {
  const factory CustomBuildWeaponModel({
    required String key,
    required int index,
    required int rarity,
    required int refinement,
    required double baseAtk,
    required StatType subStatType,
    required double subStatValue,
    required String name,
    required String image,
  }) = _CustomBuildWeaponModel;
}
