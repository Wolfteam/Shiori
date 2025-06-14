part of 'wish_banner_history_bloc.dart';

@freezed
sealed class WishBannerHistoryState with _$WishBannerHistoryState {
  const factory WishBannerHistoryState.loading() = WishBannerHistoryStateLoading;

  const factory WishBannerHistoryState.loaded({
    required List<WishBannerHistoryGroupedPeriodModel> allPeriods,
    required List<WishBannerHistoryGroupedPeriodModel> filteredPeriods,
    required SortDirectionType sortDirectionType,
    required WishBannerGroupedType groupedType,
    @Default(<String>[]) List<String> selectedItemKeys,
  }) = WishBannerHistoryStateLoaded;
}
