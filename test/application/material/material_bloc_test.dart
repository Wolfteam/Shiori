import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

void main() {
  late final TelemetryService _telemetryService;
  late final GenshinService _genshinService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _telemetryService = MockTelemetryService();
    final settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    final localeService = LocaleServiceImpl(settingsService);
    _genshinService = GenshinServiceImpl(localeService);

    return Future(() async {
      await _genshinService.init(settingsService.language);
    });
  });

  test('Initial state', () => expect(MaterialBloc(_genshinService, _telemetryService).state, const MaterialState.loading()));

  group('Load from key', () {
    const key = 'slime-secretions';
    blocTest<MaterialBloc, MaterialState>(
      key,
      build: () => MaterialBloc(_genshinService, _telemetryService),
      act: (bloc) => bloc.add(const MaterialEvent.loadFromKey(key: key)),
      verify: (bloc) {
        bloc.state.map(
          loading: (_) => throw Exception('Invalid state'),
          loaded: (state) {
            checkTranslation(state.name, canBeNull: false);
            checkAsset(state.fullImage);
            expect(state.rarity, 2);
            expect(state.type, MaterialType.common);
            checkItemsCommon(state.characters);
            checkItemsCommon(state.weapons);
            checkItemsCommon(state.droppedBy);
            expect(state.days, isEmpty);
            expect(state.obtainedFrom, isNotEmpty);
            final items = state.obtainedFrom.expand((el) => el.items).toList();
            for (final item in items) {
              checkItemKeyAndImage(item.key, item.image);
            }
            checkItemsCommon(state.relatedMaterials);
          },
        );
      },
    );
  });
}
