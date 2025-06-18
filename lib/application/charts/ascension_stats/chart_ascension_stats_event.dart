part of 'chart_ascension_stats_bloc.dart';

@freezed
sealed class ChartAscensionStatsEvent with _$ChartAscensionStatsEvent {
  const factory ChartAscensionStatsEvent.init({
    required ItemType type,
    required int maxNumberOfColumns,
  }) = ChartAscensionStatsEventInit;

  const factory ChartAscensionStatsEvent.goToNextPage() = ChartAscensionStatsEventGoToNextPage;

  const factory ChartAscensionStatsEvent.goToPreviousPage() = ChartAscensionStatsEventGoToPreviousPage;

  const factory ChartAscensionStatsEvent.goToFirstPage() = ChartAscensionStatsEventGoToFirstPage;

  const factory ChartAscensionStatsEvent.goToLastPage() = ChartAscensionStatsEventGoToLastPage;
}
