part of 'wish_banner_history_bloc.dart';

@freezed
sealed class WishBannerHistoryEvent with _$WishBannerHistoryEvent {
  const factory WishBannerHistoryEvent.init() = WishBannerHistoryEventInit;

  const factory WishBannerHistoryEvent.groupTypeChanged(
    WishBannerGroupedType type,
  ) = WishBannerHistoryEventGroupTypeChanged;

  const factory WishBannerHistoryEvent.sortDirectionTypeChanged(
    SortDirectionType type,
  ) = WishBannerHistoryEventSortDirectionTypeChanged;

  const factory WishBannerHistoryEvent.itemsSelected({
    required List<String> keys,
  }) = WishBannerHistoryEventItemsSelected;
}
