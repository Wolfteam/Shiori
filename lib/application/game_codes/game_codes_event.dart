part of 'game_codes_bloc.dart';

@freezed
abstract class GameCodesEvent with _$GameCodesEvent {
  const factory GameCodesEvent.init() = _Init;

  const factory GameCodesEvent.markAsUsed({
    @required String code,
    @required bool wasUsed,
  }) = _MarkAsUsed;

  const factory GameCodesEvent.close() = _Close;
}
