part of 'banner_history_bloc.dart';

@freezed
class BannerHistoryEvent with _$BannerHistoryEvent {
  const factory BannerHistoryEvent.init() = _Init;

  const factory BannerHistoryEvent.typeChanged({
    required BannerHistoryItemType type,
  }) = _TypeChanged;

  const factory BannerHistoryEvent.sortTypeChanged({
    required BannerHistorySortType type,
  }) = _SortTypeChanged;

  const factory BannerHistoryEvent.versionSelected({
    required double version,
  }) = _VersionSelected;
}
