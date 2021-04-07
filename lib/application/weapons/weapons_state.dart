part of 'weapons_bloc.dart';

@freezed
abstract class WeaponsState with _$WeaponsState {
  const factory WeaponsState.loading() = _LoadingState;
  const factory WeaponsState.loaded({
    @required List<WeaponCardModel> weapons,
    String search,
    @required bool showWeaponDetails,
    @required List<WeaponType> weaponTypes,
    @required List<WeaponType> tempWeaponTypes,
    @required int rarity,
    @required int tempRarity,
    @required WeaponFilterType weaponFilterType,
    @required WeaponFilterType tempWeaponFilterType,
    @required SortDirectionType sortDirectionType,
    @required SortDirectionType tempSortDirectionType,
    @required StatType weaponSubStatType,
    @required StatType tempWeaponSubStatType,
    @required ItemLocationType weaponLocationType,
    @required ItemLocationType tempWeaponLocationType,
    @Default(<String>[]) List<String> excludeKeys,
  }) = _LoadedState;
}
