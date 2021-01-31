part of 'url_page_bloc.dart';

@freezed
abstract class UrlPageEvent with _$UrlPageEvent {
  const factory UrlPageEvent.init({
    @required bool loadMap,
    @required bool loadWishSimulator,
  }) = _Init;
}
