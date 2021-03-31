part of 'character_bloc.dart';

@freezed
abstract class CharacterEvent with _$CharacterEvent {
  const factory CharacterEvent.loadFromName({
    @required String key,
    @Default(true) bool addToQueue,
  }) = _LoadCharacterFroName;

  const factory CharacterEvent.loadFromImg({
    @required String image,
    @Default(true) bool addToQueue,
  }) = _LoadCharacterFromImg;

  const factory CharacterEvent.addedToInventory({
    @required String key,
    @required bool wasAdded,
  }) = _AddedToInventory;
}
