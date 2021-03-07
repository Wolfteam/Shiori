part of 'game_codes_bloc.dart';

@freezed
abstract class GameCodesState with _$GameCodesState {
  const factory GameCodesState.loading() = _Loading;

  const factory GameCodesState.loaded({
    @required List<GameCodeFileModel> workingGameCodes,
    @required List<GameCodeFileModel> expiredGameCodes,
  }) = _Loaded;
}
