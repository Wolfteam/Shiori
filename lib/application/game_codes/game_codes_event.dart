part of 'game_codes_bloc.dart';

@freezed
sealed class GameCodesEvent with _$GameCodesEvent {
  const factory GameCodesEvent.init() = GameCodesEventInit;

  const factory GameCodesEvent.markAsUsed({
    required String code,
    required bool wasUsed,
  }) = GameCodesEventMarkAsUsed;

  const factory GameCodesEvent.refresh() = GameCodesEventRefresh;
}
