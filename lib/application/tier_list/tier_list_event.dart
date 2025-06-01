part of 'tier_list_bloc.dart';

@freezed
sealed class TierListEvent with _$TierListEvent {
  const factory TierListEvent.init({
    @Default(false) bool reset,
  }) = TierListEventInit;

  const factory TierListEvent.rowTextChanged({
    required int index,
    required String newValue,
  }) = TierListEventRowTextChanged;

  const factory TierListEvent.rowPositionChanged({
    required int index,
    required int newIndex,
  }) = TierListEventRowPositionChanged;

  const factory TierListEvent.rowColorChanged({
    required int index,
    required int newColor,
  }) = TierListEventRowColorChanged;

  const factory TierListEvent.addNewRow({
    required int index,
    required bool above,
  }) = TierListEventAddRow;

  const factory TierListEvent.deleteRow({
    required int index,
  }) = TierListEventDeleteRow;

  const factory TierListEvent.clearRow({
    required int index,
  }) = TierListEventClearRow;

  const factory TierListEvent.clearAllRows() = TierListEventClearAllRows;

  const factory TierListEvent.addCharacterToRow({
    required int index,
    required ItemCommon item,
  }) = TierListEventAddCharacterToRow;

  const factory TierListEvent.deleteCharacterFromRow({
    required int index,
    required ItemCommon item,
  }) = TierListEventDeleteCharacterFromRow;

  const factory TierListEvent.readyToSave({required bool ready}) = TierListEventReadyToSave;

  const factory TierListEvent.screenshotTaken({
    required bool succeed,
    Object? ex,
    StackTrace? trace,
  }) = TierListEventScreenshotTaken;
}
