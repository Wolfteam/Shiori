import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
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
      const BannerVersionHistoryState.loading(), reason: 'A freshly built BannerVersionHistoryBloc must start in BannerVersionHistoryState.loading'),
  );

  group('Init', () {
    void validVersionCheck(BannerVersionHistoryState state, double version) {
      switch (state) {
        case BannerVersionHistoryStateLoading():
          throw InvalidStateError();
        case BannerVersionHistoryStateLoaded():
          final validItemTypes = [ItemType.character, ItemType.weapon];
          expect(state.version, version, reason: 'After init(version), loaded state version must be $version');
          expect(state.items, isNotEmpty, reason: 'Loaded state must expose banner period groups for version $version');
          for (final grouped in state.items) {
            final from = DateFormat(BannerVersionHistoryBloc.periodDateFormat).parse(grouped.from);
            final until = DateFormat(BannerVersionHistoryBloc.periodDateFormat).parse(grouped.until);
            expect(until.isAfter(from), isTrue, reason: 'Banner period must end after it begins (from=${grouped.from}, until=${grouped.until})');
            expect(grouped.items, isNotEmpty, reason: 'Banner period group must contain at least one item (from=${grouped.from})');

            final keys = grouped.items.map((e) => e.key).toList();
            expect(keys.toSet().length == keys.length, isTrue, reason: 'Item keys within a banner period group must be unique (from=${grouped.from})');

            for (final group in grouped.items) {
              checkItemKeyAndImage(group.key, group.image);
              expect(group.rarity, greaterThanOrEqualTo(4), reason: 'Banner item rarity must be >= 4 (key=${group.key})');
              expect(validItemTypes.contains(group.type), isTrue, reason: 'Banner item type must be character or weapon, got ${group.type} (key=${group.key})');
            }
          }
      }
    }

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
      errors: () => [predicate<ArgumentError>((e) => e.name == 'version')],
    );
  });
}
