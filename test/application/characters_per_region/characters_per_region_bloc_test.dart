import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../mocks.mocks.dart';

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

  test(
    'Initial state',
    () => expect(
      CharactersPerRegionBloc(_genshinService).state,
      const CharactersPerRegionState.loading(),
    ),
  );

  group('Init', () {
    blocTest<CharactersPerRegionBloc, CharactersPerRegionState>(
      'emits loaded state',
      build: () => CharactersPerRegionBloc(_genshinService),
      act: (bloc) => bloc.add(const CharactersPerRegionEvent.init(type: RegionType.inazuma)),
      expect: () {
        final items = _genshinService.getCharactersForItemsByRegion(RegionType.inazuma);
        return [CharactersPerRegionState.loaded(regionType: RegionType.inazuma, items: items)];
      },
    );

    blocTest<CharactersPerRegionBloc, CharactersPerRegionState>(
      'invalid region',
      build: () => CharactersPerRegionBloc(_genshinService),
      act: (bloc) => bloc.add(const CharactersPerRegionEvent.init(type: RegionType.anotherWorld)),
      errors: () => [isA<Exception>()],
    );
  });
}
