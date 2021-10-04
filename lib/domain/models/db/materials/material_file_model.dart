import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'material_file_model.freezed.dart';
part 'material_file_model.g.dart';

@freezed
class MaterialFileModel with _$MaterialFileModel {
  String get fullImagePath => Assets.getMaterialPath(image, type);

  bool get isAnExperienceMaterial => type == MaterialType.expWeapon || type == MaterialType.expCharacter;

  ExperienceMaterialAttributesModel? get experienceAttributes =>
      isAnExperienceMaterial ? ExperienceMaterialAttributesModel.fromJson(attributes!) : null;

  Duration? get farmingRespawnDuration => farmingRespawnTime == null ? null : Duration(hours: farmingRespawnTime!);

  //TODO: MOVE THIS TO THE GENERATED CODE ?
  bool get isFromBoss =>
      type == MaterialType.elementalStone ||
      (type == MaterialType.talents && days.isEmpty) ||
      (type == MaterialType.jewels && !key.startsWith('brilliant-diamond'));

  int? get farmingRespawnTime {
    if (attributes == null || !attributes!.containsKey('farmingRespawnTime')) {
      return null;
    }
    final value = attributes!.entries.firstWhere((el) => el.key == 'farmingRespawnTime').value as int;
    return value;
  }

  bool get canBeObtainedFromAnExpedition {
    if (attributes == null || !attributes!.containsKey('canBeObtainedFromAnExpedition')) {
      return false;
    }
    final value = attributes!.entries.firstWhere((el) => el.key == 'canBeObtainedFromAnExpedition').value as bool;
    return value;
  }

  factory MaterialFileModel({
    required String key,
    required int rarity,
    required String image,
    required MaterialType type,
    required List<int> days,
    required double level,
    required bool hasSiblings,
    required List<MaterialPartOfRecipeFileModel> recipes,
    required List<MaterialPartOfRecipeFileModel> obtainedFrom,
    @Default(true) bool isReadyToBeUsed,
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
class MaterialPartOfRecipeFileModel with _$MaterialPartOfRecipeFileModel {
  factory MaterialPartOfRecipeFileModel({
    required String createsMaterialKey,
    required List<MaterialObtainedFromFileModel> needs,
  }) = _MaterialPartOfRecipeFileModel;

  MaterialPartOfRecipeFileModel._();

  factory MaterialPartOfRecipeFileModel.fromJson(Map<String, dynamic> json) => _$MaterialPartOfRecipeFileModelFromJson(json);
}

@freezed
class MaterialObtainedFromFileModel with _$MaterialObtainedFromFileModel {
  factory MaterialObtainedFromFileModel({
    required String key,
    required int quantity,
  }) = _MaterialObtainedFromFileModel;

  MaterialObtainedFromFileModel._();

  factory MaterialObtainedFromFileModel.fromJson(Map<String, dynamic> json) => _$MaterialObtainedFromFileModelFromJson(json);
}
