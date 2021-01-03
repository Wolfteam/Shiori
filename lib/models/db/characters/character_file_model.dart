import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../common/assets.dart';
import '../../../common/enums/character_skill_ability_type.dart';
import '../../../common/enums/character_skill_type.dart';
import '../../../common/enums/character_type.dart';
import '../../../common/enums/element_type.dart';
import '../../../common/enums/weapon_type.dart';
import '../../models.dart';

part 'character_file_model.freezed.dart';
part 'character_file_model.g.dart';

@freezed
abstract class CharacterFileModel implements _$CharacterFileModel {
  factory CharacterFileModel({
    @required String key,
    @required int rarity,
    @required WeaponType weaponType,
    @required ElementType elementType,
    @required String image,
    @required String fullImage,
    String secondFullImage,
    @required String region,
    @required bool isFemale,
    @required bool isComingSoon,
    @required bool isNew,
    @required CharacterType role,
    @required List<CharacterFileAscentionMaterialModel> ascentionMaterials,
    @required List<CharacterFileTalentAscentionMaterialModel> talentAscentionMaterials,
    List<CharacterFileMultiTalentAscentionMaterialModel> multiTalentAscentionMaterials,
    @required List<CharacterFileBuild> builds,
    @required List<CharacterFileSkillModel> skills,
    @required List<CharacterFilePassiveModel> passives,
    @required List<CharacterFileConstellationModel> constellations,
  }) = _CharacterFileModel;

  const CharacterFileModel._();

  factory CharacterFileModel.fromJson(Map<String, dynamic> json) => _$CharacterFileModelFromJson(json);
}

@freezed
abstract class CharacterFileAscentionMaterialModel implements _$CharacterFileAscentionMaterialModel {
  factory CharacterFileAscentionMaterialModel({
    @required int rank,
    @required int level,
    @required List<ItemAscentionMaterialModel> materials,
  }) = _CharacterFileAscentionMaterialModel;

  const CharacterFileAscentionMaterialModel._();

  factory CharacterFileAscentionMaterialModel.fromJson(Map<String, dynamic> json) =>
      _$CharacterFileAscentionMaterialModelFromJson(json);
}

@freezed
abstract class CharacterFileTalentAscentionMaterialModel implements _$CharacterFileTalentAscentionMaterialModel {
  factory CharacterFileTalentAscentionMaterialModel({
    @required int level,
    @required List<ItemAscentionMaterialModel> materials,
  }) = _CharacterFileTalentAscentionMaterialModel;

  const CharacterFileTalentAscentionMaterialModel._();

  factory CharacterFileTalentAscentionMaterialModel.fromJson(Map<String, dynamic> json) =>
      _$CharacterFileTalentAscentionMaterialModelFromJson(json);
}

@freezed
abstract class CharacterFileMultiTalentAscentionMaterialModel
    implements _$CharacterFileMultiTalentAscentionMaterialModel {
  factory CharacterFileMultiTalentAscentionMaterialModel({
    @required int number,
    @required List<CharacterFileTalentAscentionMaterialModel> materials,
  }) = _CharacterFileMultiTalentAscentionMaterialModel;

  const CharacterFileMultiTalentAscentionMaterialModel._();

  factory CharacterFileMultiTalentAscentionMaterialModel.fromJson(Map<String, dynamic> json) =>
      _$CharacterFileMultiTalentAscentionMaterialModelFromJson(json);
}

@freezed
abstract class CharacterFileBuild implements _$CharacterFileBuild {
  factory CharacterFileBuild({
    @required bool isSupport,
    @required List<String> weaponImages,
    @required List<CharacterFileArtifactBuild> artifacts,
  }) = _CharacterFileBuild;

  const CharacterFileBuild._();

  factory CharacterFileBuild.fromJson(Map<String, dynamic> json) => _$CharacterFileBuildFromJson(json);
}

@freezed
abstract class CharacterFileArtifactBuild implements _$CharacterFileArtifactBuild {
  @late
  String get fullImagePath => one != null ? Assets.getArtifactPath(one) : null;

  factory CharacterFileArtifactBuild({
    String one,
    List<CharacterFileArtifactMultipleBuild> multiples,
  }) = _CharacterFileArtifactBuild;

  CharacterFileArtifactBuild._();

  factory CharacterFileArtifactBuild.fromJson(Map<String, dynamic> json) => _$CharacterFileArtifactBuildFromJson(json);
}

@freezed
abstract class CharacterFileArtifactMultipleBuild implements _$CharacterFileArtifactMultipleBuild {
  @late
  String get fullImagePath => Assets.getArtifactPath(image);

  factory CharacterFileArtifactMultipleBuild({
    @required int quantity,
    @required String image,
  }) = _CharacterFileArtifactMultipleBuild;

  CharacterFileArtifactMultipleBuild._();

  factory CharacterFileArtifactMultipleBuild.fromJson(Map<String, dynamic> json) =>
      _$CharacterFileArtifactMultipleBuildFromJson(json);
}

@freezed
abstract class CharacterFileSkillModel implements _$CharacterFileSkillModel {
  @late
  String get fullImagePath => Assets.getSkillPath(image);

  factory CharacterFileSkillModel({
    @required String key,
    @required CharacterSkillType type,
    @required String image,
    List<CharacterFileSkillAbilityModel> abilities,
  }) = _CharacterFileSkillModel;

  CharacterFileSkillModel._();

  factory CharacterFileSkillModel.fromJson(Map<String, dynamic> json) => _$CharacterFileSkillModelFromJson(json);
}

@freezed
abstract class CharacterFileSkillAbilityModel implements _$CharacterFileSkillAbilityModel {
  factory CharacterFileSkillAbilityModel({
    @required String key,
    @required CharacterSkillAbilityType type,
  }) = _CharacterFileSkillAbilityModel;

  CharacterFileSkillAbilityModel._();

  factory CharacterFileSkillAbilityModel.fromJson(Map<String, dynamic> json) =>
      _$CharacterFileSkillAbilityModelFromJson(json);
}

@freezed
abstract class CharacterFilePassiveModel implements _$CharacterFilePassiveModel {
  @late
  String get fullImagePath => Assets.getSkillPath(image);

  factory CharacterFilePassiveModel({
    @required String key,
    @required int unlockedAt,
    @required String image,
  }) = _CharacterFilePassiveModel;

  CharacterFilePassiveModel._();

  factory CharacterFilePassiveModel.fromJson(Map<String, dynamic> json) => _$CharacterFilePassiveModelFromJson(json);
}

@freezed
abstract class CharacterFileConstellationModel implements _$CharacterFileConstellationModel {
  @late
  String get fullImagePath => Assets.getSkillPath(image);

  factory CharacterFileConstellationModel({
    @required String key,
    @required int number,
    @required String image,
  }) = _CharacterFileConstellationModel;

  CharacterFileConstellationModel._();

  factory CharacterFileConstellationModel.fromJson(Map<String, dynamic> json) =>
      _$CharacterFileConstellationModelFromJson(json);
}
