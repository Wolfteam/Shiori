part of 'wish_banner_history_bloc.dart';

@freezed
class WishBannerHistoryState with _$WishBannerHistoryState {
  const factory WishBannerHistoryState.loading() = _LoadingState;

  const factory WishBannerHistoryState.loaded({
    required List<WishBannerHistoryGroupedPeriodModel> allPeriods,
    required List<WishBannerHistoryGroupedPeriodModel> filteredPeriods,
    required SortDirectionType sortDirectionType,
    required WishBannerGroupedType groupedType,
    @Default(<String>[]) List<String> selectedItemKeys,
  }) = _LoadedState;
}
