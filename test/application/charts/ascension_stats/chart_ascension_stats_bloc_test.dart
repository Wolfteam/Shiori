import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../../common.dart';
import '../../../mocks.mocks.dart';

void main() {
  late LocaleService localeService;
  late SettingsService settingsService;
  late GenshinService genshinService;
  late List<ChartAscensionStatModel> charStats;
  late List<ChartAscensionStatModel> weaponStats;

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
      charStats = genshinService.getItemAscensionStatsForCharts(ItemType.character);
      weaponStats = genshinService.getItemAscensionStatsForCharts(ItemType.weapon);
    });
  });

  test(
    'Initial state',
    () => expect(
      ChartAscensionStatsBloc(genshinService).state,
      const ChartAscensionStatsState.loading(),
    ),
  );

  group('Init', () {
    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'emits loaded state',
      build: () => ChartAscensionStatsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 10))
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.weapon, maxNumberOfColumns: 8)),
      expect: () => [
        ChartAscensionStatsState.loaded(
          maxCount: charStats.map((e) => e.quantity).reduce(max),
          ascensionStats: charStats.take(10).toList(),
          maxNumberOfColumns: 10,
          itemType: ItemType.character,
          canGoToFirstPage: false,
          canGoToLastPage: true,
          canGoToNextPage: true,
          canGoToPreviousPage: false,
          currentPage: 1,
          maxPage: (charStats.length / 10).ceil(),
        ),
        ChartAscensionStatsState.loaded(
          maxCount: weaponStats.map((e) => e.quantity).reduce(max),
          ascensionStats: weaponStats.take(8).toList(),
          maxNumberOfColumns: 8,
          itemType: ItemType.weapon,
          canGoToFirstPage: false,
          canGoToLastPage: true,
          canGoToNextPage: true,
          canGoToPreviousPage: false,
          currentPage: 1,
          maxPage: (weaponStats.length / 8).ceil(),
        ),
      ],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'loaded state does not change',
      build: () => ChartAscensionStatsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 10))
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 10)),
      skip: 1,
      expect: () => [],
    );

    const invalidTypes = [ItemType.artifact, ItemType.material];
    for (final type in invalidTypes) {
      blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
        'with type (${type.name}) which is not valid',
        build: () => ChartAscensionStatsBloc(genshinService),
        act: (bloc) => bloc..add(ChartAscensionStatsEvent.init(type: type, maxNumberOfColumns: 10)),
        errors: () => [isA<Exception>()],
      );
    }

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'max number of columns is not valid',
      build: () => ChartAscensionStatsBloc(genshinService),
      act: (bloc) => bloc.add(const ChartAscensionStatsEvent.init(type: ItemType.material, maxNumberOfColumns: 0)),
      errors: () => [isA<Exception>()],
    );
  });

  group('Go to next page', () {
    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'next page exists',
      build: () => ChartAscensionStatsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.weapon, maxNumberOfColumns: 4))
        ..add(const ChartAscensionStatsEvent.goToNextPage()),
      skip: 1,
      expect: () => [
        ChartAscensionStatsState.loaded(
          maxCount: weaponStats.map((e) => e.quantity).reduce(max),
          ascensionStats: weaponStats.skip(4).take(4).toList(),
          maxNumberOfColumns: 4,
          itemType: ItemType.weapon,
          canGoToFirstPage: true,
          canGoToLastPage: true,
          canGoToNextPage: true,
          canGoToPreviousPage: true,
          currentPage: 2,
          maxPage: (weaponStats.length / 4).ceil(),
        ),
      ],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'next page does not exist',
      build: () => ChartAscensionStatsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 10000))
        ..add(const ChartAscensionStatsEvent.goToNextPage()),
      skip: 1,
      errors: () => [isA<Exception>()],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'state is not valid',
      build: () => ChartAscensionStatsBloc(genshinService),
      act: (bloc) => bloc.add(const ChartAscensionStatsEvent.goToNextPage()),
      errors: () => [isA<Exception>()],
    );
  });

  group('Go to previous page', () {
    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'previous page exists',
      build: () => ChartAscensionStatsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.weapon, maxNumberOfColumns: 4))
        ..add(const ChartAscensionStatsEvent.goToNextPage())
        ..add(const ChartAscensionStatsEvent.goToPreviousPage()),
      skip: 2,
      expect: () => [
        ChartAscensionStatsState.loaded(
          maxCount: weaponStats.map((e) => e.quantity).reduce(max),
          ascensionStats: weaponStats.take(4).toList(),
          maxNumberOfColumns: 4,
          itemType: ItemType.weapon,
          canGoToFirstPage: false,
          canGoToLastPage: true,
          canGoToNextPage: true,
          canGoToPreviousPage: false,
          currentPage: 1,
          maxPage: (weaponStats.length / 4).ceil(),
        ),
      ],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'previous page does not exist',
      build: () => ChartAscensionStatsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 1))
        ..add(const ChartAscensionStatsEvent.goToPreviousPage()),
      skip: 1,
      errors: () => [isA<Exception>()],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'state is not valid',
      build: () => ChartAscensionStatsBloc(genshinService),
      act: (bloc) => bloc.add(const ChartAscensionStatsEvent.goToPreviousPage()),
      errors: () => [isA<Exception>()],
    );
  });

  group('Go to first page', () {
    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'first page exists',
      build: () => ChartAscensionStatsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 4))
        ..add(const ChartAscensionStatsEvent.goToNextPage())
        ..add(const ChartAscensionStatsEvent.goToNextPage())
        ..add(const ChartAscensionStatsEvent.goToFirstPage()),
      skip: 3,
      expect: () => [
        ChartAscensionStatsState.loaded(
          maxCount: charStats.map((e) => e.quantity).reduce(max),
          ascensionStats: charStats.take(4).toList(),
          maxNumberOfColumns: 4,
          itemType: ItemType.character,
          canGoToFirstPage: false,
          canGoToLastPage: true,
          canGoToNextPage: true,
          canGoToPreviousPage: false,
          currentPage: 1,
          maxPage: (charStats.length / 4).ceil(),
        ),
      ],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'already on first page',
      build: () => ChartAscensionStatsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 1))
        ..add(const ChartAscensionStatsEvent.goToFirstPage()),
      skip: 1,
      errors: () => [isA<Exception>()],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'state is not valid',
      build: () => ChartAscensionStatsBloc(genshinService),
      act: (bloc) => bloc.add(const ChartAscensionStatsEvent.goToFirstPage()),
      errors: () => [isA<Exception>()],
    );
  });

  group('Go to last page', () {
    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'last page exists',
      build: () => ChartAscensionStatsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 4))
        ..add(const ChartAscensionStatsEvent.goToLastPage()),
      skip: 1,
      expect: () {
        final maxPage = (charStats.length / 4).ceil();
        return [
          ChartAscensionStatsState.loaded(
            maxCount: charStats.map((e) => e.quantity).reduce(max),
            ascensionStats: charStats.skip((maxPage - 1) * 4).take(4).toList(),
            maxNumberOfColumns: 4,
            itemType: ItemType.character,
            canGoToFirstPage: true,
            canGoToLastPage: false,
            canGoToNextPage: false,
            canGoToPreviousPage: true,
            currentPage: maxPage,
            maxPage: maxPage,
          ),
        ];
      },
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'already on last page',
      build: () => ChartAscensionStatsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 10000))
        ..add(const ChartAscensionStatsEvent.goToLastPage()),
      skip: 1,
      errors: () => [isA<Exception>()],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'state is not valid',
      build: () => ChartAscensionStatsBloc(genshinService),
      act: (bloc) => bloc.add(const ChartAscensionStatsEvent.goToLastPage()),
      errors: () => [isA<Exception>()],
    );
  });
}
