part of 'banner_history_bloc.dart';

@freezed
class BannerHistoryEvent with _$BannerHistoryEvent {
  const factory BannerHistoryEvent.init({
    @Default(BannerHistoryItemType.character) BannerHistoryItemType type,
  }) = _Init;
}
