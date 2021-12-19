part of 'character_bloc.dart';

@freezed
class CharacterEvent with _$CharacterEvent {
  const factory CharacterEvent.loadFromKey({required String key}) = _LoadCharacterFroName;

  const factory CharacterEvent.addToInventory({required String key}) = _AddToInventory;

  const factory CharacterEvent.deleteFromInventory({required String key}) = _DeleteFromInventory;
}
