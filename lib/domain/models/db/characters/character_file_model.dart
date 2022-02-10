import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

import '../../../assets.dart';
import '../../models.dart';

part 'character_file_model.freezed.dart';
part 'character_file_model.g.dart';

@freezed
class CharacterFileModel with _$CharacterFileModel {
  String get fullCharacterImagePath => Assets.getCharacterFullPath(image);

  String get fullImagePath => Assets.getCharacterPath(image);

  String? get fullSecondImagePath => secondFullImage != null ? Assets.getCharacterFullPath(secondFullImage!) : null;

  factory CharacterFileModel({
    required String key,
    required int rarity,
    required WeaponType weaponType,
    required ElementType elementType,
    required String image,
    required String fullImage,
    String? secondFullImage,
    required RegionType region,
    required bool isFemale,
    required bool isComingSoon,
    required bool isNew,
    required CharacterRoleType role,
    required String tier,
    String? birthday,
    required List<CharacterFileAscensionMaterialModel> ascensionMaterials,
    required List<CharacterFileTalentAscensionMaterialModel> talentAscensionMaterials,
    List<CharacterFileMultiTalentAscensionMaterialModel>? multiTalentAscensionMaterials,
    required List<CharacterFileBuild> builds,
    required List<CharacterFileSkillModel> skills,
    required List<CharacterFilePassiveModel> passives,
    required List<CharacterFileConstellationModel> constellations,
    required StatType subStatType,
    required List<CharacterFileStatModel> stats,
  }) = _CharacterFileModel;

  CharacterFileModel._();

  factory CharacterFileModel.fromJson(Map<String, dynamic> json) => _$CharacterFileModelFromJson(json);
}

@freezed
class CharacterFileAscensionMaterialModel with _$CharacterFileAscensionMaterialModel {
  factory CharacterFileAscensionMaterialModel({
    required int rank,
    required int level,
    required List<ItemAscensionMaterialFileModel> materials,
  }) = _CharacterFileAscensionMaterialModel;

  const CharacterFileAscensionMaterialModel._();

  factory CharacterFileAscensionMaterialModel.fromJson(Map<String, dynamic> json) => _$CharacterFileAscensionMaterialModelFromJson(json);
}

@freezed
class CharacterFileTalentAscensionMaterialModel with _$CharacterFileTalentAscensionMaterialModel {
  factory CharacterFileTalentAscensionMaterialModel({
    required int level,
    required List<ItemAscensionMaterialFileModel> materials,
  }) = _CharacterFileTalentAscensionMaterialModel;

  const CharacterFileTalentAscensionMaterialModel._();

  factory CharacterFileTalentAscensionMaterialModel.fromJson(Map<String, dynamic> json) => _$CharacterFileTalentAscensionMaterialModelFromJson(json);
}

@freezed
class CharacterFileMultiTalentAscensionMaterialModel with _$CharacterFileMultiTalentAscensionMaterialModel {
  factory CharacterFileMultiTalentAscensionMaterialModel({
    required int number,
    required List<CharacterFileTalentAscensionMaterialModel> materials,
  }) = _CharacterFileMultiTalentAscensionMaterialModel;

  const CharacterFileMultiTalentAscensionMaterialModel._();

  factory CharacterFileMultiTalentAscensionMaterialModel.fromJson(Map<String, dynamic> json) =>
      _$CharacterFileMultiTalentAscensionMaterialModelFromJson(json);
}

@freezed
class CharacterFileBuild with _$CharacterFileBuild {
  factory CharacterFileBuild({
    required bool isRecommended,
    required CharacterRoleType type,
    required CharacterRoleSubType subType,
    required List<CharacterSkillType> skillPriorities,
    required List<String> weaponKeys,
    required List<CharacterFileArtifactBuild> artifacts,
    required List<StatType> subStatsToFocus,
  }) = _CharacterFileBuild;

  const CharacterFileBuild._();

  factory CharacterFileBuild.fromJson(Map<String, dynamic> json) => _$CharacterFileBuildFromJson(json);
}

@freezed
class CharacterFileArtifactBuild with _$CharacterFileArtifactBuild {
  factory CharacterFileArtifactBuild({
    String? oneKey,
    required List<CharacterFileArtifactMultipleBuild> multiples,
    required List<StatType> stats,
  }) = _CharacterFileArtifactBuild;

  CharacterFileArtifactBuild._();

  factory CharacterFileArtifactBuild.fromJson(Map<String, dynamic> json) => _$CharacterFileArtifactBuildFromJson(json);
}

@freezed
class CharacterFileArtifactMultipleBuild with _$CharacterFileArtifactMultipleBuild {
  factory CharacterFileArtifactMultipleBuild({
    required String key,
    required int quantity,
  }) = _CharacterFileArtifactMultipleBuild;

  CharacterFileArtifactMultipleBuild._();

  factory CharacterFileArtifactMultipleBuild.fromJson(Map<String, dynamic> json) => _$CharacterFileArtifactMultipleBuildFromJson(json);
}

@freezed
class CharacterFileSkillModel with _$CharacterFileSkillModel {
  String get fullImagePath => Assets.getSkillPath(image);

  factory CharacterFileSkillModel({
    required String key,
    required CharacterSkillType type,
    required List<CharacterFileSkillStatModel> stats,
    String? image,
  }) = _CharacterFileSkillModel;

  CharacterFileSkillModel._();

  factory CharacterFileSkillModel.fromJson(Map<String, dynamic> json) => _$CharacterFileSkillModelFromJson(json);
}

@freezed
class CharacterFileSkillStatModel with _$CharacterFileSkillStatModel {
  factory CharacterFileSkillStatModel({
    required String key,
    required List<double> values,
  }) = _CharacterFileSkillStatModel;

  CharacterFileSkillStatModel._();

  factory CharacterFileSkillStatModel.fromJson(Map<String, dynamic> json) => _$CharacterFileSkillStatModelFromJson(json);
}

@freezed
class CharacterFilePassiveModel with _$CharacterFilePassiveModel {
  String get fullImagePath => Assets.getSkillPath(image);

  factory CharacterFilePassiveModel({
    required String key,
    required int unlockedAt,
    String? image,
  }) = _CharacterFilePassiveModel;

  CharacterFilePassiveModel._();

  factory CharacterFilePassiveModel.fromJson(Map<String, dynamic> json) => _$CharacterFilePassiveModelFromJson(json);
}

@freezed
class CharacterFileConstellationModel with _$CharacterFileConstellationModel {
  String get fullImagePath => Assets.getSkillPath(image);

  factory CharacterFileConstellationModel({
    required String key,
    required int number,
    String? image,
  }) = _CharacterFileConstellationModel;

  CharacterFileConstellationModel._();

  factory CharacterFileConstellationModel.fromJson(Map<String, dynamic> json) => _$CharacterFileConstellationModelFromJson(json);
}

@freezed
class CharacterFileStatModel with _$CharacterFileStatModel {
  factory CharacterFileStatModel({
    required int level,
    required double baseHp,
    required double baseAtk,
    required double baseDef,
    required bool isAnAscension,
    required double statValue,
  }) = _CharacterFileStatModel;

  const CharacterFileStatModel._();

  factory CharacterFileStatModel.fromJson(Map<String, dynamic> json) => _$CharacterFileStatModelFromJson(json);
}
