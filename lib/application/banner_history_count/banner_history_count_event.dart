part of 'banner_history_count_bloc.dart';

@freezed
sealed class BannerHistoryCountEvent with _$BannerHistoryCountEvent {
  const factory BannerHistoryCountEvent.init() = BannerHistoryCountEventInit;

  const factory BannerHistoryCountEvent.typeChanged({
    required BannerHistoryItemType type,
  }) = BannerHistoryCountEventTypeChanged;

  const factory BannerHistoryCountEvent.sortTypeChanged({
    required BannerHistorySortType type,
  }) = BannerHistoryCountEventSortTypeChanged;

  const factory BannerHistoryCountEvent.versionSelected({
    required double version,
  }) = BannerHistoryCountEventVersionSelected;

  const factory BannerHistoryCountEvent.itemsSelected({
    required List<String> keys,
  }) = BannerHistoryCountEventCharactersSelected;
}
