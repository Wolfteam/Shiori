part of 'banner_history_count_bloc.dart';

@freezed
sealed class BannerHistoryCountState with _$BannerHistoryCountState {
  const factory BannerHistoryCountState.initial({
    required BannerHistoryItemType type,
    required BannerHistorySortType sortType,
    required List<BannerHistoryItemModel> banners,
    required List<double> versions,
    required int maxNumberOfItems,
    @Default(<double>[]) List<double> selectedVersions,
    @Default(<String>[]) List<String> selectedItemKeys,
  }) = BannerHistoryCountStateInitial;
}
