part of 'custom_build_bloc.dart';

@freezed
class CustomBuildEvent with _$CustomBuildEvent {
  const factory CustomBuildEvent.load({int? key}) = _Init;

  const factory CustomBuildEvent.characterChanged({required String newKey}) = _CharacterChanged;

  const factory CustomBuildEvent.titleChanged({required String newValue}) = _TitleChanged;

  const factory CustomBuildEvent.roleChanged({required CharacterRoleType newValue}) = _RoleChanged;

  const factory CustomBuildEvent.subRoleChanged({required CharacterRoleSubType newValue}) = _SubRoleChanged;

  const factory CustomBuildEvent.showOnCharacterDetailChanged({required bool newValue}) = _ShowOnCharacterDetailChanged;

  const factory CustomBuildEvent.addWeapon({required String key}) = _AddWeapon;

  const factory CustomBuildEvent.deleteWeapon({required String key}) = _DeleteWeapon;

  const factory CustomBuildEvent.weaponOrderChanged({required String key, required int newIndex}) = _WeaponOrderChanged;

  const factory CustomBuildEvent.addArtifact({required String key, required ArtifactType type}) = _AddArtifact;

  const factory CustomBuildEvent.saveChanges() = _SaveChanges;

  const factory CustomBuildEvent.reset() = _Reset;

  //TODO: SHARE, SBUSTATS, TALENETS, ARTIFACT'S PIECE BONUS
}
