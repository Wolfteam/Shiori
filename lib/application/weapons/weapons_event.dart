part of 'weapons_bloc.dart';

@freezed
abstract class WeaponsEvent with _$WeaponsEvent {
  const factory WeaponsEvent.init({
    @Default(true) bool includeInventory,
  }) = _Init;

  const factory WeaponsEvent.searchChanged({
    @required String search,
  }) = _SearchChanged;

  const factory WeaponsEvent.weaponTypeChanged(WeaponType weaponType) = _WeaponTypesChanged;

  const factory WeaponsEvent.rarityChanged(int rarity) = _RarityChanged;

  const factory WeaponsEvent.weaponFilterTypeChanged(WeaponFilterType filterType) = _WeaponFilterChanged;

  const factory WeaponsEvent.applyFilterChanges() = _ApplyFilterChanges;

  const factory WeaponsEvent.sortDirectionTypeChanged(SortDirectionType sortDirectionType) = _SortDirectionTypeChanged;

  const factory WeaponsEvent.weaponSubStatTypeChanged(StatType subStatType) = _WeaponSubStatTypeChanged;

  const factory WeaponsEvent.weaponLocationTypeChanged(ItemLocationType locationType) = _WeaponLocationTypeChanged;

  const factory WeaponsEvent.cancelChanges() = _CancelChanges;
}
