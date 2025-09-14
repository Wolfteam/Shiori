part of 'chart_elements_bloc.dart';

@freezed
sealed class ChartElementsEvent with _$ChartElementsEvent {
  const factory ChartElementsEvent.init({
    required int maxNumberOfColumns,
  }) = ChartElementsEventInit;

  const factory ChartElementsEvent.elementSelected({
    required ElementType type,
  }) = ChartElementsEventElementSelected;

  const factory ChartElementsEvent.goToNextPage() = ChartElementsEventGoToNextPage;

  const factory ChartElementsEvent.goToPreviousPage() = ChartElementsEventGoToPreviousPage;

  const factory ChartElementsEvent.goToFirstPage() = ChartElementsEventGoToFirstPage;

  const factory ChartElementsEvent.goToLastPage() = ChartElementsEventGoToLastPage;
}
