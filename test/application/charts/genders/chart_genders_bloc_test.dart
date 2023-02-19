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

  test('Initial state', () => expect(ChartGendersBloc(genshinService).state, const ChartGendersState.loading()));

  blocTest<ChartGendersBloc, ChartGendersState>(
    'Init emits loaded state',
    build: () => ChartGendersBloc(genshinService),
    act: (bloc) => bloc.add(const ChartGendersEvent.init()),
    expect: () {
      final items = genshinService.characters.getCharacterGendersForCharts();
      final maxCount = max<int>(items.map((e) => e.femaleCount).reduce(max), items.map((e) => e.maleCount).reduce(max));
      return [ChartGendersState.loaded(genders: items, maxCount: maxCount)];
    },
  );
}
