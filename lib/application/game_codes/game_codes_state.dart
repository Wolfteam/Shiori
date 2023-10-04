part of 'game_codes_bloc.dart';

@freezed
class GameCodesState with _$GameCodesState {
  const factory GameCodesState.loaded({
    required List<GameCodeModel> workingGameCodes,
    required List<GameCodeModel> expiredGameCodes,
    @Default(false) bool isBusy,
    bool? isInternetAvailable,
    @Default(false) bool unknownErrorOccurred,
  }) = _LoadedState;
}
