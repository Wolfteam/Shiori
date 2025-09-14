part of 'characters_birthdays_per_month_bloc.dart';

@freezed
sealed class CharactersBirthdaysPerMonthEvent with _$CharactersBirthdaysPerMonthEvent {
  const factory CharactersBirthdaysPerMonthEvent.init({
    required int month,
  }) = CharactersBirthdaysPerMonthEventBirthdaysPerMonthEvent;
}
