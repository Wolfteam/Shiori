part of 'banner_history_bloc.dart';

@freezed
class BannerHistoryState with _$BannerHistoryState {
  const factory BannerHistoryState.initial({
    required BannerHistoryItemType type,
    required BannerHistorySortType sortType,
    required List<BannerHistoryItemModel> banners,
    required List<double> versions,
    @Default(<double>[]) List<double> selectedVersions,
  }) = _InitialState;
}
