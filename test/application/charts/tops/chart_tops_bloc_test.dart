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
  late LocaleService localeService;
  late SettingsService settingsService;
  late GenshinService genshinService;
  late TelemetryService telemetryService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    when(settingsService.showCharacterDetails).thenReturn(true);
    localeService = LocaleServiceImpl(settingsService);
    final resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);
    telemetryService = MockTelemetryService();

    return Future(() async {
      await genshinService.init(AppLanguageType.english);
    });
  });

  test('Initial state', () => expect(ChartTopsBloc(genshinService, telemetryService).state, const ChartTopsState.loading()));

  blocTest<ChartTopsBloc, ChartTopsState>(
    'Init emits loaded state',
    build: () => ChartTopsBloc(genshinService, telemetryService),
    act: (bloc) => bloc.add(const ChartTopsEvent.init()),
    expect: () {
      final tops = [
        ...genshinService.getTopCharts(ChartType.topFiveStarCharacterMostReruns),
        ...genshinService.getTopCharts(ChartType.topFiveStarCharacterLeastReruns),
        ...genshinService.getTopCharts(ChartType.topFiveStarWeaponMostReruns),
        ...genshinService.getTopCharts(ChartType.topFiveStarWeaponLeastReruns),
        ...genshinService.getTopCharts(ChartType.topFourStarCharacterMostReruns),
        ...genshinService.getTopCharts(ChartType.topFourStarCharacterLeastReruns),
        ...genshinService.getTopCharts(ChartType.topFourStarWeaponMostReruns),
        ...genshinService.getTopCharts(ChartType.topFourStarWeaponLeastReruns),
      ];

      return [ChartTopsState.loaded(tops: tops)];
    },
  );
}
