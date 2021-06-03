part of 'game_codes_bloc.dart';

@freezed
abstract class GameCodesState with _$GameCodesState {
  const factory GameCodesState.loaded({
    @required List<GameCodeModel> workingGameCodes,
    @required List<GameCodeModel> expiredGameCodes,
    @Default(false) bool isBusy,
    bool isInternetAvailable,
  }) = _Loaded;
}
