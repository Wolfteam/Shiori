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
      CharactersPerRegionGenderBloc(_genshinService).state,
      const CharactersPerRegionGenderState.loading(),
    ),
  );

  group('Init', () {
    blocTest<CharactersPerRegionGenderBloc, CharactersPerRegionGenderState>(
      'emits loaded state',
      build: () => CharactersPerRegionGenderBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const CharactersPerRegionGenderEvent.init(regionType: RegionType.inazuma, onlyFemales: true))
        ..add(const CharactersPerRegionGenderEvent.init(regionType: RegionType.inazuma, onlyFemales: false)),
      expect: () {
        final females = _genshinService.getCharactersForItemsByRegionAndGender(RegionType.inazuma, true);
        final males = _genshinService.getCharactersForItemsByRegionAndGender(RegionType.inazuma, false);
        return [
          CharactersPerRegionGenderState.loaded(regionType: RegionType.inazuma, onlyFemales: true, items: females),
          CharactersPerRegionGenderState.loaded(regionType: RegionType.inazuma, onlyFemales: false, items: males),
        ];
      },
    );

    blocTest<CharactersPerRegionGenderBloc, CharactersPerRegionGenderState>(
      'invalid region',
      build: () => CharactersPerRegionGenderBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const CharactersPerRegionGenderEvent.init(regionType: RegionType.anotherWorld, onlyFemales: true))
        ..add(const CharactersPerRegionGenderEvent.init(regionType: RegionType.anotherWorld, onlyFemales: false)),
      errors: () => [isA<Exception>(), isA<Exception>()],
    );
  });
}
