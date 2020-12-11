import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../common/assets.dart';
import '../../../common/enums/item_location_type.dart';
import '../../../common/enums/stat_type.dart';
import '../../../common/enums/weapon_type.dart';
import '../../models.dart';

part 'weapon_file_model.freezed.dart';
part 'weapon_file_model.g.dart';

@freezed
abstract class WeaponFileModel implements _$WeaponFileModel {
  @late
  String get fullImagePath => Assets.getWeaponPath(image, type);

  factory WeaponFileModel({
    @required String name,
    @required String image,
    @required WeaponType type,
    @required int atk,
    @required int rarity,
    @required StatType secondaryStat,
    @required double secondaryStatValue,
    @required ItemLocationType location,
    @required List<WeaponFileAscentionMaterial> ascentionMaterials,
    @required List<WeaponFileRefinement> refinements,
  }) = _WeaponFileModel;

  WeaponFileModel._();

  factory WeaponFileModel.fromJson(Map<String, dynamic> json) => _$WeaponFileModelFromJson(json);
}

@freezed
abstract class WeaponFileAscentionMaterial implements _$WeaponFileAscentionMaterial {
  factory WeaponFileAscentionMaterial({
    @required int level,
    @required List<ItemAscentionMaterialModel> materials,
  }) = _WeaponFileAscentionMaterial;

  const WeaponFileAscentionMaterial._();

  factory WeaponFileAscentionMaterial.fromJson(Map<String, dynamic> json) =>
      _$WeaponFileAscentionMaterialFromJson(json);
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
