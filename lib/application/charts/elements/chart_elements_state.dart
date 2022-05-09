part of 'chart_elements_bloc.dart';

@freezed
class ChartElementsState with _$ChartElementsState {
  const factory ChartElementsState.loading() = _LoadingState;

  const factory ChartElementsState.loaded({
    required int maxNumberOfColumns,
    required double firstVersion,
    required double lastVersion,
    required List<ChartElementItemModel> elements,
    required List<ChartElementItemModel> filteredElements,
    required bool canGoToFirstPage,
    required bool canGoToNextPage,
    required bool canGoToPreviousPage,
    required bool canGoToLastPage,
    @Default(<ElementType>[]) List<ElementType> selectedElementTypes,
  }) = _InitialState;
}
