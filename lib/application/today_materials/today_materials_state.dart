part of 'today_materials_bloc.dart';

@freezed
sealed class TodayMaterialsState with _$TodayMaterialsState {
  const factory TodayMaterialsState.loading() = TodayMaterialsStateLoading;

  const factory TodayMaterialsState.loaded({
    required List<TodayCharAscensionMaterialsModel> charAscMaterials,
    required List<TodayWeaponAscensionMaterialModel> weaponAscMaterials,
  }) = TodayMaterialsStateLoaded;
}
