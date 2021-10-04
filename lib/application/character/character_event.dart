part of 'character_bloc.dart';

@freezed
class CharacterEvent with _$CharacterEvent {
  const factory CharacterEvent.loadFromKey({
    required String key,
    @Default(true) bool addToQueue,
  }) = _LoadCharacterFroName;

  const factory CharacterEvent.addedToInventory({
    required String key,
    required bool wasAdded,
  }) = _AddedToInventory;
}
