part of 'wish_simulator_pull_history_bloc.dart';

@freezed
sealed class WishSimulatorPullHistoryEvent with _$WishSimulatorPullHistoryEvent {
  const factory WishSimulatorPullHistoryEvent.init({required BannerItemType bannerType}) = WishSimulatorPullHistoryEventInit;

  const factory WishSimulatorPullHistoryEvent.pageChanged({required int page}) = WishSimulatorPullHistoryEventPageChanged;

  const factory WishSimulatorPullHistoryEvent.deleteData({required BannerItemType bannerType}) =
      WishSimulatorPullHistoryEventDeleteData;
}
