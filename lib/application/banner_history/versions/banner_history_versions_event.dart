part of 'banner_history_versions_bloc.dart';

@freezed
class BannerHistoryVersionsEvent with _$BannerHistoryVersionsEvent {
  const factory BannerHistoryVersionsEvent.init({
    @Default(BannerHistoryItemType.character) BannerHistoryItemType type,
  }) = _Init;
}
