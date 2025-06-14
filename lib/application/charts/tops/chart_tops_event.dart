part of 'chart_tops_bloc.dart';

@freezed
sealed class ChartTopsEvent with _$ChartTopsEvent {
  const factory ChartTopsEvent.init() = ChartTopsEventInit;
}
