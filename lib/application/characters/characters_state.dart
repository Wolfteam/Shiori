part of 'characters_bloc.dart';

@freezed
abstract class CharactersState with _$CharactersState {
  const factory CharactersState.loading() = _LoadingState;

  const factory CharactersState.loaded({
    @required List<CharacterCardModel> characters,
    String search,
    @required bool showCharacterDetails,
    @required List<WeaponType> weaponTypes,
    @required List<WeaponType> tempWeaponTypes,
    @required List<ElementType> elementTypes,
    @required List<ElementType> tempElementTypes,
    @required int rarity,
    @required int tempRarity,
    @required ItemStatusType statusType,
    @required ItemStatusType tempStatusType,
    @required CharacterFilterType characterFilterType,
    @required CharacterFilterType tempCharacterFilterType,
    @required SortDirectionType sortDirectionType,
    @required SortDirectionType tempSortDirectionType,
    @required CharacterRoleType roleType,
    @required CharacterRoleType tempRoleType,
    @Default(<String>[]) List<String> excludeKeys,
  }) = _LoadedState;
}
