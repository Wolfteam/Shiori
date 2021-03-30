import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/data_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';
import 'package:meta/meta.dart';

part 'game_codes_bloc.freezed.dart';
part 'game_codes_event.dart';
part 'game_codes_state.dart';

const _initialState = GameCodesState.loaded(workingGameCodes: [], expiredGameCodes: []);

class GameCodesBloc extends Bloc<GameCodesEvent, GameCodesState> {
  final DataService _dataService;
  final TelemetryService _telemetryService;

  GameCodesBloc(this._dataService, this._telemetryService) : super(_initialState);

  @override
  Stream<GameCodesState> mapEventToState(GameCodesEvent event) async* {
    final s = await event.when(
      init: () async {
        await _telemetryService.trackGameCodesOpened();
        return _buildInitialState();
      },
      markAsUsed: (code, wasUsed) async {
        await _dataService.markCodeAsUsed(code, wasUsed: wasUsed);
        return _buildInitialState();
      },
      close: () async => _initialState,
    );

    yield s;
  }

  GameCodesState _buildInitialState() {
    final gameCodes = _dataService.getAllGameCodes();

    return GameCodesState.loaded(
      workingGameCodes: gameCodes.where((code) => !code.isExpired).toList(),
      expiredGameCodes: gameCodes.where((code) => code.isExpired).toList(),
    );
  }
}
