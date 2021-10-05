part of 'materials_bloc.dart';

@freezed
class MaterialsState with _$MaterialsState {
  const factory MaterialsState.loading() = _LoadingState;

  const factory MaterialsState.loaded({
    required List<MaterialCardModel> materials,
    String? search,
    required int rarity,
    required int tempRarity,
    required MaterialFilterType filterType,
    required MaterialFilterType tempFilterType,
    MaterialType? type,
    MaterialType? tempType,
    required SortDirectionType sortDirectionType,
    required SortDirectionType tempSortDirectionType,
    @Default(<String>[]) List<String> excludeKeys,
  }) = _LoadedState;
}
