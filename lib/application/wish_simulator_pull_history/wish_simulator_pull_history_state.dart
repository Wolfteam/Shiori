part of 'wish_simulator_pull_history_bloc.dart';

@freezed
class WishSimulatorPullHistoryState with _$WishSimulatorPullHistoryState {
  const factory WishSimulatorPullHistoryState.loading() = _LoadingState;

  const factory WishSimulatorPullHistoryState.loaded({
    required BannerItemType bannerType,
    required List<WishSimulatorBannerItemPullHistoryModel> allItems,
    required List<WishSimulatorBannerItemPullHistoryModel> items,
    required int currentPage,
    required int maxPage,
  }) = _LoadedState;
}
