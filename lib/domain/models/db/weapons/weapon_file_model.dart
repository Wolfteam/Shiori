import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

part 'weapon_file_model.freezed.dart';
part 'weapon_file_model.g.dart';

@freezed
class WeaponFileModel with _$WeaponFileModel {
  factory WeaponFileModel({
    required String key,
    required String image,
    required WeaponType type,
    required double atk,
    required int rarity,
    required StatType secondaryStat,
    required double secondaryStatValue,
    required ItemLocationType location,
    required bool isComingSoon,
    required List<WeaponFileAscensionMaterial> ascensionMaterials,
    required List<WeaponFileStatModel> stats,
    @Default(<ItemAscensionMaterialFileModel>[]) List<ItemAscensionMaterialFileModel> craftingMaterials,
  }) = _WeaponFileModel;

  WeaponFileModel._();

  factory WeaponFileModel.fromJson(Map<String, dynamic> json) => _$WeaponFileModelFromJson(json);
}

@freezed
class WeaponFileAscensionMaterial with _$WeaponFileAscensionMaterial {
  factory WeaponFileAscensionMaterial({
    required int level,
    required List<ItemAscensionMaterialFileModel> materials,
  }) = _WeaponFileAscensionMaterial;

  const WeaponFileAscensionMaterial._();

  factory WeaponFileAscensionMaterial.fromJson(Map<String, dynamic> json) => _$WeaponFileAscensionMaterialFromJson(json);
}

@freezed
class WeaponFileStatModel with _$WeaponFileStatModel {
  factory WeaponFileStatModel({
    required int level,
    required double baseAtk,
    required bool isAnAscension,
    required double statValue,
  }) = _WeaponFileStatModel;

  const WeaponFileStatModel._();

  factory WeaponFileStatModel.fromJson(Map<String, dynamic> json) => _$WeaponFileStatModelFromJson(json);
}
