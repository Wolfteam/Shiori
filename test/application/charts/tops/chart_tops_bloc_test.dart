import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../../common.dart';
import '../../../mocks.mocks.dart';

void main() {
  late LocaleService _localeService;
  late SettingsService _settingsService;
  late GenshinService _genshinService;
  late TelemetryService _telemetryService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _settingsService = MockSettingsService();
    when(_settingsService.language).thenReturn(AppLanguageType.english);
    when(_settingsService.showCharacterDetails).thenReturn(true);
    _localeService = LocaleServiceImpl(_settingsService);
    final resourceService = getResourceService(_settingsService);
    _genshinService = GenshinServiceImpl(resourceService, _localeService);
    _telemetryService = MockTelemetryService();

    return Future(() async {
      await _genshinService.init(AppLanguageType.english);
    });
  });

  test('Initial state', () => expect(ChartTopsBloc(_genshinService, _telemetryService).state, const ChartTopsState.loading()));

  blocTest<ChartTopsBloc, ChartTopsState>(
    'Init emits loaded state',
    build: () => ChartTopsBloc(_genshinService, _telemetryService),
    act: (bloc) => bloc.add(const ChartTopsEvent.init()),
    expect: () {
      final tops = [
        ..._genshinService.getTopCharts(ChartType.topFiveStarCharacterMostReruns),
        ..._genshinService.getTopCharts(ChartType.topFiveStarCharacterLeastReruns),
        ..._genshinService.getTopCharts(ChartType.topFiveStarWeaponMostReruns),
        ..._genshinService.getTopCharts(ChartType.topFiveStarWeaponLeastReruns),
        ..._genshinService.getTopCharts(ChartType.topFourStarCharacterMostReruns),
        ..._genshinService.getTopCharts(ChartType.topFourStarCharacterLeastReruns),
        ..._genshinService.getTopCharts(ChartType.topFourStarWeaponMostReruns),
        ..._genshinService.getTopCharts(ChartType.topFourStarWeaponLeastReruns),
      ];

      return [ChartTopsState.loaded(tops: tops)];
    },
  );
}
