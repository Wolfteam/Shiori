part of 'home_bloc.dart';

@freezed
sealed class HomeEvent with _$HomeEvent {
  const factory HomeEvent.init() = HomeEventInit;

  const factory HomeEvent.dayChanged({
    required int newDay,
  }) = HomeEventDayChanged;
}
