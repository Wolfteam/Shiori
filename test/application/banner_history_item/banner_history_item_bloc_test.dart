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
  late GenshinService _genshinService;
  late TelemetryService _telemetryService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    return Future(() async {
      _telemetryService = MockTelemetryService();
      final settingsService = MockSettingsService();
      when(settingsService.language).thenReturn(AppLanguageType.english);

      final localeService = LocaleServiceImpl(settingsService);
      _genshinService = GenshinServiceImpl(localeService);

      await _genshinService.init(settingsService.language);
    });
  });

  test(
    'Initial state',
    () => expect(
      BannerHistoryItemBloc(_genshinService, _telemetryService).state,
      const BannerHistoryItemState.loading(),
    ),
  );

  group('Init', () {
    blocTest<BannerHistoryItemBloc, BannerHistoryItemState>(
      'valid version',
      build: () => BannerHistoryItemBloc(_genshinService, _telemetryService),
      act: (bloc) => bloc.add(const BannerHistoryItemEvent.init(version: 1.1)),
      verify: (bloc) => bloc.state.map(
        loading: (_) => throw Exception('Invalid state'),
        loadedState: (state) {
          final validItemTypes = [ItemType.character, ItemType.weapon];
          expect(state.version, 1.1);
          expect(state.items.isNotEmpty, isTrue);
          for (final item in state.items) {
            expect(item.until.isAfter(item.from), isTrue);
            expect(item.version >= 1, isTrue);
            expect(BannerHistoryItemType.values.contains(item.type), isTrue);
            for (final el in item.items) {
              checkItemKeyAndImage(el.key, el.image);
              expect(el.rarity >= 4, isTrue);
              expect(validItemTypes.contains(el.type), isTrue);
            }
          }
        },
      ),
    );

    blocTest<BannerHistoryItemBloc, BannerHistoryItemState>(
      'invalid version',
      build: () => BannerHistoryItemBloc(_genshinService, _telemetryService),
      act: (bloc) => bloc.add(const BannerHistoryItemEvent.init(version: 0.5)),
      errors: () => [isA<Exception>()],
    );
  });
}
