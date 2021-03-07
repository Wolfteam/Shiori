import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../assets.dart';
import '../../../enums/material_type.dart';

part 'material_file_model.freezed.dart';
part 'material_file_model.g.dart';

@freezed
abstract class MaterialFileModel implements _$MaterialFileModel {
  @late
  String get fullImagePath => Assets.getMaterialPath(image, type);

  @late
  bool get isAnExperienceMaterial => type == MaterialType.expWeapon || type == MaterialType.expCharacter;

  @late
  ExperienceMaterialAttributesModel get experienceAttributes =>
      isAnExperienceMaterial ? ExperienceMaterialAttributesModel.fromJson(attributes) : null;

  factory MaterialFileModel({
    @required String key,
    @required String image,
    @required bool isFromBoss,
    @required bool isForCharacters,
    @required bool isForWeapons,
    @required MaterialType type,
    @required List<int> days,
    @required double level,
    Map<String, dynamic> attributes,
  }) = _MaterialFileModel;

  MaterialFileModel._();

  factory MaterialFileModel.fromJson(Map<String, dynamic> json) => _$MaterialFileModelFromJson(json);
}

@freezed
abstract class ExperienceMaterialAttributesModel implements _$ExperienceMaterialAttributesModel {
  factory ExperienceMaterialAttributesModel({
    @required double experience,
    @required double pricePerUsage,
  }) = _ExperienceMaterialAttributesModel;

  ExperienceMaterialAttributesModel._();

  factory ExperienceMaterialAttributesModel.fromJson(Map<String, dynamic> json) => _$ExperienceMaterialAttributesModelFromJson(json);
}
