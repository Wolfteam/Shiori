part of 'url_page_bloc.dart';

@freezed
class UrlPageState with _$UrlPageState {
  const factory UrlPageState.loading() = _Loading;
  const factory UrlPageState.loaded({
    required String mapUrl,
    required String dailyCheckInUrl,
    required bool hasInternetConnection,
    required String userAgent,
  }) = _Loaded;
}
