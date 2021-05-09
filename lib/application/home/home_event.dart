part of 'home_bloc.dart';

@freezed
abstract class HomeEvent with _$HomeEvent {
  const factory HomeEvent.init() = _Init;

  const factory HomeEvent.dayChanged({
    @required int newDay,
  }) = _DayChanged;
}
