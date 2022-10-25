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
  late LocaleService _localeService;
  late SettingsService _settingsService;
  late GenshinService _genshinService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _settingsService = MockSettingsService();
    when(_settingsService.language).thenReturn(AppLanguageType.english);
    when(_settingsService.showCharacterDetails).thenReturn(true);
    _localeService = LocaleServiceImpl(_settingsService);
    final resourceService = getResourceService(_settingsService);
    _genshinService = GenshinServiceImpl(resourceService, _localeService);

    return Future(() async {
      await _genshinService.init(AppLanguageType.english);
    });
  });

  test(
    'Initial state',
    () => expect(ChartBirthdaysBloc(_genshinService).state, const ChartBirthdaysState.loading()),
  );

  blocTest<ChartBirthdaysBloc, ChartBirthdaysState>(
    'Init emits loaded state',
    build: () => ChartBirthdaysBloc(_genshinService),
    act: (bloc) => bloc.add(const ChartBirthdaysEvent.init()),
    expect: () {
      final birthdays = _genshinService.characters.getCharacterBirthdaysForCharts();
      return [ChartBirthdaysState.loaded(birthdays: birthdays)];
    },
  );
}
