import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';
import 'package:meta/meta.dart';

part 'game_codes_bloc.freezed.dart';
part 'game_codes_event.dart';
part 'game_codes_state.dart';

class GameCodesBloc extends Bloc<GameCodesEvent, GameCodesState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;

  GameCodesBloc(this._genshinService, this._telemetryService) : super(const GameCodesState.loading());

  @override
  Stream<GameCodesState> mapEventToState(GameCodesEvent event) async* {
    final s = await event.when(
      init: () async {
        final gameCodes = _genshinService.getAllGameCodes();

        return GameCodesState.loaded(
          workingGameCodes: gameCodes.where((code) => !code.isExpired).toList(),
          expiredGameCodes: gameCodes.where((code) => code.isExpired).toList(),
        );
      },
      opened: () async {
        await _telemetryService.trackGameCodesOpened();
        return state;
      },
    );

    yield s;
  }
}
