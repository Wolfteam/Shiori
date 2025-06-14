part of 'wish_simulator_bloc.dart';

@freezed
sealed class WishSimulatorEvent with _$WishSimulatorEvent {
  const factory WishSimulatorEvent.init() = WishSimulatorEventInit;

  const factory WishSimulatorEvent.periodChanged({
    required double version,
    required DateTime from,
    required DateTime until,
  }) = WishSimulatorEventPeriodChanged;

  const factory WishSimulatorEvent.bannerSelected({required int index}) = WishSimulatorEventBannerSelected;
}
