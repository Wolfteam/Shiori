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
  late GenshinService genshinService;
  late TelemetryService telemetryService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    return Future(() async {
      telemetryService = MockTelemetryService();
      final settingsService = MockSettingsService();
      when(settingsService.language).thenReturn(AppLanguageType.english);

      final localeService = LocaleServiceImpl(settingsService);
      final resourceService = getResourceService(settingsService);
      genshinService = GenshinServiceImpl(resourceService, localeService);

      await genshinService.init(settingsService.language);
    });
  });

  test(
    'Initial state',
    () => expect(
      ItemReleaseHistoryBloc(genshinService, telemetryService).state,
      const ItemReleaseHistoryState.loading(),
    ),
  );

  group('Init', () {
    blocTest<ItemReleaseHistoryBloc, ItemReleaseHistoryState>(
      'valid item key',
      build: () => ItemReleaseHistoryBloc(genshinService, telemetryService),
      act: (bloc) => bloc.add(const ItemReleaseHistoryEvent.init(itemKey: 'keqing')),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case ItemReleaseHistoryStateLoading():
            throw Exception('Invalid state');
          case ItemReleaseHistoryStateInitial():
            expect(state.itemKey, 'keqing');
            expect(state.history.isNotEmpty, isTrue);
            for (final history in state.history) {
              expect(history.version >= 1, isTrue);
              for (final dates in history.dates) {
                expect(dates.until.isAfter(dates.from), isTrue);
              }
            }
        }
      },
    );

    blocTest<ItemReleaseHistoryBloc, ItemReleaseHistoryState>(
      'invalid item key',
      build: () => ItemReleaseHistoryBloc(genshinService, telemetryService),
      act: (bloc) => bloc.add(const ItemReleaseHistoryEvent.init(itemKey: 'no-existent-item')),
      errors: () => [isA<Exception>()],
    );
  });
}
