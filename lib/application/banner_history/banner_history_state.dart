part of 'banner_history_bloc.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class BannerHistoryState with _$BannerHistoryState {
  const factory BannerHistoryState.initial({
    required BannerHistoryItemType type,
    required BannerHistorySortType sortType,
    required List<BannerHistoryItemModel> banners,
    required List<double> versions,
    required int maxNumberOfItems,
    @Default(<double>[]) List<double> selectedVersions,
    @Default(<String>[]) List<String> selectedItemKeys,
  }) = _InitialState;
}
