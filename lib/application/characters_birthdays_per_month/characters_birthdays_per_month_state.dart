part of 'characters_birthdays_per_month_bloc.dart';

@freezed
sealed class CharactersBirthdaysPerMonthState with _$CharactersBirthdaysPerMonthState {
  const factory CharactersBirthdaysPerMonthState.loading() = CharactersBirthdaysPerMonthStateLoading;

  const factory CharactersBirthdaysPerMonthState.loaded({
    required int month,
    required List<CharacterBirthdayModel> characters,
  }) = CharactersBirthdaysPerMonthStateLoaded;
}
