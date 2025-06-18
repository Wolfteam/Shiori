part of 'character_bloc.dart';

@freezed
sealed class CharacterEvent with _$CharacterEvent {
  const factory CharacterEvent.loadFromKey({required String key}) = CharacterEventLoadFromKey;

  const factory CharacterEvent.addToInventory({required String key}) = CharacterEventAddToInventory;

  const factory CharacterEvent.deleteFromInventory({required String key}) = CharacterEventDeleteFromInventory;
}
