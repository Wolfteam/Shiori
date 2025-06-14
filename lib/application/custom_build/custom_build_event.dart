part of 'custom_build_bloc.dart';

@freezed
sealed class CustomBuildEvent with _$CustomBuildEvent {
  const factory CustomBuildEvent.load({
    int? key,
    required String initialTitle,
  }) = CustomBuildEventInit;

  const factory CustomBuildEvent.characterChanged({required String newKey}) = CustomBuildEventCharacterChanged;

  const factory CustomBuildEvent.titleChanged({required String newValue}) = CustomBuildEventTitleChanged;

  const factory CustomBuildEvent.roleChanged({required CharacterRoleType newValue}) = CustomBuildEventRoleChanged;

  const factory CustomBuildEvent.subRoleChanged({required CharacterRoleSubType newValue}) = CustomBuildEventSubRoleChanged;

  const factory CustomBuildEvent.showOnCharacterDetailChanged({required bool newValue}) =
      CustomBuildEventShowOnCharacterDetailChanged;

  const factory CustomBuildEvent.isRecommendedChanged({required bool newValue}) = CustomBuildEventIsRecommendedChanged;

  const factory CustomBuildEvent.addSkillPriority({required CharacterSkillType type}) = CustomBuildEventAddSkillPriority;

  const factory CustomBuildEvent.deleteSkillPriority({required int index}) = CustomBuildEventDeleteSkillPriority;

  const factory CustomBuildEvent.addNote({required String note}) = CustomBuildEventAddNote;

  const factory CustomBuildEvent.deleteNote({required int index}) = CustomBuildEventDeleteNote;

  const factory CustomBuildEvent.addWeapon({required String key}) = CustomBuildEventAddWeapon;

  const factory CustomBuildEvent.weaponRefinementChanged({
    required String key,
    required int newValue,
  }) = CustomBuildEventWeaponRefinementChanged;

  const factory CustomBuildEvent.weaponStatChanged({
    required String key,
    required WeaponFileStatModel newValue,
  }) = CustomBuildEventWeaponStatChanged;

  const factory CustomBuildEvent.weaponsOrderChanged({required List<SortableItem> weapons}) = CustomBuildEventWeaponsOrderChanged;

  const factory CustomBuildEvent.deleteWeapon({required String key}) = CustomBuildEventDeleteWeapon;

  const factory CustomBuildEvent.deleteWeapons() = CustomBuildEventDeleteWeapons;

  const factory CustomBuildEvent.addArtifact({
    required String key,
    required ArtifactType type,
    required StatType statType,
  }) = CustomBuildEventAddArtifact;

  const factory CustomBuildEvent.addArtifactSubStats({
    required ArtifactType type,
    required List<StatType> subStats,
  }) = CustomBuildEventAddArtifactSubStats;

  const factory CustomBuildEvent.deleteArtifact({required ArtifactType type}) = CustomBuildEventDeleteArtifact;

  const factory CustomBuildEvent.deleteArtifacts() = CustomBuildEventDeleteArtifacts;

  const factory CustomBuildEvent.addTeamCharacter({
    required String key,
    required CharacterRoleType roleType,
    required CharacterRoleSubType subType,
  }) = CustomBuildEventAddTeamCharacter;

  const factory CustomBuildEvent.teamCharactersOrderChanged({required List<SortableItem> characters}) =
      CustomBuildEventTeamCharactersOrderChanged;

  const factory CustomBuildEvent.deleteTeamCharacter({required String key}) = CustomBuildEventDeleteTeamCharacter;

  const factory CustomBuildEvent.deleteTeamCharacters() = CustomBuildEventDeleteTeamCharacters;

  const factory CustomBuildEvent.readyForScreenshot({required bool ready}) = CustomBuildEventReadyForScreenshot;

  const factory CustomBuildEvent.screenshotWasTaken({
    required bool succeed,
    Object? ex,
    StackTrace? trace,
  }) = CustomBuildEventScreenshotWasTaken;

  const factory CustomBuildEvent.saveChanges() = CustomBuildEventSaveChanges;
}
