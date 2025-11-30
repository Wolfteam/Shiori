import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/extensions/double_extensions.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../../common.dart';
import '../../../dummy_mocks.dart';
import '../../../mocks.mocks.dart';

void main() {
  late LocaleService localeService;
  late SettingsService settingsService;
  late GenshinService genshinService;
  late List<double> versions;

  setUpAll(() {
    provideDummyMocks();
    TestWidgetsFlutterBinding.ensureInitialized();
    settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    when(settingsService.showCharacterDetails).thenReturn(true);
    localeService = LocaleServiceImpl(settingsService);
    final resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);

    return Future(() async {
      await genshinService.init(AppLanguageType.english);
      versions = genshinService.bannerHistory.getBannerHistoryVersions(SortDirectionType.asc);
    });
  });

  test(
    'Initial state',
    () => expect(ChartElementsBloc(genshinService).state, const ChartElementsState.loading()),
  );

  group('Init', () {
    blocTest<ChartElementsBloc, ChartElementsState>(
      'emits loaded state',
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 10))
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 8)),
      expect: () {
        final firstLastVersion = versions.first + 10 * gameVersionIncrementsBy;
        final secondLastVersion = versions.first + 8 * gameVersionIncrementsBy;
        return [
          ChartElementsState.loaded(
            elements: genshinService.bannerHistory.getElementsForCharts(versions.first, firstLastVersion),
            filteredElements: genshinService.bannerHistory.getElementsForCharts(versions.first, firstLastVersion),
            firstVersion: versions.first,
            lastVersion: firstLastVersion,
            maxNumberOfColumns: 10,
            canGoToFirstPage: false,
            canGoToLastPage: true,
            canGoToNextPage: true,
            canGoToPreviousPage: false,
          ),
          ChartElementsState.loaded(
            elements: genshinService.bannerHistory.getElementsForCharts(versions.first, secondLastVersion),
            filteredElements: genshinService.bannerHistory.getElementsForCharts(versions.first, secondLastVersion),
            firstVersion: versions.first,
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
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 5))
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 5)),
      skip: 1,
      expect: () => [],
    );

    blocTest<ChartElementsBloc, ChartElementsState>(
      'max number of columns is not valid',
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc.add(const ChartElementsEvent.init(maxNumberOfColumns: 0)),
      errors: () => [predicate<RangeError>((e) => e.name == 'maxNumberOfColumns')],
    );
  });

  group('Element selected', () {
    blocTest<ChartElementsBloc, ChartElementsState>(
      'electro and anemo were selected',
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 4))
        ..add(const ChartElementsEvent.elementSelected(type: ElementType.electro))
        ..add(const ChartElementsEvent.elementSelected(type: ElementType.anemo)),
      skip: 2,
      expect: () {
        final fromVersion = versions.first;
        final untilVersion = fromVersion + 4 * gameVersionIncrementsBy;
        final elements = genshinService.bannerHistory.getElementsForCharts(fromVersion, untilVersion);
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
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 4))
        ..add(const ChartElementsEvent.elementSelected(type: ElementType.electro))
        ..add(const ChartElementsEvent.elementSelected(type: ElementType.electro)),
      skip: 2,
      expect: () {
        final fromVersion = versions.first;
        final untilVersion = fromVersion + 4 * gameVersionIncrementsBy;
        final elements = genshinService.bannerHistory.getElementsForCharts(fromVersion, untilVersion);
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
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 4))
        ..add(const ChartElementsEvent.goToNextPage()),
      skip: 1,
      expect: () {
        final fromVersion = (versions.first + gameVersionIncrementsBy).truncateToDecimalPlaces();
        final untilVersion = fromVersion + 4 * gameVersionIncrementsBy;
        final elements = genshinService.bannerHistory.getElementsForCharts(fromVersion, untilVersion);
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
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 10000))
        ..add(const ChartElementsEvent.goToNextPage()),
      skip: 1,
      errors: () => [predicate<PaginationError>((e) => e.name == 'nextPage')],
    );

    blocTest<ChartElementsBloc, ChartElementsState>(
      'state is not valid',
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc.add(const ChartElementsEvent.goToNextPage()),
      errors: () => [isA<InvalidStateError>()],
    );
  });

  group('Go to previous page', () {
    blocTest<ChartElementsBloc, ChartElementsState>(
      'previous page exists',
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 4))
        ..add(const ChartElementsEvent.goToNextPage())
        ..add(const ChartElementsEvent.goToPreviousPage()),
      skip: 2,
      expect: () {
        final fromVersion = versions.first;
        final untilVersion = fromVersion + 4 * gameVersionIncrementsBy;
        final elements = genshinService.bannerHistory.getElementsForCharts(fromVersion, untilVersion);
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
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 1))
        ..add(const ChartElementsEvent.goToPreviousPage()),
      skip: 1,
      errors: () => [predicate<PaginationError>((e) => e.name == 'previousPage')],
    );

    blocTest<ChartElementsBloc, ChartElementsState>(
      'state is not valid',
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc.add(const ChartElementsEvent.goToPreviousPage()),
      errors: () => [isA<InvalidStateError>()],
    );
  });

  group('Go to first page', () {
    blocTest<ChartElementsBloc, ChartElementsState>(
      'first page exists',
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 4))
        ..add(const ChartElementsEvent.goToNextPage())
        ..add(const ChartElementsEvent.goToNextPage())
        ..add(const ChartElementsEvent.goToFirstPage()),
      skip: 3,
      expect: () {
        final fromVersion = versions.first;
        final untilVersion = fromVersion + 4 * gameVersionIncrementsBy;
        final elements = genshinService.bannerHistory.getElementsForCharts(fromVersion, untilVersion);
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
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 1))
        ..add(const ChartElementsEvent.goToFirstPage()),
      skip: 1,
      errors: () => [predicate<ArgumentError>((e) => e.toString().contains('already'))],
    );

    blocTest<ChartElementsBloc, ChartElementsState>(
      'state is not valid',
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc.add(const ChartElementsEvent.goToFirstPage()),
      errors: () => [isA<InvalidStateError>()],
    );
  });

  group('Go to last page', () {
    blocTest<ChartElementsBloc, ChartElementsState>(
      'last page exists',
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 4))
        ..add(const ChartElementsEvent.goToLastPage()),
      skip: 1,
      expect: () {
        final fromVersion = versions.last - 4 * gameVersionIncrementsBy;
        final untilVersion = versions.last;
        final elements = genshinService.bannerHistory.getElementsForCharts(fromVersion, untilVersion);
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
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc
        ..add(const ChartElementsEvent.init(maxNumberOfColumns: 10000))
        ..add(const ChartElementsEvent.goToLastPage()),
      skip: 1,
      errors: () => [predicate<ArgumentError>((e) => e.name == 'newFirstVersion')],
    );

    blocTest<ChartElementsBloc, ChartElementsState>(
      'state is not valid',
      build: () => ChartElementsBloc(genshinService),
      act: (bloc) => bloc.add(const ChartElementsEvent.goToLastPage()),
      errors: () => [isA<InvalidStateError>()],
    );
  });
}
