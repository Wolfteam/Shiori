part of 'custom_build_bloc.dart';

@freezed
class CustomBuildState with _$CustomBuildState {
  const factory CustomBuildState.loading() = _LoadingState;

  const factory CustomBuildState.loaded({
    int? key,
    required String title,
    required CharacterRoleType type,
    required CharacterRoleSubType subType,
    required bool showOnCharacterDetail,
    required bool isRecommended,
    required CharacterCardModel character,
    required List<WeaponCardModel> weapons,
    required List<CustomBuildArtifactModel> artifacts,
    required List<CustomBuildNoteModel> notes,
    required List<CharacterSkillType> skillPriorities,
    required List<StatType> subStatsSummary,
  }) = _LoadedState;
}
