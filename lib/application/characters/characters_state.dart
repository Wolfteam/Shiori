part of 'characters_bloc.dart';

@freezed
sealed class CharactersState with _$CharactersState {
  const factory CharactersState.loading() = CharactersStateLoading;

  const factory CharactersState.loaded({
    required List<CharacterCardModel> characters,
    String? search,
    required bool showCharacterDetails,
    required List<WeaponType> weaponTypes,
    required List<WeaponType> tempWeaponTypes,
    required List<ElementType> elementTypes,
    required List<ElementType> tempElementTypes,
    required int rarity,
    required int tempRarity,
    ItemStatusType? statusType,
    ItemStatusType? tempStatusType,
    required CharacterFilterType characterFilterType,
    required CharacterFilterType tempCharacterFilterType,
    required SortDirectionType sortDirectionType,
    required SortDirectionType tempSortDirectionType,
    CharacterRoleType? roleType,
    CharacterRoleType? tempRoleType,
    RegionType? regionType,
    RegionType? tempRegionType,
    @Default(<String>[]) List<String> excludeKeys,
  }) = CharactersStateLoaded;
}
