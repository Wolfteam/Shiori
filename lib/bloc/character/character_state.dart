part of 'character_bloc.dart';

@freezed
abstract class CharacterState with _$CharacterState {
  const factory CharacterState.loading() = _LoadingState;
  const factory CharacterState.loaded({
    @required String name,
    @required String fullImage,
    String secondFullImage,
    @required String description,
    @required int rarity,
    @required ElementType elementType,
    @required WeaponType weaponType,
    @required RegionType region,
    @required CharacterType role,
    @required bool isFemale,
    @required List<CharacterFileAscentionMaterialModel> ascentionMaterials,
    @required List<CharacterFileTalentAscentionMaterialModel> talentAscentionsMaterials,
    List<CharacterFileMultiTalentAscentionMaterialModel> multiTalentAscentionMaterials,
    @required List<CharacterSkillCardModel> skills,
    @required List<CharacterPassiveTalentModel> passives,
    @required List<CharacterConstellationModel> constellations,
    @required List<CharacterBuildCardModel> builds,
  }) = _LoadedState;
}
