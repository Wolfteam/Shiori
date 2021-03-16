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
    @required List<WeaponFileAscensionMaterial> ascensionMaterials,
    @required List<WeaponFileRefinementModel> refinements,
    @required List<String> charImages,
    @required List<WeaponFileStatModel> stats,
    @required List<ItemAscensionMaterialModel> craftingMaterials,
  }) = _LoadedState;
}
