import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'check_for_resource_updates_bloc.freezed.dart';
part 'check_for_resource_updates_event.dart';
part 'check_for_resource_updates_state.dart';

class CheckForResourceUpdatesBloc extends Bloc<CheckForResourceUpdatesEvent, CheckForResourceUpdatesState> {
  final ResourceService _resourceService;
  final SettingsService _settingsService;
  final DeviceInfoService _deviceInfoService;
  final TelemetryService _telemetryService;

  CheckForResourceUpdatesBloc(this._resourceService, this._settingsService, this._deviceInfoService, this._telemetryService)
    : super(const CheckForResourceUpdatesState.loading()) {
    on<CheckForResourceUpdatesEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(CheckForResourceUpdatesEvent event, Emitter<CheckForResourceUpdatesState> emit) async {
    switch (event) {
      case CheckForResourceUpdatesEventInit():
        final state = await _init();
        emit(state);
      case CheckForResourceUpdatesEventCheckForUpdates():
        emit(const CheckForResourceUpdatesState.loading());
        final state = await _checkForUpdates();
        emit(state);
    }
  }

  Future<CheckForResourceUpdatesState> _init() {
    final state = CheckForResourceUpdatesState.loaded(
      currentResourceVersion: _settingsService.resourceVersion,
      noResourcesHaveBeenDownloaded: _settingsService.noResourcesHasBeenDownloaded,
    );

    return Future.value(state);
  }

  Future<CheckForResourceUpdatesState> _checkForUpdates() async {
    await Future.delayed(const Duration(seconds: 1));
    final result = await _resourceService.checkForUpdates(
      _deviceInfoService.version,
      _settingsService.resourceVersion,
      updateResourceCheckedDate: false,
    );
    await _telemetryService.trackCheckForResourceUpdates(result.type);
    return CheckForResourceUpdatesState.loaded(
      updateResultType: result.type,
      currentResourceVersion: _settingsService.resourceVersion,
      targetResourceVersion:
          result.resourceVersion == _settingsService.resourceVersion ||
              result.type != AppResourceUpdateResultType.updatesAvailable
          ? null
          : result.resourceVersion,
      downloadTotalSize: result.downloadTotalSize,
      noResourcesHaveBeenDownloaded: _settingsService.noResourcesHasBeenDownloaded,
    );
  }
}
