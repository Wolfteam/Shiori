part of 'birthdays_per_month_bloc.dart';

@freezed
class BirthdaysPerMonthState with _$BirthdaysPerMonthState {
  const factory BirthdaysPerMonthState.loading() = _LoadingState;

  const factory BirthdaysPerMonthState.loaded({
    required int month,
    required List<CharacterBirthdayModel> characters,
  }) = _LoadedState;
}
