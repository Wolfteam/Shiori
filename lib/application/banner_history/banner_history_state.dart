part of 'banner_history_bloc.dart';

@freezed
class BannerHistoryState with _$BannerHistoryState {
  const factory BannerHistoryState.initial({
    required List<BannerHistoryItemModel> banners,
    required List<double> versions,
  }) = _BannerHistoryState;
}
