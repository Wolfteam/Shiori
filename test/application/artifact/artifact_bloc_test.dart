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
  late final GenshinService genshinService;
  late final SettingsService settingsService;
  late final LocaleService localeService;
  late final ArtifactBloc artifactBloc;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    return Future(() async {
      settingsService = MockSettingsService();
      when(settingsService.language).thenReturn(AppLanguageType.english);

      final resourceService = getResourceService(settingsService);

      localeService = LocaleServiceImpl(settingsService);
      genshinService = GenshinServiceImpl(resourceService, localeService);

      await genshinService.init(settingsService.language);
      artifactBloc = ArtifactBloc(genshinService, MockTelemetryService(), resourceService);
    });
  });

  test('Initial state', () => expect(artifactBloc.state, const ArtifactState.loading()));

  group('Load from key', () {
    const key = 'wanderers-troupe';
    blocTest<ArtifactBloc, ArtifactState>(
      key,
      build: () => artifactBloc,
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
            for (final item in state.usedBy) {
              checkItemCommonWithName(item);
            }
            for (final item in state.droppedBy) {
              checkItemCommonWithName(item);
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
