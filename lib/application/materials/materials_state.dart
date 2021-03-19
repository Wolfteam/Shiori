part of 'materials_bloc.dart';

@freezed
abstract class MaterialsState implements _$MaterialsState {
  const factory MaterialsState.loading() = _LoadingState;

  const factory MaterialsState.loaded({
    @required List<MaterialCardModel> materials,
    String search,
    @required int rarity,
    @required int tempRarity,
    @required MaterialFilterType filterType,
    @required MaterialFilterType tempFilterType,
    @required MaterialType type,
    @required MaterialType tempType,
    @required SortDirectionType sortDirectionType,
    @required SortDirectionType tempSortDirectionType,
  }) = _LoadedState;
}
