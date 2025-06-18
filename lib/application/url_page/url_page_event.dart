part of 'url_page_bloc.dart';

@freezed
sealed class UrlPageEvent with _$UrlPageEvent {
  const factory UrlPageEvent.init({
    required bool loadMap,
    required bool loadDailyCheckIn,
  }) = UrlPageEventInit;
}
