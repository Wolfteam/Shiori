part of 'url_page_bloc.dart';

@freezed
abstract class UrlPageEvent with _$UrlPageEvent {
  const factory UrlPageEvent.init() = _Init;
}
