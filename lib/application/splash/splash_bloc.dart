import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/settings_service.dart';

part 'splash_bloc.freezed.dart';
part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final ResourceService _resourceService;
  final SettingsService _settingsService;
  final DeviceInfoService _deviceInfoService;
  final LanguageModel _language;

  StreamSubscription? _downloadStream;

  SplashBloc(
    this._resourceService,
    this._settingsService,
    this._deviceInfoService,
    LocaleService localeService,
  )   : _language = localeService.getLocaleWithoutLang(),
        super(const SplashState.loading());

  @override
  Stream<SplashState> mapEventToState(SplashEvent event) async* {
    if (event is _Init) {
      //This is just to trigger a change in the ui
      if (event.retry) {
        yield SplashState.loaded(updateResultType: AppResourceUpdateResultType.retrying, language: _language);
        await Future.delayed(const Duration(seconds: 2));
      }

      final result = await _resourceService.checkForUpdates(_deviceInfoService.version, _settingsService.resourceVersion);
      yield SplashState.loaded(updateResultType: result.type, language: _language);

      if (result.type == AppResourceUpdateResultType.updatesAvailable) {
        //the stream is required to avoid blocking the bloc
        final downloadStream = _resourceService
            .downloadAndApplyUpdates(
              result.resourceVersion,
              result.zipFileKeyName,
              result.jsonFileKeyName,
              keyNames: result.keyNames,
              onProgress: (value) => add(SplashEvent.progressChanged(progress: value)),
            )
            .asStream();

        _downloadStream?.cancel();
        _downloadStream = downloadStream.listen((applied) => add(SplashEvent.updateCompleted(applied: applied)));
      }
      return;
    }

    if (event is _ProgressChanged) {
      assert(state is _LoadedState, 'The current state should be loaded');
      final currentState = state as _LoadedState;
      if (event.progress >= 100) {
        yield currentState.copyWith(progress: 100);
        return;
      }

      final diff = (event.progress - currentState.progress).abs();
      if (diff < 1) {
        return;
      }
      yield currentState.copyWith(progress: event.progress);
    }

    if (event is _UpdateCompleted) {
      final appliedResult = event.applied ? AppResourceUpdateResultType.updated : AppResourceUpdateResultType.unknownError;
      yield SplashState.loaded(updateResultType: appliedResult, language: _language, progress: 100);
    }
  }

  @override
  Future<void> close() {
    _downloadStream?.cancel();
    return super.close();
  }
}
