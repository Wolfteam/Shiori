part of 'chart_tops_bloc.dart';

@freezed
sealed class ChartTopsState with _$ChartTopsState {
  const factory ChartTopsState.loading() = ChartTopsStateLoading;

  const factory ChartTopsState.loaded({
    required List<ChartTopItemModel> tops,
  }) = ChartTopsStateLoaded;
}
