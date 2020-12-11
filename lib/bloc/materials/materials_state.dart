part of 'materials_bloc.dart';

@freezed
abstract class MaterialsState with _$MaterialsState {
  const factory MaterialsState.loading() = _LoadingState;
  const factory MaterialsState.loaded({
    @required List<TodayCharAscentionMaterialsModel> charAscMaterials,
    @required List<TodayWeaponAscentionMaterialModel> weaponAscMaterials,
  }) = _LoadedState;
}
