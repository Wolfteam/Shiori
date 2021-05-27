import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/services/device_info_service.dart';
import 'package:genshindb/domain/services/network_service.dart';
import 'package:genshindb/domain/services/settings_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';

part 'url_page_bloc.freezed.dart';
part 'url_page_event.dart';
part 'url_page_state.dart';

class UrlPageBloc extends Bloc<UrlPageEvent, UrlPageState> {
  final wishSimulatorUrl = 'https://gi-wish-simulator.uzairashraf.dev';
  final officialMapUrl = 'https://webstatic-sea.mihoyo.com/app/ys-map-sea/index.html';
  final unofficialMapUrl = 'https://genshin-impact-map.appsample.com';
  final dailyCheckInUrl = 'https://webstatic-sea.mihoyo.com/ys/event/signin-sea/index.html?act_id=e202102251931481&lang=en-us';

  final NetworkService _networkService;
  final TelemetryService _telemetryService;
  final DeviceInfoService _deviceInfoService;
  final SettingsService _settingsService;

  UrlPageBloc(
    this._networkService,
    this._telemetryService,
    this._deviceInfoService,
    this._settingsService,
  ) : super(const UrlPageState.loading());

  @override
  Stream<UrlPageState> mapEventToState(UrlPageEvent event) async* {
    final s = await event.map(
      init: (e) async {
        final finalMapUrl = _settingsService.useOfficialMap ? officialMapUrl : unofficialMapUrl;
        final isInternetAvailable = await _networkService.isInternetAvailable();
        await _telemetryService.trackUrlOpened(e.loadMap, e.loadWishSimulator, e.loadDailyCheckIn, isInternetAvailable);
        return UrlPageState.loaded(
          hasInternetConnection: isInternetAvailable,
          mapUrl: finalMapUrl,
          wishSimulatorUrl: wishSimulatorUrl,
          dailyCheckInUrl: dailyCheckInUrl,
          userAgent: _deviceInfoService.userAgent,
        );
      },
    );

    yield s;
  }
}
