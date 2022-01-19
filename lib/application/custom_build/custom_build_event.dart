part of 'custom_build_bloc.dart';

@freezed
class CustomBuildEvent with _$CustomBuildEvent {
  const factory CustomBuildEvent.load({int? key}) = _Init;

  const factory CustomBuildEvent.characterChanged({required String newKey}) = _CharacterChanged;

  const factory CustomBuildEvent.titleChanged({required String newValue}) = _TitleChanged;

  const factory CustomBuildEvent.roleChanged({required CharacterRoleType newValue}) = _RoleChanged;

  const factory CustomBuildEvent.subRoleChanged({required CharacterRoleSubType newValue}) = _SubRoleChanged;

  const factory CustomBuildEvent.showOnCharacterDetailChanged({required bool newValue}) = _ShowOnCharacterDetailChanged;

  const factory CustomBuildEvent.isRecommendedChanged({required bool newValue}) = _IsRecommendedChanged;

  const factory CustomBuildEvent.addSkillPriority({required CharacterSkillType type}) = _AddSkillPriority;

  const factory CustomBuildEvent.deleteSkillPriority({required int index}) = _DeleteSkillPriority;

  const factory CustomBuildEvent.addNote({required String note}) = _AddNote;

  const factory CustomBuildEvent.deleteNote({required int index}) = _DeleteNote;

  const factory CustomBuildEvent.addWeapon({required String key}) = _AddWeapon;

  const factory CustomBuildEvent.weaponRefinementChanged({
    required String key,
    required int newValue,
  }) = _WeaponRefinementChanged;

  const factory CustomBuildEvent.weaponsOrderChanged({required List<SortableItem> weapons}) = _WeaponsOrderChanged;

  const factory CustomBuildEvent.deleteWeapon({required String key}) = _DeleteWeapon;

  const factory CustomBuildEvent.deleteWeapons() = _DeleteWeapons;

  const factory CustomBuildEvent.addArtifact({
    required String key,
    required ArtifactType type,
    required StatType statType,
  }) = _AddArtifact;

  const factory CustomBuildEvent.addArtifactSubStats({
    required ArtifactType type,
    required List<StatType> subStats,
  }) = _AddArtifactSubStats;

  const factory CustomBuildEvent.deleteArtifact({required ArtifactType type}) = _DeleteArtifact;

  const factory CustomBuildEvent.deleteArtifacts() = _DeleteArtifacts;

  const factory CustomBuildEvent.addTeamCharacter({
    required String key,
    required CharacterRoleType roleType,
    required CharacterRoleSubType subType,
  }) = _AddTeamCharacter;

  const factory CustomBuildEvent.teamCharactersOrderChanged({required List<SortableItem> characters}) = _TeamCharactersOrderChanged;

  const factory CustomBuildEvent.deleteTeamCharacter({required String key}) = _DeleteTeamCharacter;

  const factory CustomBuildEvent.deleteTeamCharacters() = _DeleteTeamCharacters;

  const factory CustomBuildEvent.saveChanges() = _SaveChanges;

  //TODO: DELETE THIS?
  const factory CustomBuildEvent.reset() = _Reset;

//TODO: SHARE, SBUSTATS, TALENETS, ARTIFACT'S PIECE BONUS
}
