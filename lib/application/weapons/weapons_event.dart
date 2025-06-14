part of 'weapons_bloc.dart';

@freezed
sealed class WeaponsEvent with _$WeaponsEvent {
  const factory WeaponsEvent.init({
    @Default(false) bool force,
    @Default(<String>[]) List<String> excludeKeys,
    @Default(<WeaponType>[]) List<WeaponType> weaponTypes,
    @Default(true) bool areWeaponTypesEnabled,
  }) = WeaponsEventInit;

  const factory WeaponsEvent.searchChanged({
    required String search,
  }) = WeaponsEventSearchChanged;

  const factory WeaponsEvent.weaponTypeChanged(WeaponType weaponType) = WeaponsEventWeaponTypesChanged;

  const factory WeaponsEvent.rarityChanged(int rarity) = WeaponsEventRarityChanged;

  const factory WeaponsEvent.weaponFilterTypeChanged(WeaponFilterType filterType) = WeaponsEventWeaponFilterChanged;

  const factory WeaponsEvent.applyFilterChanges() = WeaponsEventApplyFilterChanges;

  const factory WeaponsEvent.sortDirectionTypeChanged(SortDirectionType sortDirectionType) = WeaponsEventSortDirectionTypeChanged;

  const factory WeaponsEvent.weaponSubStatTypeChanged(StatType? subStatType) = WeaponsEventWeaponSubStatTypeChanged;

  const factory WeaponsEvent.weaponLocationTypeChanged(ItemLocationType? locationType) = WeaponsEventWeaponLocationTypeChanged;

  const factory WeaponsEvent.cancelChanges() = WeaponsEventCancelChanges;

  const factory WeaponsEvent.resetFilters() = WeaponsEventResetFilters;
}
