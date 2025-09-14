part of 'item_release_history_bloc.dart';

@freezed
sealed class ItemReleaseHistoryState with _$ItemReleaseHistoryState {
  const factory ItemReleaseHistoryState.loading() = ItemReleaseHistoryStateLoading;

  const factory ItemReleaseHistoryState.initial({
    required String itemKey,
    required List<ItemReleaseHistoryModel> history,
  }) = ItemReleaseHistoryStateInitial;
}
