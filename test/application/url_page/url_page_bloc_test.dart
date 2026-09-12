import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/app_language_type.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

import '../../mocks.mocks.dart';

void main() {
  late final TelemetryService telemetryService;
  late final SettingsService settingsService;
  late final NetworkService networkService;
  late final DeviceInfoService deviceInfoService;

  setUpAll(() {
    telemetryService = MockTelemetryService();
    settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    when(settingsService.useOfficialMap).thenReturn(true);

    networkService = MockNetworkService();
    when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(true));

    deviceInfoService = MockDeviceInfoService();
    when(deviceInfoService.userAgent).thenReturn('Default user agent');
  });

  test(
    'Initial state',
    () => expect(
      UrlPageBloc(networkService, telemetryService, deviceInfoService, settingsService).state,
      const UrlPageState.loading(),
      reason: 'A fresh UrlPageBloc should start in loading state'),
  );

  blocTest<UrlPageBloc, UrlPageState>(
    'Init',
    build: () => UrlPageBloc(networkService, telemetryService, deviceInfoService, settingsService),
    act: (bloc) => bloc.add(const UrlPageEvent.init(loadMap: true, loadDailyCheckIn: true)),
    verify: (bloc) {
      final state = bloc.state;
      switch (state) {
        case UrlPageStateLoading():
          throw InvalidStateError();
        case UrlPageStateLoaded():
          expect(state.hasInternetConnection, true, reason: 'Network is available so hasInternetConnection should be true, got ${state.hasInternetConnection}');
          expect(state.mapUrl.startsWith(bloc.officialMapUrl), true, reason: 'With useOfficialMap true, mapUrl should start with the official map url, got ${state.mapUrl}');
          expect(state.dailyCheckInUrl.startsWith(bloc.dailyCheckInUrl), true, reason: 'dailyCheckInUrl should start with the bloc daily check-in url, got ${state.dailyCheckInUrl}');
          expect(state.userAgent, deviceInfoService.userAgent, reason: 'Loaded state should carry the device userAgent, got ${state.userAgent}');
      }
    },
  );
}
