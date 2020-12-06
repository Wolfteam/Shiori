part of 'characters_bloc.dart';

@freezed
abstract class CharactersState with _$CharactersState {
  const factory CharactersState.loading() = _LoadingState;
  const factory CharactersState.loaded({
    @required List<CharacterCardModel> characters,
  }) = _LoadedState;
}
