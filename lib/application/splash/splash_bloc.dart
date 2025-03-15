import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/datetime_extensions.dart';
import 'package:shiori/domain/models/dtos.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/api_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/env.dart';

part 'splash_bloc.freezed.dart';
part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final ResourceService _resourceService;
  final SettingsService _settingsService;
  final DeviceInfoService _deviceInfoService;
  final TelemetryService _telemetryService;
  final DataService _dataService;
  final ApiService _apiService;
  final NetworkService _networkService;
  final LanguageModel _language;

  StreamSubscription? _downloadStream;

  SplashBloc(
    this._resourceService,
    this._settingsService,
    this._deviceInfoService,
    this._telemetryService,
    this._dataService,
    this._apiService,
    this._networkService,
    LocaleService localeService,
  )   : _language = localeService.getLocaleWithoutLang(),
        super(const SplashState.loading());

  @override
  Stream<SplashState> mapEventToState(SplashEvent event) async* {
    await _sendTelemetryData();

    if (event is _Init) {
      final noResourcesHasBeenDownloaded = _settingsService.noResourcesHasBeenDownloaded;
      //This is just to trigger a change in the ui
      if (event.retry) {
        const type = AppResourceUpdateResultType.retrying;
        yield SplashState.loaded(
          updateResultType: type,
          language: _language,
          noResourcesHasBeenDownloaded: noResourcesHasBeenDownloaded,
          isUpdating: _isUpdating(type),
          isLoading: _isLoading(type),
          updateFailed: _updateFailed(type),
          canSkipUpdate: _canSkipUpdate(type),
          noInternetConnectionOnFirstInstall: _noInternetConnectionOnFirstInstall(type),
          needsLatestAppVersionOnFirstInstall: _needsLatestAppVersionOnFirstInstall(type),
        );
        await Future.delayed(const Duration(seconds: 1));
      }

      final skipCheck =
          !noResourcesHasBeenDownloaded && !_settingsService.checkForUpdatesOnStartup && _settingsService.resourceVersion >= Env.minResourceVersion;
      if (skipCheck) {
        const resultType = AppResourceUpdateResultType.noUpdatesAvailable;
        yield SplashState.loaded(
          updateResultType: resultType,
          language: _language,
          noResourcesHasBeenDownloaded: noResourcesHasBeenDownloaded,
          isUpdating: _isUpdating(resultType),
          isLoading: _isLoading(resultType),
          updateFailed: _updateFailed(resultType),
          canSkipUpdate: _canSkipUpdate(resultType),
          noInternetConnectionOnFirstInstall: _noInternetConnectionOnFirstInstall(resultType),
          needsLatestAppVersionOnFirstInstall: _needsLatestAppVersionOnFirstInstall(resultType),
        );
      }

      final result = await _resourceService.checkForUpdates(_deviceInfoService.version, _settingsService.resourceVersion);
      final unknownErrorOnFirstInstall = _unknownErrorOnFirstInstall(result.type);
      final resultType = unknownErrorOnFirstInstall ? AppResourceUpdateResultType.unknownErrorOnFirstInstall : result.type;
      await _telemetryService.trackCheckForResourceUpdates(resultType);
      yield SplashState.loaded(
        updateResultType: resultType,
        language: _language,
        result: result,
        noResourcesHasBeenDownloaded: noResourcesHasBeenDownloaded,
        isUpdating: _isUpdating(resultType),
        isLoading: _isLoading(resultType),
        updateFailed: _updateFailed(resultType),
        canSkipUpdate: _canSkipUpdate(resultType),
        noInternetConnectionOnFirstInstall: _noInternetConnectionOnFirstInstall(resultType),
        needsLatestAppVersionOnFirstInstall: _needsLatestAppVersionOnFirstInstall(resultType),
      );
      return;
    }

    if (event is _ApplyUpdate) {
      assert(state is _LoadedState, 'The current state should be loaded');
      final currentState = state as _LoadedState;
      assert(currentState.result != null, 'The update result must not be null');

      const type = AppResourceUpdateResultType.updating;
      yield currentState.copyWith(
        updateResultType: type,
        isUpdating: _isUpdating(type),
        isLoading: _isLoading(type),
        updateFailed: _updateFailed(type),
        canSkipUpdate: _canSkipUpdate(type),
        noInternetConnectionOnFirstInstall: _noInternetConnectionOnFirstInstall(type),
        needsLatestAppVersionOnFirstInstall: _needsLatestAppVersionOnFirstInstall(type),
      );

      //the stream is required to avoid blocking the bloc
      final result = currentState.result!;
      final downloadStream = _resourceService
          .downloadAndApplyUpdates(
            result.resourceVersion,
            result.jsonFileKeyName,
            keyNames: result.keyNames,
            onProgress: (progress, downloadedBytes) => add(SplashEvent.progressChanged(progress: progress, downloadedBytes: downloadedBytes)),
          )
          .asStream();

      await _downloadStream?.cancel();
      _downloadStream = downloadStream.listen(
        (applied) => add(SplashEvent.updateCompleted(applied: applied, resourceVersion: result.resourceVersion)),
      );
    }

    if (event is _ProgressChanged) {
      assert(state is _LoadedState, 'The current state should be loaded');
      if (event.progress < 0) {
        throw Exception('Invalid progress value');
      }

      final currentState = state as _LoadedState;
      final double progress = event.progress;
      final int downloadedBytes = event.downloadedBytes;
      final int downloadTotalSize = currentState.result!.downloadTotalSize!;
      if (progress >= 100) {
        yield currentState.copyWith(progress: 100, downloadedBytes: downloadTotalSize);
        return;
      }

      final diff = (progress - currentState.progress).abs();
      if (diff < 1) {
        return;
      }
      yield currentState.copyWith(progress: progress, downloadedBytes: downloadedBytes);
    }

    if (event is _UpdateCompleted) {
      final appliedResult = event.applied
          ? AppResourceUpdateResultType.updated
          : _settingsService.noResourcesHasBeenDownloaded
              ? AppResourceUpdateResultType.unknownErrorOnFirstInstall
              : AppResourceUpdateResultType.unknownError;
      await _telemetryService.trackResourceUpdateCompleted(event.applied, event.resourceVersion);
      yield SplashState.loaded(
        updateResultType: appliedResult,
        language: _language,
        progress: 100,
        noResourcesHasBeenDownloaded: _settingsService.noResourcesHasBeenDownloaded,
        isUpdating: _isUpdating(appliedResult),
        isLoading: _isLoading(appliedResult),
        updateFailed: _updateFailed(appliedResult),
        canSkipUpdate: _canSkipUpdate(appliedResult),
        noInternetConnectionOnFirstInstall: _noInternetConnectionOnFirstInstall(appliedResult),
        needsLatestAppVersionOnFirstInstall: _needsLatestAppVersionOnFirstInstall(appliedResult),
      );
    }
  }

  @override
  Future<void> close() async {
    await _downloadStream?.cancel();
    return super.close();
  }

  bool _isLoading(AppResourceUpdateResultType type) {
    return type == AppResourceUpdateResultType.noUpdatesAvailable ||
        type == AppResourceUpdateResultType.retrying ||
        type == AppResourceUpdateResultType.updated;
  }

  bool _isUpdating(AppResourceUpdateResultType type) => type == AppResourceUpdateResultType.updating;

  bool _updateFailed(AppResourceUpdateResultType type) {
    return type == AppResourceUpdateResultType.unknownError ||
        type == AppResourceUpdateResultType.unknownErrorOnFirstInstall ||
        type == AppResourceUpdateResultType.noInternetConnection ||
        type == AppResourceUpdateResultType.apiIsUnavailable ||
        _noInternetConnectionOnFirstInstall(type) ||
        _needsLatestAppVersionOnFirstInstall(type);
  }

  bool _noInternetConnectionOnFirstInstall(AppResourceUpdateResultType type) {
    return type == AppResourceUpdateResultType.noInternetConnectionForFirstInstall ||
        (_settingsService.noResourcesHasBeenDownloaded && type == AppResourceUpdateResultType.noInternetConnection);
  }

  bool _needsLatestAppVersionOnFirstInstall(AppResourceUpdateResultType type) =>
      _settingsService.noResourcesHasBeenDownloaded && type == AppResourceUpdateResultType.needsLatestAppVersion;

  bool _canSkipUpdate(AppResourceUpdateResultType type) {
    return type != AppResourceUpdateResultType.unknownErrorOnFirstInstall &&
        !_noInternetConnectionOnFirstInstall(type) &&
        !_needsLatestAppVersionOnFirstInstall(type) &&
        !_settingsService.noResourcesHasBeenDownloaded;
  }

  bool _unknownErrorOnFirstInstall(AppResourceUpdateResultType type) {
    return (type == AppResourceUpdateResultType.unknownError || type == AppResourceUpdateResultType.apiIsUnavailable) &&
        _settingsService.noResourcesHasBeenDownloaded;
  }

  Future<void> _sendTelemetryData() async {
    final bool isNetworkAvailable = await _networkService.isInternetAvailable();
    if (!isNetworkAvailable) {
      return;
    }

    final DateTime? lastCheckedDate = _settingsService.lastTelemetryCheckedDate;
    final List<Telemetry> telemetryData = _dataService.telemetry.getAll();
    final bool send = telemetryData.isNotEmpty && (lastCheckedDate == null || DateTime.now().isAfter(lastCheckedDate.add(const Duration(hours: 3))));
    if (!send) {
      return;
    }
    _settingsService.lastTelemetryCheckedDate = DateTime.now();

    final logs = telemetryData.map((t) => SaveAppLogRequestDto(timestamp: t.createdAt.ticks, message: t.message)).toList();
    final request = SaveAppLogsRequestDto(logs: logs);
    await Future.wait([
      _apiService.sendTelemetryData(request),
      _dataService.telemetry.deleteByIds(telemetryData.map((t) => t.id).toList()),
    ]);
  }
}
