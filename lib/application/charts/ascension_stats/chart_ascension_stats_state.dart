part of 'chart_ascension_stats_bloc.dart';

@freezed
sealed class ChartAscensionStatsState with _$ChartAscensionStatsState {
  const factory ChartAscensionStatsState.loading() = ChartAscensionStatsStateLoading;

  const factory ChartAscensionStatsState.loaded({
    required int currentPage,
    required int maxPage,
    required int maxNumberOfColumns,
    required bool canGoToFirstPage,
    required bool canGoToNextPage,
    required bool canGoToPreviousPage,
    required bool canGoToLastPage,
    required ItemType itemType,
    required int maxCount,
    required List<ChartAscensionStatModel> ascensionStats,
  }) = ChartAscensionStatsStateLoaded;
}
