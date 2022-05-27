part of 'chart_regions_bloc.dart';

@freezed
class ChartRegionsState with _$ChartRegionsState {
  const factory ChartRegionsState.loading() = _LoadingState;

  const factory ChartRegionsState.loaded({
    required int maxCount,
    required List<ChartCharacterRegionModel> items,
  }) = _LoadedState;
}
