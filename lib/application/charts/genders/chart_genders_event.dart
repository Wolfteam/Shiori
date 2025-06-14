part of 'chart_genders_bloc.dart';

@freezed
sealed class ChartGendersEvent with _$ChartGendersEvent {
  const factory ChartGendersEvent.init() = InitChartGendersEvent;
}
