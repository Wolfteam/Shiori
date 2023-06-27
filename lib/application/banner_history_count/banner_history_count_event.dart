part of 'banner_history_count_bloc.dart';

@freezed
class BannerHistoryCountEvent with _$BannerHistoryCountEvent {
  const factory BannerHistoryCountEvent.init() = _Init;

  const factory BannerHistoryCountEvent.typeChanged({
    required BannerHistoryItemType type,
  }) = _TypeChanged;

  const factory BannerHistoryCountEvent.sortTypeChanged({
    required BannerHistorySortType type,
  }) = _SortTypeChanged;

  const factory BannerHistoryCountEvent.versionSelected({
    required double version,
  }) = _VersionSelected;

  const factory BannerHistoryCountEvent.itemsSelected({
    required List<String> keys,
  }) = _CharactersSelected;
}
