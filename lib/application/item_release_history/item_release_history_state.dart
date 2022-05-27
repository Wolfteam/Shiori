part of 'item_release_history_bloc.dart';

@freezed
class ItemReleaseHistoryState with _$ItemReleaseHistoryState {
  const factory ItemReleaseHistoryState.loading() = _Loading;

  const factory ItemReleaseHistoryState.initial({
    required String itemKey,
    required List<ItemReleaseHistoryModel> history,
  }) = _InitialState;
}
