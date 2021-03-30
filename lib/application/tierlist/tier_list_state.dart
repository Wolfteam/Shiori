part of 'tier_list_bloc.dart';

@freezed
abstract class TierListState with _$TierListState {
  const factory TierListState.loaded({
    @required List<TierListRowModel> rows,
    @required List<String> charsAvailable,
    @required bool readyToSave,
  }) = _LoadedState;
}
