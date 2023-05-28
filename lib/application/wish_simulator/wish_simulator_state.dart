part of 'wish_simulator_bloc.dart';

@freezed
class WishSimulatorState with _$WishSimulatorState {
  const factory WishSimulatorState.loading() = _LoadingState;

  const factory WishSimulatorState.loaded({
    required String wishIconImage,
    required int selectedBannerIndex,
    required WishBannerItemsPerPeriodModel period,
  }) = _LoadedState;
}
