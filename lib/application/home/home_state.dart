part of 'home_bloc.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.loading() = _LoadingState;
  const factory HomeState.loaded({
    required List<TodayCharAscensionMaterialsModel> charAscMaterials,
    required List<TodayWeaponAscensionMaterialModel> weaponAscMaterials,
    required int day,
    required String dayName,
    @Default([]) List<ItemCommon> characterImgBirthday,
  }) = _LoadedState;
}
