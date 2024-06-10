part of 'wish_simulator_pull_history_bloc.dart';

@freezed
class WishSimulatorPullHistoryEvent with _$WishSimulatorPullHistoryEvent {
  const factory WishSimulatorPullHistoryEvent.init({required BannerItemType bannerType}) = _Init;

  const factory WishSimulatorPullHistoryEvent.pageChanged({required int page}) = _PageChanged;

  const factory WishSimulatorPullHistoryEvent.deleteData({required BannerItemType bannerType}) = _DeleteData;
}
