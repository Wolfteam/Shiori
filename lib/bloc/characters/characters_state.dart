part of 'characters_bloc.dart';

@freezed
abstract class CharactersState with _$CharactersState {
  const factory CharactersState.loading() = _LoadingState;
  const factory CharactersState.loaded({
    @required List<CharacterCardModel> characters,
    String search,
    @required List<WeaponType> weaponTypes,
    @required List<WeaponType> tempWeaponTypes,
    @required List<ElementType> elementTypes,
    @required List<ElementType> tempElementTypes,
    @required int rarity,
    @required int tempRarity,
    @required ReleasedUnreleasedType releasedUnreleasedType,
    @required ReleasedUnreleasedType tempReleasedUnreleasedType,
    @required CharacterFilterType characterFilterType,
    @required CharacterFilterType tempCharacterFilterType,
    @required SortDirectionType sortDirectionType,
    @required SortDirectionType tempSortDirectionType,
  }) = _LoadedState;
}
