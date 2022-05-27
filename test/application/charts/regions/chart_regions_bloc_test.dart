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

import '../../../mocks.mocks.dart';

void main() {
  late LocaleService _localeService;
  late SettingsService _settingsService;
  late GenshinService _genshinService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _settingsService = MockSettingsService();
    when(_settingsService.language).thenReturn(AppLanguageType.english);
    when(_settingsService.showCharacterDetails).thenReturn(true);
    _localeService = LocaleServiceImpl(_settingsService);
    _genshinService = GenshinServiceImpl(_localeService);

    return Future(() async {
      await _genshinService.init(AppLanguageType.english);
    });
  });

  test('Initial state', () => expect(ChartRegionsBloc(_genshinService).state, const ChartRegionsState.loading()));

  blocTest<ChartRegionsBloc, ChartRegionsState>(
    'Init emits loaded state',
    build: () => ChartRegionsBloc(_genshinService),
    act: (bloc) => bloc.add(const ChartRegionsEvent.init()),
    expect: () {
      final items = _genshinService.getCharacterRegionsForCharts();
      final maxCount = items.map((e) => e.quantity).reduce(max);
      return [ChartRegionsState.loaded(maxCount: maxCount, items: items)];
    },
  );
}
