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

  test('Initial state', () => expect(ChartGendersBloc(_genshinService).state, const ChartGendersState.loading()));

  blocTest<ChartGendersBloc, ChartGendersState>(
    'Init emits loaded state',
    build: () => ChartGendersBloc(_genshinService),
    act: (bloc) => bloc.add(const ChartGendersEvent.init()),
    expect: () {
      final items = _genshinService.getCharacterGendersForCharts();
      final maxCount = max<int>(items.map((e) => e.femaleCount).reduce(max), items.map((e) => e.maleCount).reduce(max));
      return [ChartGendersState.loaded(genders: items, maxCount: maxCount)];
    },
  );
}
