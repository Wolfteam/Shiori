part of 'home_bloc.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState.loading() = _LoadingState;
  const factory HomeState.loaded({
    @required List<TodayCharAscentionMaterialsModel> charAscMaterials,
    @required List<TodayWeaponAscentionMaterialModel> weaponAscMaterials,
  }) = _LoadedState;
}
