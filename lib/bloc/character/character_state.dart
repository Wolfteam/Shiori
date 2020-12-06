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
    @required String region,
    @required String role,
    @required bool isFemale,
    @required List<CharacterFileAscentionMaterialModel> ascentionMaterials,
    @required List<CharacterFileTalentAscentionMaterialModel> talentAscentionsMaterials,
    List<CharacterFileMultiTalentAscentionMaterialModel> multiTalentAscentionMaterials,
    @required List<TranslationCharacterSkillFile> skills,
    @required List<TranslationCharacterPassive> passives,
    @required List<TranslationCharacterConstellation> constellations,
  }) = _LoadedState;
}
