part of 'chart_regions_bloc.dart';

@freezed
sealed class ChartRegionsState with _$ChartRegionsState {
  const factory ChartRegionsState.loading() = ChartRegionsStateLoading;

  const factory ChartRegionsState.loaded({
    required int maxCount,
    required List<ChartCharacterRegionModel> items,
  }) = ChartRegionsStateLoaded;
}
