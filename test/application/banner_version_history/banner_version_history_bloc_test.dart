import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
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

      final resourceService = getResourceService(settingsService);
      final localeService = LocaleServiceImpl(settingsService);
      genshinService = GenshinServiceImpl(resourceService, localeService);

      await genshinService.init(settingsService.language);
    });
  });

  test(
    'Initial state',
    () => expect(
      BannerVersionHistoryBloc(genshinService, telemetryService).state,
      const BannerVersionHistoryState.loading(),
    ),
  );

  group('Init', () {
    void validVersionCheck(BannerVersionHistoryState state, double version) => state.map(
          loading: (_) => throw Exception('Invalid state'),
          loadedState: (state) {
            final validItemTypes = [ItemType.character, ItemType.weapon];
            expect(state.version, version);
            expect(state.items.isNotEmpty, isTrue);
            for (final grouped in state.items) {
              final from = DateFormat(BannerVersionHistoryBloc.periodDateFormat).parse(grouped.from);
              final until = DateFormat(BannerVersionHistoryBloc.periodDateFormat).parse(grouped.until);
              expect(until.isAfter(from), isTrue);
              expect(grouped.items.isNotEmpty, isTrue);

              final keys = grouped.items.map((e) => e.key).toList();
              expect(keys.toSet().length == keys.length, isTrue);

              for (final group in grouped.items) {
                checkItemKeyAndImage(group.key, group.image);
                expect(group.rarity >= 4, isTrue);
                expect(validItemTypes.contains(group.type), isTrue);
              }
            }
            return null;
          },
        );

    blocTest<BannerVersionHistoryBloc, BannerVersionHistoryState>(
      'valid version',
      build: () => BannerVersionHistoryBloc(genshinService, telemetryService),
      act: (bloc) => bloc.add(const BannerVersionHistoryEvent.init(version: 1.1)),
      verify: (bloc) => validVersionCheck(bloc.state, 1.1),
    );

    blocTest<BannerVersionHistoryBloc, BannerVersionHistoryState>(
      'valid version, double banner',
      build: () => BannerVersionHistoryBloc(genshinService, telemetryService),
      act: (bloc) => bloc.add(const BannerVersionHistoryEvent.init(version: 2.4)),
      verify: (bloc) => validVersionCheck(bloc.state, 2.4),
    );

    blocTest<BannerVersionHistoryBloc, BannerVersionHistoryState>(
      'invalid version',
      build: () => BannerVersionHistoryBloc(genshinService, telemetryService),
      act: (bloc) => bloc.add(const BannerVersionHistoryEvent.init(version: 0.5)),
      errors: () => [isA<Exception>()],
    );
  });
}
