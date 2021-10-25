import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/app_language_type.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

import '../../mocks.mocks.dart';

void main() {
  late final TelemetryService _telemetryService;
  late final SettingsService _settingsService;
  late final NetworkService _networkService;
  late final DeviceInfoService _deviceInfoService;

  setUpAll(() {
    _telemetryService = MockTelemetryService();
    _settingsService = MockSettingsService();
    when(_settingsService.language).thenReturn(AppLanguageType.english);
    when(_settingsService.useOfficialMap).thenReturn(true);

    _networkService = MockNetworkService();
    when(_networkService.isInternetAvailable()).thenAnswer((_) => Future.value(true));

    _deviceInfoService = MockDeviceInfoService();
    when(_deviceInfoService.userAgent).thenReturn('Default user agent');
  });

  test(
    'Initial state',
    () => expect(UrlPageBloc(_networkService, _telemetryService, _deviceInfoService, _settingsService).state, const UrlPageState.loading()),
  );

  blocTest<UrlPageBloc, UrlPageState>(
    'Init',
    build: () => UrlPageBloc(_networkService, _telemetryService, _deviceInfoService, _settingsService),
    act: (bloc) => bloc.add(const UrlPageEvent.init(loadMap: true, loadWishSimulator: true, loadDailyCheckIn: true)),
    verify: (bloc) {
      bloc.state.map(
        loading: (_) => throw Exception('Invalid state'),
        loaded: (state) {
          expect(state.hasInternetConnection, true);
          expect(state.mapUrl.startsWith(bloc.officialMapUrl), true);
          expect(state.wishSimulatorUrl, bloc.wishSimulatorUrl);
          expect(state.dailyCheckInUrl.startsWith(bloc.dailyCheckInUrl), true);
          expect(state.userAgent, _deviceInfoService.userAgent);
        },
      );
    },
  );
}
