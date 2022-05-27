part of 'characters_birthdays_per_month_bloc.dart';

@freezed
class CharactersBirthdaysPerMonthState with _$CharactersBirthdaysPerMonthState {
  const factory CharactersBirthdaysPerMonthState.loading() = _LoadingState;

  const factory CharactersBirthdaysPerMonthState.loaded({
    required int month,
    required List<CharacterBirthdayModel> characters,
  }) = _LoadedState;
}
