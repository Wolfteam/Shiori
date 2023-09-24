part of 'wish_simulator_bloc.dart';

@freezed
class WishSimulatorEvent with _$WishSimulatorEvent {
  const factory WishSimulatorEvent.init() = _Init;

  const factory WishSimulatorEvent.periodChanged({
    required double version,
    required DateTime from,
    required DateTime until,
  }) = _PeriodChanged;

  const factory WishSimulatorEvent.bannerSelected({required int index}) = _BannerSelected;
}
