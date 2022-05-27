part of 'chart_ascension_stats_bloc.dart';

@freezed
class ChartAscensionStatsEvent with _$ChartAscensionStatsEvent {
  const factory ChartAscensionStatsEvent.init({
    required ItemType type,
    required int maxNumberOfColumns,
  }) = _Init;

  const factory ChartAscensionStatsEvent.goToNextPage() = _GoToNextPage;

  const factory ChartAscensionStatsEvent.goToPreviousPage() = _GoToPreviousPage;

  const factory ChartAscensionStatsEvent.goToFirstPage() = _GoToFirstPage;

  const factory ChartAscensionStatsEvent.goToLastPage() = _GoToLastPage;
}
