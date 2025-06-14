part of 'elements_bloc.dart';

@freezed
sealed class ElementsState with _$ElementsState {
  const factory ElementsState.loading() = ElementsStateLoading;

  const factory ElementsState.loaded({
    required List<ElementCardModel> debuffs,
    required List<ElementReactionCardModel> reactions,
    required List<ElementReactionCardModel> resonances,
  }) = ElementsStateLoaded;
}
