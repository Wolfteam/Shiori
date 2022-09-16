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
  late final GenshinService _genshinService;
  late final SettingsService _settingsService;
  late final LocaleService _localeService;
  late final ArtifactBloc _artifactBloc;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    return Future(() async {
      _settingsService = MockSettingsService();
      when(_settingsService.language).thenReturn(AppLanguageType.english);

      final resourceService = getResourceService(_settingsService);

      _localeService = LocaleServiceImpl(_settingsService);
      _genshinService = GenshinServiceImpl(resourceService, _localeService);

      await _genshinService.init(_settingsService.language);
      _artifactBloc = ArtifactBloc(_genshinService, MockTelemetryService(), resourceService);
    });
  });

  test('Initial state', () => expect(_artifactBloc.state, const ArtifactState.loading()));

  group('Load from key', () {
    const key = 'wanderers-troupe';
    blocTest<ArtifactBloc, ArtifactState>(
      key,
      build: () => _artifactBloc,
      act: (bloc) => bloc.add(const ArtifactEvent.loadFromKey(key: key)),
      verify: (bloc) {
        bloc.state.map(
          loading: (_) => throw Exception('Invalid state'),
          loaded: (state) {
            checkTranslation(state.name, canBeNull: false);
            checkAsset(state.image);
            for (final img in state.images) {
              checkAsset(img);
            }
            for (final item in state.charImages) {
              checkItemCommon(item);
            }
            for (final item in state.droppedBy) {
              checkItemCommon(item);
            }
            expect(state.minRarity, inInclusiveRange(2, 4));
            expect(state.maxRarity, inInclusiveRange(4, 5));
            expect(state.bonus, isNotEmpty);
          },
        );
      },
    );
  });
}
