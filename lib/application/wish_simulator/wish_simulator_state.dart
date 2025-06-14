part of 'wish_simulator_bloc.dart';

@freezed
sealed class WishSimulatorState with _$WishSimulatorState {
  const factory WishSimulatorState.loading() = WishSimulatorStateLoading;

  const factory WishSimulatorState.loaded({
    required String wishIconImage,
    required int selectedBannerIndex,
    required WishSimulatorBannerItemsPerPeriodModel period,
  }) = WishSimulatorStateLoaded;
}
