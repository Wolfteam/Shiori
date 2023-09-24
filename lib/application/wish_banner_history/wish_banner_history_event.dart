part of 'wish_banner_history_bloc.dart';

@freezed
class WishBannerHistoryEvent with _$WishBannerHistoryEvent {
  const factory WishBannerHistoryEvent.init() = _Init;

  const factory WishBannerHistoryEvent.groupTypeChanged(
    WishBannerGroupedType type,
  ) = _GroupTypeChanged;

  const factory WishBannerHistoryEvent.sortDirectionTypeChanged(
    SortDirectionType type,
  ) = _SortDirectionTypeChanged;

  const factory WishBannerHistoryEvent.itemsSelected({
    required List<String> keys,
  }) = _ItemsSelected;
}
