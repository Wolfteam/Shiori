import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../../common.dart';
import '../../../mocks.mocks.dart';

void main() {
  late LocaleService localeService;
  late SettingsService settingsService;
  late GenshinService genshinService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    when(settingsService.showCharacterDetails).thenReturn(true);
    localeService = LocaleServiceImpl(settingsService);
    final resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);

    return Future(() async {
      await genshinService.init(AppLanguageType.english);
    });
  });

  test('Initial state', () => expect(ChartRegionsBloc(genshinService).state, const ChartRegionsState.loading()));

  blocTest<ChartRegionsBloc, ChartRegionsState>(
    'Init emits loaded state',
    build: () => ChartRegionsBloc(genshinService),
    act: (bloc) => bloc.add(const ChartRegionsEvent.init()),
    expect: () {
      final items = genshinService.characters.getCharacterRegionsForCharts();
      final maxCount = items.map((e) => e.quantity).reduce(max);
      return [ChartRegionsState.loaded(maxCount: maxCount, items: items)];
    },
  );
}
