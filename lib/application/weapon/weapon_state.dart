part of 'weapon_bloc.dart';

@freezed
class WeaponState with _$WeaponState {
  const factory WeaponState.loading() = _LoadingState;
  const factory WeaponState.loaded({
    required String key,
    required String name,
    required WeaponType weaponType,
    required String fullImage,
    required int rarity,
    required double atk,
    required StatType secondaryStat,
    required double secondaryStatValue,
    required String description,
    required ItemLocationType locationType,
    required bool isInInventory,
    required List<WeaponAscensionModel> ascensionMaterials,
    required List<WeaponFileRefinementModel> refinements,
    required List<ItemCommonWithName> characters,
    required List<WeaponFileStatModel> stats,
    required List<ItemCommonWithQuantityAndName> craftingMaterials,
  }) = _LoadedState;
}
