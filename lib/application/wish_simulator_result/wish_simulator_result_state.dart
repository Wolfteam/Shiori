part of 'wish_simulator_result_bloc.dart';

@freezed
class WishSimulatorResultState with _$WishSimulatorResultState {
  const factory WishSimulatorResultState.loading() = _LoadingState;

  const factory WishSimulatorResultState.loaded({
    required List<WishBannerItemResultModel> results,
  }) = _LoadedState;
}
