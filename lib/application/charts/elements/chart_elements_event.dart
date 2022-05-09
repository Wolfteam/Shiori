part of 'chart_elements_bloc.dart';

@freezed
class ChartElementsEvent with _$ChartElementsEvent {
  const factory ChartElementsEvent.init({
    required int maxNumberOfColumns,
  }) = _Init;

  const factory ChartElementsEvent.elementSelected({
    required ElementType type,
  }) = _ElementSelected;

  const factory ChartElementsEvent.goToNextPage() = _GoToNextPage;

  const factory ChartElementsEvent.goToPreviousPage() = _GoToPreviousPage;

  const factory ChartElementsEvent.goToFirstPage() = _GoToFirstPage;

  const factory ChartElementsEvent.goToLastPage() = _GoToLastPage;
}
