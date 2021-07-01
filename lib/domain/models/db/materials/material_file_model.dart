import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';

part 'material_file_model.freezed.dart';
part 'material_file_model.g.dart';

@freezed
class MaterialFileModel with _$MaterialFileModel {
  String get fullImagePath => Assets.getMaterialPath(image, type);

  bool get isAnExperienceMaterial => type == MaterialType.expWeapon || type == MaterialType.expCharacter;

  ExperienceMaterialAttributesModel? get experienceAttributes =>
      isAnExperienceMaterial ? ExperienceMaterialAttributesModel.fromJson(attributes!) : null;

  Duration? get farmingRespawnDuration => farmingRespawnTime == null ? null : Duration(hours: farmingRespawnTime!);

  factory MaterialFileModel({
    required String key,
    required int rarity,
    required String image,
    required bool isFromBoss,
    required bool isForCharacters,
    required bool isForWeapons,
    required MaterialType type,
    required List<int> days,
    required double level,
    required List<ObtainedFromFileModel> obtainedFrom,
    required bool hasSiblings,
    @Default(true) bool isReadyToBeUsed,
    @Default(false) bool canBeObtainedFromAnExpedition,
    int? farmingRespawnTime,
    Map<String, dynamic>? attributes,
  }) = _MaterialFileModel;

  MaterialFileModel._();

  factory MaterialFileModel.fromJson(Map<String, dynamic> json) => _$MaterialFileModelFromJson(json);
}

@freezed
class ExperienceMaterialAttributesModel with _$ExperienceMaterialAttributesModel {
  factory ExperienceMaterialAttributesModel({
    required double experience,
    required double pricePerUsage,
  }) = _ExperienceMaterialAttributesModel;

  ExperienceMaterialAttributesModel._();

  factory ExperienceMaterialAttributesModel.fromJson(Map<String, dynamic> json) => _$ExperienceMaterialAttributesModelFromJson(json);
}

@freezed
class ObtainedFromFileModel with _$ObtainedFromFileModel {
  factory ObtainedFromFileModel({
    required List<ItemAscensionMaterialModel> items,
  }) = _ObtainedFromFileModel;

  ObtainedFromFileModel._();

  factory ObtainedFromFileModel.fromJson(Map<String, dynamic> json) => _$ObtainedFromFileModelFromJson(json);
}
