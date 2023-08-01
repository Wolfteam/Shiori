part of 'wish_simulator_result_bloc.dart';

@freezed
class WishSimulatorResultEvent with _$WishSimulatorResultEvent {
  const factory WishSimulatorResultEvent.init({
    required int index,
    required int qty,
    required WishBannerItemsPerPeriodModel period,
  }) = _Init;
}
