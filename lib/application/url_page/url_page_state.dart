part of 'url_page_bloc.dart';

@freezed
sealed class UrlPageState with _$UrlPageState {
  const factory UrlPageState.loading() = UrlPageStateLoading;

  const factory UrlPageState.loaded({
    required String mapUrl,
    required String dailyCheckInUrl,
    required bool hasInternetConnection,
    required String userAgent,
  }) = UrlPageStateLoaded;
}
