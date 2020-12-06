part of 'character_bloc.dart';

@freezed
abstract class CharacterEvent with _$CharacterEvent {
  const factory CharacterEvent.loadCharacter({
    @required String name,
  }) = _LoadCharacter;
}
