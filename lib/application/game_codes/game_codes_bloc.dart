import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/game_code_service.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'game_codes_bloc.freezed.dart';
part 'game_codes_event.dart';
part 'game_codes_state.dart';

const _initialState = GameCodesState.loaded(workingGameCodes: [], expiredGameCodes: []);

class GameCodesBloc extends Bloc<GameCodesEvent, GameCodesState> {
  final DataService _dataService;
  final TelemetryService _telemetryService;
  final GameCodeService _gameCodeService;
  final NetworkService _networkService;

  GameCodesBloc(this._dataService, this._telemetryService, this._gameCodeService, this._networkService) : super(_initialState);

  @override
  Stream<GameCodesState> mapEventToState(GameCodesEvent event) async* {
    if (event is _Refresh) {
      final isInternetAvailable = await _networkService.isInternetAvailable();
      if (!isInternetAvailable) {
        yield state.copyWith.call(isInternetAvailable: false);
        yield state.copyWith.call(isInternetAvailable: null);
        return;
      }
      yield _initialState.copyWith.call(isBusy: true, workingGameCodes: [], expiredGameCodes: []);
    }

    final s = await event.maybeWhen(
      init: () async {
        await _telemetryService.trackGameCodesOpened();
        return _buildInitialState();
      },
      markAsUsed: (code, wasUsed) async {
        await _dataService.markCodeAsUsed(code, wasUsed: wasUsed);
        return _buildInitialState();
      },
      close: () async => _initialState,
      refresh: () async {
        final gameCodes = await _gameCodeService.getAllGameCodes();
        await _dataService.saveGameCodes(gameCodes);

        await _telemetryService.trackGameCodesOpened();
        return _buildInitialState();
      },
      orElse: () async => _initialState,
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
