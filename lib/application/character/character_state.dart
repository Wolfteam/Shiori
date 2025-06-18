part of 'character_bloc.dart';

@freezed
sealed class CharacterState with _$CharacterState {
  const factory CharacterState.loading() = CharacterStateLoading;

  const factory CharacterState.loaded({
    required String key,
    required String name,
    required String fullImage,
    String? secondFullImage,
    required String description,
    required int rarity,
    required ElementType elementType,
    required WeaponType weaponType,
    required RegionType region,
    required CharacterRoleType role,
    required bool isFemale,
    String? birthday,
    required bool isInInventory,
    required List<CharacterAscensionModel> ascensionMaterials,
    required List<CharacterTalentAscensionModel> talentAscensionsMaterials,
    @Default(<CharacterMultiTalentAscensionModel>[]) List<CharacterMultiTalentAscensionModel> multiTalentAscensionMaterials,
    required List<CharacterSkillCardModel> skills,
    required List<CharacterPassiveTalentModel> passives,
    required List<CharacterConstellationModel> constellations,
    required List<CharacterBuildCardModel> builds,
    required StatType subStatType,
    required List<CharacterFileStatModel> stats,
  }) = CharacterStateLoaded;
}
