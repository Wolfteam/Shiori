part of 'banner_history_item_bloc.dart';

@freezed
class BannerHistoryItemEvent with _$BannerHistoryItemEvent {
  const factory BannerHistoryItemEvent.init({
    required double version,
  }) = _Init;
}
