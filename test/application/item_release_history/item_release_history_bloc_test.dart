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
      final resourceService = getResourceService(settingsService);
      _genshinService = GenshinServiceImpl(resourceService, localeService);

      await _genshinService.init(settingsService.language);
    });
  });

  test(
    'Initial state',
    () => expect(
      ItemReleaseHistoryBloc(_genshinService, _telemetryService).state,
      const ItemReleaseHistoryState.loading(),
    ),
  );

  group('Init', () {
    blocTest<ItemReleaseHistoryBloc, ItemReleaseHistoryState>(
      'valid item key',
      build: () => ItemReleaseHistoryBloc(_genshinService, _telemetryService),
      act: (bloc) => bloc.add(const ItemReleaseHistoryEvent.init(itemKey: 'keqing')),
      verify: (bloc) => bloc.state.map(
        loading: (_) => throw Exception('Invalid state'),
        initial: (state) {
          expect(state.itemKey, 'keqing');
          expect(state.history.isNotEmpty, isTrue);
          for (final history in state.history) {
            expect(history.version >= 1, isTrue);
            for (final dates in history.dates) {
              expect(dates.until.isAfter(dates.from), isTrue);
            }
          }
        },
      ),
    );

    blocTest<ItemReleaseHistoryBloc, ItemReleaseHistoryState>(
      'invalid item key',
      build: () => ItemReleaseHistoryBloc(_genshinService, _telemetryService),
      act: (bloc) => bloc.add(const ItemReleaseHistoryEvent.init(itemKey: 'no-existent-item')),
      errors: () => [isA<Exception>()],
    );
  });
}
