part of 'wish_simulator_result_bloc.dart';

@freezed
sealed class WishSimulatorResultState with _$WishSimulatorResultState {
  const factory WishSimulatorResultState.loading() = WishSimulatorResultStateLoading;

  const factory WishSimulatorResultState.loaded({
    required List<WishSimulatorBannerItemResultModel> results,
  }) = WishSimulatorResultStateLoaded;
}
