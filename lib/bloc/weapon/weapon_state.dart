part of 'weapon_bloc.dart';

@freezed
abstract class WeaponState with _$WeaponState {
  const factory WeaponState.loading() = _LoadingState;
  const factory WeaponState.loaded({
    @required String name,
    @required WeaponType weaponType,
    @required String fullImage,
    @required int rarity,
    @required int atk,
    @required StatType secondaryStat,
    @required double secondaryStatValue,
    @required String description,
    @required ItemLocationType locationType,
    @required List<WeaponFileAscentionMaterial> ascentionMaterials,
    @required List<WeaponFileRefinementModel> refinements,
  }) = _LoadedState;
}
