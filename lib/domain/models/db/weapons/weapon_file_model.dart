import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/enums/enums.dart';

import '../../../assets.dart';
import '../../../enums/item_location_type.dart';
import '../../../enums/stat_type.dart';
import '../../../enums/weapon_type.dart';
import '../../models.dart';

part 'weapon_file_model.freezed.dart';

part 'weapon_file_model.g.dart';

@freezed
abstract class WeaponFileModel implements _$WeaponFileModel {
  @late
  String get fullImagePath => Assets.getWeaponPath(image, type);

  factory WeaponFileModel({
    @required String key,
    @required String image,
    @required WeaponType type,
    @required int atk,
    @required int rarity,
    @required StatType secondaryStat,
    @required double secondaryStatValue,
    @required ItemLocationType location,
    @required bool isComingSoon,
    @required List<WeaponFileAscensionMaterial> ascensionMaterials,
    @required List<WeaponFileRefinement> refinements,
    @required List<WeaponFileStatModel> stats,
    List<WeaponCraftedFileModel> craftingMaterials,
  }) = _WeaponFileModel;

  WeaponFileModel._();

  factory WeaponFileModel.fromJson(Map<String, dynamic> json) => _$WeaponFileModelFromJson(json);
}

@freezed
abstract class WeaponFileAscensionMaterial implements _$WeaponFileAscensionMaterial {
  factory WeaponFileAscensionMaterial({
    @required int level,
    @required List<ItemAscensionMaterialModel> materials,
  }) = _WeaponFileAscensionMaterial;

  const WeaponFileAscensionMaterial._();

  factory WeaponFileAscensionMaterial.fromJson(Map<String, dynamic> json) => _$WeaponFileAscensionMaterialFromJson(json);
}

@freezed
abstract class WeaponFileRefinement implements _$WeaponFileRefinement {
  factory WeaponFileRefinement({
    @required int level,
    @required List<double> values,
  }) = _WeaponFileRefinement;

  const WeaponFileRefinement._();

  factory WeaponFileRefinement.fromJson(Map<String, dynamic> json) => _$WeaponFileRefinementFromJson(json);
}

@freezed
abstract class WeaponFileStatModel implements _$WeaponFileStatModel {
  factory WeaponFileStatModel({
    @required int level,
    @required double baseAtk,
    @required bool isAnAscension,
    @required double specificValue,
  }) = _WeaponFileStatModel;

  const WeaponFileStatModel._();

  factory WeaponFileStatModel.fromJson(Map<String, dynamic> json) => _$WeaponFileStatModelFromJson(json);
}

@freezed
abstract class WeaponCraftedFileModel implements _$WeaponCraftedFileModel {
  @late
  String get fullImagePath => Assets.getMaterialPath(image, materialType);

  factory WeaponCraftedFileModel({
    @required int quantity,
    @required MaterialType materialType,
    @required String image,
  }) = _WeaponCraftedFileModel;

  WeaponCraftedFileModel._();

  factory WeaponCraftedFileModel.fromJson(Map<String, dynamic> json) => _$WeaponCraftedFileModelFromJson(json);
}
