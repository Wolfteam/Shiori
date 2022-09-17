import 'package:bloc/bloc.dart';
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
      : super(const CheckForResourceUpdatesState.loading());

  @override
  Stream<CheckForResourceUpdatesState> mapEventToState(CheckForResourceUpdatesEvent event) async* {
    yield const CheckForResourceUpdatesState.loading();
    await Future.delayed(const Duration(seconds: 1));
    final s = await event.map(init: (_) => _init());
    yield s;
  }

  Future<CheckForResourceUpdatesState> _init() async {
    final result = await _resourceService.checkForUpdates(_deviceInfoService.version, _settingsService.resourceVersion);
    await _telemetryService.trackCheckForResourceUpdates(result.type);
    return CheckForResourceUpdatesState.loaded(
      updateResultType: result.type,
      currentResourceVersion: _settingsService.resourceVersion,
      targetResourceVersion: result.resourceVersion == _settingsService.resourceVersion ? null : result.resourceVersion,
    );
  }
}
