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

import '../../../mocks.mocks.dart';

void main() {
  late LocaleService _localeService;
  late SettingsService _settingsService;
  late GenshinService _genshinService;
  late List<ChartAscensionStatModel> _charStats;
  late List<ChartAscensionStatModel> _weaponStats;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _settingsService = MockSettingsService();
    when(_settingsService.language).thenReturn(AppLanguageType.english);
    when(_settingsService.showCharacterDetails).thenReturn(true);
    _localeService = LocaleServiceImpl(_settingsService);
    _genshinService = GenshinServiceImpl(_localeService);

    return Future(() async {
      await _genshinService.init(AppLanguageType.english);
      _charStats = _genshinService.getItemAscensionStatsForCharts(ItemType.character);
      _weaponStats = _genshinService.getItemAscensionStatsForCharts(ItemType.weapon);
    });
  });

  test(
    'Initial state',
    () => expect(
      ChartAscensionStatsBloc(_genshinService).state,
      const ChartAscensionStatsState.loading(),
    ),
  );

  group('Init', () {
    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'emits loaded state',
      build: () => ChartAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 10))
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.weapon, maxNumberOfColumns: 8)),
      expect: () => [
        ChartAscensionStatsState.loaded(
          maxCount: _charStats.map((e) => e.quantity).reduce(max),
          ascensionStats: _charStats.take(10).toList(),
          maxNumberOfColumns: 10,
          itemType: ItemType.character,
          canGoToFirstPage: false,
          canGoToLastPage: true,
          canGoToNextPage: true,
          canGoToPreviousPage: false,
          currentPage: 1,
          maxPage: (_charStats.length / 10).ceil(),
        ),
        ChartAscensionStatsState.loaded(
          maxCount: _weaponStats.map((e) => e.quantity).reduce(max),
          ascensionStats: _weaponStats.take(8).toList(),
          maxNumberOfColumns: 8,
          itemType: ItemType.weapon,
          canGoToFirstPage: false,
          canGoToLastPage: true,
          canGoToNextPage: true,
          canGoToPreviousPage: false,
          currentPage: 1,
          maxPage: (_weaponStats.length / 8).ceil(),
        ),
      ],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'loaded state does not change',
      build: () => ChartAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 10))
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 10)),
      skip: 1,
      expect: () => [],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'invalid item type',
      build: () => ChartAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.artifact, maxNumberOfColumns: 10))
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.material, maxNumberOfColumns: 10)),
      errors: () => [isA<Exception>(), isA<Exception>()],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'max number of columns is not valid',
      build: () => ChartAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc.add(const ChartAscensionStatsEvent.init(type: ItemType.material, maxNumberOfColumns: 0)),
      errors: () => [isA<Exception>()],
    );
  });

  group('Go to next page', () {
    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'next page exists',
      build: () => ChartAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.weapon, maxNumberOfColumns: 4))
        ..add(const ChartAscensionStatsEvent.goToNextPage()),
      skip: 1,
      expect: () => [
        ChartAscensionStatsState.loaded(
          maxCount: _weaponStats.map((e) => e.quantity).reduce(max),
          ascensionStats: _weaponStats.skip(4).take(4).toList(),
          maxNumberOfColumns: 4,
          itemType: ItemType.weapon,
          canGoToFirstPage: true,
          canGoToLastPage: true,
          canGoToNextPage: true,
          canGoToPreviousPage: true,
          currentPage: 2,
          maxPage: (_weaponStats.length / 4).ceil(),
        ),
      ],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'next page does not exist',
      build: () => ChartAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 10000))
        ..add(const ChartAscensionStatsEvent.goToNextPage()),
      skip: 1,
      errors: () => [isA<Exception>()],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'state is not valid',
      build: () => ChartAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc.add(const ChartAscensionStatsEvent.goToNextPage()),
      errors: () => [isA<Exception>()],
    );
  });

  group('Go to previous page', () {
    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'previous page exists',
      build: () => ChartAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.weapon, maxNumberOfColumns: 4))
        ..add(const ChartAscensionStatsEvent.goToNextPage())
        ..add(const ChartAscensionStatsEvent.goToPreviousPage()),
      skip: 2,
      expect: () => [
        ChartAscensionStatsState.loaded(
          maxCount: _weaponStats.map((e) => e.quantity).reduce(max),
          ascensionStats: _weaponStats.take(4).toList(),
          maxNumberOfColumns: 4,
          itemType: ItemType.weapon,
          canGoToFirstPage: false,
          canGoToLastPage: true,
          canGoToNextPage: true,
          canGoToPreviousPage: false,
          currentPage: 1,
          maxPage: (_weaponStats.length / 4).ceil(),
        ),
      ],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'previous page does not exist',
      build: () => ChartAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 1))
        ..add(const ChartAscensionStatsEvent.goToPreviousPage()),
      skip: 1,
      errors: () => [isA<Exception>()],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'state is not valid',
      build: () => ChartAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc.add(const ChartAscensionStatsEvent.goToPreviousPage()),
      errors: () => [isA<Exception>()],
    );
  });

  group('Go to first page', () {
    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'first page exists',
      build: () => ChartAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 4))
        ..add(const ChartAscensionStatsEvent.goToNextPage())
        ..add(const ChartAscensionStatsEvent.goToNextPage())
        ..add(const ChartAscensionStatsEvent.goToFirstPage()),
      skip: 3,
      expect: () => [
        ChartAscensionStatsState.loaded(
          maxCount: _charStats.map((e) => e.quantity).reduce(max),
          ascensionStats: _charStats.take(4).toList(),
          maxNumberOfColumns: 4,
          itemType: ItemType.character,
          canGoToFirstPage: false,
          canGoToLastPage: true,
          canGoToNextPage: true,
          canGoToPreviousPage: false,
          currentPage: 1,
          maxPage: (_charStats.length / 4).ceil(),
        ),
      ],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'already on first page',
      build: () => ChartAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 1))
        ..add(const ChartAscensionStatsEvent.goToFirstPage()),
      skip: 1,
      errors: () => [isA<Exception>()],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'state is not valid',
      build: () => ChartAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc.add(const ChartAscensionStatsEvent.goToFirstPage()),
      errors: () => [isA<Exception>()],
    );
  });

  group('Go to last page', () {
    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'last page exists',
      build: () => ChartAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 4))
        ..add(const ChartAscensionStatsEvent.goToLastPage()),
      skip: 1,
      expect: () {
        final maxPage = (_charStats.length / 4).ceil();
        return [
          ChartAscensionStatsState.loaded(
            maxCount: _charStats.map((e) => e.quantity).reduce(max),
            ascensionStats: _charStats.skip((maxPage - 1) * 4).take(4).toList(),
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
      build: () => ChartAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartAscensionStatsEvent.init(type: ItemType.character, maxNumberOfColumns: 10000))
        ..add(const ChartAscensionStatsEvent.goToLastPage()),
      skip: 1,
      errors: () => [isA<Exception>()],
    );

    blocTest<ChartAscensionStatsBloc, ChartAscensionStatsState>(
      'state is not valid',
      build: () => ChartAscensionStatsBloc(_genshinService),
      act: (bloc) => bloc.add(const ChartAscensionStatsEvent.goToLastPage()),
      errors: () => [isA<Exception>()],
    );
  });
}
