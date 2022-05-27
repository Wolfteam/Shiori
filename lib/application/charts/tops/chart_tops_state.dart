part of 'chart_tops_bloc.dart';

@freezed
class ChartTopsState with _$ChartTopsState {
  const factory ChartTopsState.loading() = _LoadingState;

  const factory ChartTopsState.loaded({
    required List<ChartTopItemModel> tops,
  }) = _LoadedState;
}
