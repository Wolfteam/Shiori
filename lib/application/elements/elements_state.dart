part of 'elements_bloc.dart';

@freezed
class ElementsState with _$ElementsState {
  const factory ElementsState.loading() = _LoadingState;
  const factory ElementsState.loaded({
    required List<ElementCardModel> debuffs,
    required List<ElementReactionCardModel> reactions,
    required List<ElementReactionCardModel> resonances,
  }) = _LoadedState;
}
