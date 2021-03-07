part of 'game_codes_bloc.dart';

@freezed
abstract class GameCodesEvent with _$GameCodesEvent {
  const factory GameCodesEvent.init() = _Init;
}
