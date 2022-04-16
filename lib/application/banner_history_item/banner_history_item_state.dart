part of 'banner_history_item_bloc.dart';

@freezed
class BannerHistoryItemState with _$BannerHistoryItemState {
  const factory BannerHistoryItemState.loading() = _LoadingState;

  const factory BannerHistoryItemState.loadedState({
    required double version,
    required List<BannerHistoryPeriodModel> items,
  }) = _LoadedState;
}
