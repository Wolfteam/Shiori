import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/double_extensions.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../../mocks.mocks.dart';

void main() {
  late LocaleService _localeService;
  late SettingsService _settingsService;
  late GenshinService _genshinService;
  late List<double> _versions;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _settingsService = MockSettingsService();
    when(_settingsService.language).thenReturn(AppLanguageType.english);
    when(_settingsService.showCharacterDetails).thenReturn(true);
    _localeService = LocaleServiceImpl(_settingsService);
    _genshinService = GenshinServiceImpl(_localeService);

    return Future(() async {
      await _genshinService.init(AppLanguageType.english);
      _versions = _genshinService.getBannerHistoryVersions(SortDirectionType.asc);
    });
  });

  test(
    'Initial state',
    () => expect(ChartElementsBloc(_genshinService).state, const ChartElementsState.loading()),
  );

  group('Init', () {
    blocTest<ChartElementsBloc, ChartElementsState>(
      'emits loaded state',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 10))
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 8)),
      expect: () {
        final firstLastVersion = _versions.first + 10 * gameVersionIncrementsBy;
        final secondLastVersion = _versions.first + 8 * gameVersionIncrementsBy;
        return [
          ChartElementsState.loaded(
            elements: _genshinService.getElementsForCharts(_versions.first, firstLastVersion),
            filteredElements: _genshinService.getElementsForCharts(_versions.first, firstLastVersion),
            firstVersion: _versions.first,
            lastVersion: firstLastVersion,
            maxNumberOfColumns: 10,
            canGoToFirstPage: false,
            canGoToLastPage: true,
            canGoToNextPage: true,
            canGoToPreviousPage: false,
          ),
          ChartElementsState.loaded(
            elements: _genshinService.getElementsForCharts(_versions.first, secondLastVersion),
            filteredElements: _genshinService.getElementsForCharts(_versions.first, secondLastVersion),
            firstVersion: _versions.first,
            lastVersion: secondLastVersion,
            maxNumberOfColumns: 8,
            canGoToFirstPage: false,
            canGoToLastPage: true,
            canGoToNextPage: true,
            canGoToPreviousPage: false,
          ),
        ];
      },
    );

    blocTest<ChartElementsBloc, ChartElementsState>(
      'loaded state does not change',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 5))
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 5)),
      skip: 1,
      expect: () => [],
    );

    blocTest<ChartElementsBloc, ChartElementsState>(
      'max number of columns is not valid',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc.add(const ChartElementsEvent.init(maxNumberOfColumns: 0)),
      errors: () => [isA<Exception>()],
    );
  });

  group('Element selected', () {
    blocTest<ChartElementsBloc, ChartElementsState>(
      'electro and anemo were selected',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 4))
        ..add(const ChartElementsEvent.elementSelected(type: ElementType.electro))
        ..add(const ChartElementsEvent.elementSelected(type: ElementType.anemo)),
      skip: 2,
      expect: () {
        final fromVersion = _versions.first;
        final untilVersion = fromVersion + 4 * gameVersionIncrementsBy;
        final elements = _genshinService.getElementsForCharts(fromVersion, untilVersion);
        final filteredElements = elements.where((el) => el.type == ElementType.electro || el.type == ElementType.anemo).toList();
        return [
          ChartElementsState.loaded(
            firstVersion: fromVersion,
            lastVersion: untilVersion,
            filteredElements: filteredElements,
            elements: elements,
            selectedElementTypes: [ElementType.electro, ElementType.anemo],
            maxNumberOfColumns: 4,
            canGoToFirstPage: false,
            canGoToLastPage: true,
            canGoToNextPage: true,
            canGoToPreviousPage: false,
          ),
        ];
      },
    );

    blocTest<ChartElementsBloc, ChartElementsState>(
      'electro was selected and deselected',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 4))
        ..add(const ChartElementsEvent.elementSelected(type: ElementType.electro))
        ..add(const ChartElementsEvent.elementSelected(type: ElementType.electro)),
      skip: 2,
      expect: () {
        final fromVersion = _versions.first;
        final untilVersion = fromVersion + 4 * gameVersionIncrementsBy;
        final elements = _genshinService.getElementsForCharts(fromVersion, untilVersion);
        return [
          ChartElementsState.loaded(
            firstVersion: fromVersion,
            lastVersion: untilVersion,
            filteredElements: elements,
            elements: elements,
            maxNumberOfColumns: 4,
            canGoToFirstPage: false,
            canGoToLastPage: true,
            canGoToNextPage: true,
            canGoToPreviousPage: false,
          ),
        ];
      },
    );
  });

  group('Go to next page', () {
    blocTest<ChartElementsBloc, ChartElementsState>(
      'next page exists',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 4))
        ..add(const ChartElementsEvent.goToNextPage()),
      skip: 1,
      expect: () {
        final fromVersion = (_versions.first + gameVersionIncrementsBy).truncateToDecimalPlaces();
        final untilVersion = fromVersion + 4 * gameVersionIncrementsBy;
        final elements = _genshinService.getElementsForCharts(fromVersion, untilVersion);
        return [
          ChartElementsState.loaded(
            firstVersion: fromVersion,
            lastVersion: untilVersion,
            filteredElements: elements,
            elements: elements,
            maxNumberOfColumns: 4,
            canGoToFirstPage: true,
            canGoToLastPage: true,
            canGoToNextPage: true,
            canGoToPreviousPage: true,
          ),
        ];
      },
    );

    blocTest<ChartElementsBloc, ChartElementsState>(
      'next page does not exist',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 10000))
        ..add(const ChartElementsEvent.goToNextPage()),
      skip: 1,
      errors: () => [isA<Exception>()],
    );

    blocTest<ChartElementsBloc, ChartElementsState>(
      'state is not valid',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc.add(const ChartElementsEvent.goToNextPage()),
      errors: () => [isA<Exception>()],
    );
  });

  group('Go to previous page', () {
    blocTest<ChartElementsBloc, ChartElementsState>(
      'previous page exists',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 4))
        ..add(const ChartElementsEvent.goToNextPage())
        ..add(const ChartElementsEvent.goToPreviousPage()),
      skip: 2,
      expect: () {
        final fromVersion = _versions.first;
        final untilVersion = fromVersion + 4 * gameVersionIncrementsBy;
        final elements = _genshinService.getElementsForCharts(fromVersion, untilVersion);
        return [
          ChartElementsState.loaded(
            firstVersion: fromVersion,
            lastVersion: untilVersion,
            filteredElements: elements,
            elements: elements,
            maxNumberOfColumns: 4,
            canGoToFirstPage: false,
            canGoToLastPage: true,
            canGoToNextPage: true,
            canGoToPreviousPage: false,
          ),
        ];
      },
    );

    blocTest<ChartElementsBloc, ChartElementsState>(
      'previous page does not exist',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 1))
        ..add(const ChartElementsEvent.goToPreviousPage()),
      skip: 1,
      errors: () => [isA<Exception>()],
    );

    blocTest<ChartElementsBloc, ChartElementsState>(
      'state is not valid',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc.add(const ChartElementsEvent.goToPreviousPage()),
      errors: () => [isA<Exception>()],
    );
  });

  group('Go to first page', () {
    blocTest<ChartElementsBloc, ChartElementsState>(
      'first page exists',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 4))
        ..add(const ChartElementsEvent.goToNextPage())
        ..add(const ChartElementsEvent.goToNextPage())
        ..add(const ChartElementsEvent.goToFirstPage()),
      skip: 3,
      expect: () {
        final fromVersion = _versions.first;
        final untilVersion = fromVersion + 4 * gameVersionIncrementsBy;
        final elements = _genshinService.getElementsForCharts(fromVersion, untilVersion);
        return [
          ChartElementsState.loaded(
            firstVersion: fromVersion,
            lastVersion: untilVersion,
            filteredElements: elements,
            elements: elements,
            maxNumberOfColumns: 4,
            canGoToFirstPage: false,
            canGoToLastPage: true,
            canGoToNextPage: true,
            canGoToPreviousPage: false,
          ),
        ];
      },
    );

    blocTest<ChartElementsBloc, ChartElementsState>(
      'already on first page',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 1))
        ..add(const ChartElementsEvent.goToFirstPage()),
      skip: 1,
      errors: () => [isA<Exception>()],
    );

    blocTest<ChartElementsBloc, ChartElementsState>(
      'state is not valid',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc.add(const ChartElementsEvent.goToFirstPage()),
      errors: () => [isA<Exception>()],
    );
  });

  group('Go to last page', () {
    blocTest<ChartElementsBloc, ChartElementsState>(
      'last page exists',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 4))
        ..add(const ChartElementsEvent.goToLastPage()),
      skip: 1,
      expect: () {
        final fromVersion = _versions.last - 4 * gameVersionIncrementsBy;
        final untilVersion = _versions.last;
        final elements = _genshinService.getElementsForCharts(fromVersion, untilVersion);
        return [
          ChartElementsState.loaded(
            firstVersion: fromVersion,
            lastVersion: untilVersion,
            filteredElements: elements,
            elements: elements,
            maxNumberOfColumns: 4,
            canGoToFirstPage: true,
            canGoToLastPage: false,
            canGoToNextPage: false,
            canGoToPreviousPage: true,
          ),
        ];
      },
    );

    blocTest<ChartElementsBloc, ChartElementsState>(
      'already on last page',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 10000))
        ..add(const ChartElementsEvent.goToLastPage()),
      skip: 1,
      errors: () => [isA<Exception>()],
    );

    blocTest<ChartElementsBloc, ChartElementsState>(
      'state is not valid',
      build: () => ChartElementsBloc(_genshinService),
      act: (bloc) => bloc.add(const ChartElementsEvent.goToLastPage()),
      errors: () => [isA<Exception>()],
    );
  });
}
