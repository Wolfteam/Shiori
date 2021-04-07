part of 'url_page_bloc.dart';

@freezed
abstract class UrlPageState with _$UrlPageState {
  const factory UrlPageState.loading() = _Loading;
  const factory UrlPageState.loaded({
    @required String wishSimulatorUrl,
    @required String mapUrl,
    @required bool hasInternetConnection,
    @required String userAgent,
  }) = _Loaded;
}
