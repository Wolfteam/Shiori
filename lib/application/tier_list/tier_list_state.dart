part of 'tier_list_bloc.dart';

@freezed
sealed class TierListState with _$TierListState {
  const factory TierListState.loaded({
    required List<TierListRowModel> rows,
    required List<ItemCommon> charsAvailable,
    required bool readyToSave,
  }) = TierListStateLoaded;
}
