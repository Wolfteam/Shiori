part of 'characters_bloc.dart';

@freezed
sealed class CharactersEvent with _$CharactersEvent {
  const factory CharactersEvent.init({
    @Default(false) bool force,
    @Default(<String>[]) List<String> excludeKeys,
  }) = CharactersEventInit;

  const factory CharactersEvent.searchChanged({
    required String search,
  }) = CharactersEventSearchChanged;

  const factory CharactersEvent.weaponTypeChanged(WeaponType weaponType) = CharactersEventWeaponTypeChanged;

  const factory CharactersEvent.elementTypeChanged(ElementType elementType) = CharactersEventElementTypeChanged;

  const factory CharactersEvent.rarityChanged(int rarity) = CharactersEventRarityChanged;

  const factory CharactersEvent.itemStatusChanged(ItemStatusType? statusType) = CharactersEventItemStatusTypeChanged;

  const factory CharactersEvent.characterFilterTypeChanged(CharacterFilterType characterFilterType) =
      CharactersEventCharacterFilterTypeChanged;

  const factory CharactersEvent.sortDirectionTypeChanged(SortDirectionType sortDirectionType) =
      CharactersEventSortDirectionTypeChanged;

  const factory CharactersEvent.roleTypeChanged(CharacterRoleType? roleType) = CharactersEventCharacterRoleTypeChanged;

  const factory CharactersEvent.regionTypeChanged(RegionType? regionType) = CharactersEventRegionTypeChanged;

  const factory CharactersEvent.applyFilterChanges() = CharactersEventApplyFilterChanges;

  const factory CharactersEvent.cancelChanges() = CharactersEventCancelChanges;

  const factory CharactersEvent.resetFilters() = CharactersEventResetFilters;
}
