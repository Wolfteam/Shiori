part of 'elements_bloc.dart';

@freezed
abstract class ElementsEvent with _$ElementsEvent {
  const factory ElementsEvent.init() = _Init;
}
