import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

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

  test(
    'Initial state',
    () => expect(
      CharactersPerRegionGenderBloc(genshinService).state,
      const CharactersPerRegionGenderState.loading(),
    ),
  );

  group('Init', () {
    blocTest<CharactersPerRegionGenderBloc, CharactersPerRegionGenderState>(
      'emits loaded state',
      build: () => CharactersPerRegionGenderBloc(genshinService),
      act: (bloc) => bloc
        ..add(const CharactersPerRegionGenderEvent.init(regionType: RegionType.inazuma, onlyFemales: true))
        ..add(const CharactersPerRegionGenderEvent.init(regionType: RegionType.inazuma, onlyFemales: false)),
      expect: () {
        final females = genshinService.characters.getCharactersForItemsByRegionAndGender(RegionType.inazuma, true);
        final males = genshinService.characters.getCharactersForItemsByRegionAndGender(RegionType.inazuma, false);
        return [
          CharactersPerRegionGenderState.loaded(regionType: RegionType.inazuma, onlyFemales: true, items: females),
          CharactersPerRegionGenderState.loaded(regionType: RegionType.inazuma, onlyFemales: false, items: males),
        ];
      },
    );

    blocTest<CharactersPerRegionGenderBloc, CharactersPerRegionGenderState>(
      'invalid region',
      build: () => CharactersPerRegionGenderBloc(genshinService),
      act: (bloc) => bloc
        ..add(const CharactersPerRegionGenderEvent.init(regionType: RegionType.anotherWorld, onlyFemales: true))
        ..add(const CharactersPerRegionGenderEvent.init(regionType: RegionType.anotherWorld, onlyFemales: false)),
      errors: () => [isA<Exception>(), isA<Exception>()],
    );
  });
}
