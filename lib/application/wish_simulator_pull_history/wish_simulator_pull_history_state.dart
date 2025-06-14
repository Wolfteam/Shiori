part of 'wish_simulator_pull_history_bloc.dart';

@freezed
sealed class WishSimulatorPullHistoryState with _$WishSimulatorPullHistoryState {
  const factory WishSimulatorPullHistoryState.loading() = WishSimulatorPullHistoryStateLoading;

  const factory WishSimulatorPullHistoryState.loaded({
    required BannerItemType bannerType,
    required List<WishSimulatorBannerItemPullHistoryModel> allItems,
    required List<WishSimulatorBannerItemPullHistoryModel> items,
    required int currentPage,
    required int maxPage,
  }) = WishSimulatorPullHistoryStateLoaded;
}
