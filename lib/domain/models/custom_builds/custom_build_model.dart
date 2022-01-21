import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

part 'custom_build_model.freezed.dart';

@freezed
class CustomBuildModel with _$CustomBuildModel {
  const factory CustomBuildModel({
    required int key,
    required String title,
    required CharacterRoleType type,
    required CharacterRoleSubType subType,
    required bool showOnCharacterDetail,
    required bool isRecommended,
    required CharacterCardModel character,
    required List<CustomBuildWeaponModel> weapons,
    required List<CustomBuildArtifactModel> artifacts,
    required List<CustomBuildTeamCharacterModel> teamCharacters,
    required List<CustomBuildNoteModel> notes,
    required List<CharacterSkillType> skillPriorities,
    required List<StatType> subStatsSummary,
  }) = _CustomBuildModel;
}
