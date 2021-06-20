part of 'today_materials_bloc.dart';

@freezed
class TodayMaterialsState with _$TodayMaterialsState {
  const factory TodayMaterialsState.loading() = _LoadingState;
  const factory TodayMaterialsState.loaded({
    required List<TodayCharAscensionMaterialsModel> charAscMaterials,
    required List<TodayWeaponAscensionMaterialModel> weaponAscMaterials,
  }) = _LoadedState;
}
