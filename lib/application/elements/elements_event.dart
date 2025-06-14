part of 'elements_bloc.dart';

@freezed
sealed class ElementsEvent with _$ElementsEvent {
  const factory ElementsEvent.init() = ElementsEventInit;
}
