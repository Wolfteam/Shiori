part of 'chart_regions_bloc.dart';

@freezed
sealed class ChartRegionsEvent with _$ChartRegionsEvent {
  const factory ChartRegionsEvent.init() = ChartRegionsEventInit;
}
