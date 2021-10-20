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
  late final GenshinService _genshinService;
  late final SettingsService _settingsService;
  late final LocaleService _localeService;
  late final ArtifactBloc _artifactBloc;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    return Future(() async {
      _settingsService = MockSettingsService();
      when(_settingsService.language).thenReturn(AppLanguageType.english);

      _localeService = LocaleServiceImpl(_settingsService);
      _genshinService = GenshinServiceImpl(_localeService);

      await _genshinService.init(_settingsService.language);
      _artifactBloc = ArtifactBloc(_genshinService, MockTelemetryService());
    });
  });

  test('Initial state', () => expect(_artifactBloc.state, const ArtifactState.loading()));

  group('Load from key', () {
    const key = 'wanderers-troupe';
    blocTest<ArtifactBloc, ArtifactState>(
      key,
      build: () => _artifactBloc,
      act: (bloc) => bloc.add(const ArtifactEvent.loadFromKey(key: key)),
      expect: () {
        final detail = _genshinService.getArtifact(key);
        final translation = _genshinService.getArtifactTranslation(key);
        final bonus = _genshinService.getArtifactBonus(translation);
        final charImgs = _genshinService.getCharacterForItemsUsingArtifact(key);
        final droppedBy = _genshinService.getRelatedMonsterToArtifactForItems(key);
        final images = _genshinService.getArtifactRelatedParts(detail.fullImagePath, detail.image, translation.bonus.length);
        return [
          const ArtifactState.loading(),
          ArtifactState.loaded(
            name: translation.name,
            image: detail.fullImagePath,
            minRarity: detail.minRarity,
            maxRarity: detail.maxRarity,
            bonus: bonus,
            images: images,
            charImages: charImgs,
            droppedBy: droppedBy,
          )
        ];
      },
    );
  });
}
