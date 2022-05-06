part of 'birthdays_per_month_bloc.dart';

@freezed
class BirthdaysPerMonthEvent with _$BirthdaysPerMonthEvent {
  const factory BirthdaysPerMonthEvent.init({
    required int month,
  }) = _BirthdaysPerMonthEvent;
}
