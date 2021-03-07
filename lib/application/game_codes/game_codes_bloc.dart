import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:meta/meta.dart';

part 'game_codes_bloc.freezed.dart';
part 'game_codes_event.dart';
part 'game_codes_state.dart';

class GameCodesBloc extends Bloc<GameCodesEvent, GameCodesState> {
  final GenshinService _genshinService;

  GameCodesBloc(this._genshinService) : super(const GameCodesState.loading());

  @override
  Stream<GameCodesState> mapEventToState(GameCodesEvent event) async* {
    final s = event.when(
      init: () {
        final gameCodes = _genshinService.getAllGameCodes();

        return GameCodesState.loaded(
          workingGameCodes: gameCodes.where((code) => !code.isExpired).toList(),
          expiredGameCodes: gameCodes.where((code) => code.isExpired).toList(),
        );
      },
    );

    yield s;
  }
}
