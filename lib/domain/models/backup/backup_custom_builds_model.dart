import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_custom_builds_model.freezed.dart';
part 'backup_custom_builds_model.g.dart';

@freezed
class BackupCustomBuildModel with _$BackupCustomBuildModel {
  const factory BackupCustomBuildModel({
    required String characterKey,
    required bool showOnCharacterDetail,
    required String title,
    required int roleType,
    required int roleSubType,
    required List<int> skillPriorities,
    required bool isRecommended,
    required List<BackupCustomBuildNoteModel> notes,
    required List<BackupCustomBuildWeaponModel> weapons,
    required List<BackupCustomBuildArtifactModel> artifacts,
    required List<BackupCustomBuildTeamCharacterModel> team,
  }) = _BackupCustomBuildModel;

  factory BackupCustomBuildModel.fromJson(Map<String, dynamic> json) => _$BackupCustomBuildModelFromJson(json);
}

@freezed
class BackupCustomBuildNoteModel with _$BackupCustomBuildNoteModel {
  const factory BackupCustomBuildNoteModel({
    required int index,
    required String note,
  }) = _BackupCustomBuildNoteModel;

  factory BackupCustomBuildNoteModel.fromJson(Map<String, dynamic> json) => _$BackupCustomBuildNoteModelFromJson(json);
}

@freezed
class BackupCustomBuildWeaponModel with _$BackupCustomBuildWeaponModel {
  const factory BackupCustomBuildWeaponModel({
    required String weaponKey,
    required int index,
    required int refinement,
    required int level,
    required bool isAnAscension,
  }) = _BackupCustomBuildWeaponModel;

  factory BackupCustomBuildWeaponModel.fromJson(Map<String, dynamic> json) => _$BackupCustomBuildWeaponModelFromJson(json);
}

@freezed
class BackupCustomBuildArtifactModel with _$BackupCustomBuildArtifactModel {
  const factory BackupCustomBuildArtifactModel({
    required String itemKey,
    required int type,
    required int statType,
    required List<int> subStats,
  }) = _BackupCustomBuildArtifactModel;

  factory BackupCustomBuildArtifactModel.fromJson(Map<String, dynamic> json) => _$BackupCustomBuildArtifactModelFromJson(json);
}

@freezed
class BackupCustomBuildTeamCharacterModel with _$BackupCustomBuildTeamCharacterModel {
  const factory BackupCustomBuildTeamCharacterModel({
    required int index,
    required String characterKey,
    required int roleType,
    required int subType,
  }) = _BackupCustomBuildTeamCharacterModel;

  factory BackupCustomBuildTeamCharacterModel.fromJson(Map<String, dynamic> json) => _$BackupCustomBuildTeamCharacterModelFromJson(json);
}
