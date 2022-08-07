import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

void main() {
  late GenshinService _genshinService;
  late TelemetryService _telemetryService;

  final List<BannerHistoryItemModel> _characterBanners = [];
  final List<BannerHistoryItemModel> _weaponBanners = [];

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    return Future(() async {
      _telemetryService = MockTelemetryService();
      final settingsService = MockSettingsService();
      when(settingsService.language).thenReturn(AppLanguageType.english);

      final resourceService = getResourceService(settingsService);
      final localeService = LocaleServiceImpl(settingsService);
      _genshinService = GenshinServiceImpl(resourceService, localeService);

      await _genshinService.init(settingsService.language);

      _characterBanners.addAll(_genshinService.bannerHistory.getBannerHistory(BannerHistoryItemType.character));
      _weaponBanners.addAll(_genshinService.bannerHistory.getBannerHistory(BannerHistoryItemType.weapon));
    });
  });

  void checkBannerItem(BannerHistoryItemModel banner, BannerHistoryItemType expectedType) {
    checkItemKeyAndImage(banner.key, banner.image);
    checkTranslation(banner.name, canBeNull: false);
    expect(banner.rarity >= 4, isTrue);
    expect(banner.type, expectedType);
    expect(banner.versions, isNotEmpty);
    for (final version in banner.versions) {
      if (version.released) {
        expect(version.number, isNull);
        expect(version.version >= 1, isTrue);
      } else if (version.number == 0) {
        expect(version.released, isFalse);
      } else {
        expect(version.released, isFalse);
        expect(version.number! >= 1, isTrue);
      }
    }
  }

  void checkCommonState(
    BannerHistoryState state, {
    BannerHistoryItemType type = BannerHistoryItemType.character,
    BannerHistorySortType sortType = BannerHistorySortType.versionAsc,
    List<String> selectedItemKeys = const [],
    List<double> selectedVersions = const [],
  }) {
    state.map(
      initial: (state) {
        expect(state.type, type);
        expect(state.versions, isNotEmpty);
        expect(state.versions.length, state.versions.toSet().length);
        expect(state.banners.isNotEmpty, isTrue);
        for (final banner in state.banners) {
          checkBannerItem(banner, type);
        }
        expect(state.sortType, sortType);
        expect(state.selectedItemKeys, selectedItemKeys);
        expect(state.selectedVersions, selectedVersions);

        if (selectedItemKeys.isNotEmpty) {
          expect(state.banners.length, state.selectedItemKeys.length);
        }

        if (selectedVersions.isNotEmpty) {
          final versions = state.banners
              .expand((el) => el.versions)
              .where((e) => e.released && selectedVersions.contains(e.version))
              .map((e) => e.version)
              .toSet()
              .toList();
          expect(versions.length, selectedVersions.length);
        }

        final maxCount = max(_characterBanners.length, _weaponBanners.length);
        expect(state.maxNumberOfItems, maxCount);
      },
    );
  }

  test(
    'Initial state',
    () => expect(
      BannerHistoryBloc(_genshinService, _telemetryService).state,
      const BannerHistoryState.initial(
        type: BannerHistoryItemType.character,
        sortType: BannerHistorySortType.versionAsc,
        banners: [],
        versions: [],
        selectedItemKeys: [],
        selectedVersions: [],
        maxNumberOfItems: 0,
      ),
    ),
  );

  blocTest<BannerHistoryBloc, BannerHistoryState>(
    'Init',
    build: () => BannerHistoryBloc(_genshinService, _telemetryService),
    act: (bloc) => bloc.add(const BannerHistoryEvent.init()),
    verify: (bloc) => checkCommonState(bloc.state),
  );

  group('Type changed', () {
    blocTest<BannerHistoryBloc, BannerHistoryState>(
      'weapon selected',
      build: () => BannerHistoryBloc(_genshinService, _telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryEvent.init())
        ..add(const BannerHistoryEvent.typeChanged(type: BannerHistoryItemType.weapon)),
      verify: (bloc) => checkCommonState(bloc.state, type: BannerHistoryItemType.weapon),
    );

    blocTest<BannerHistoryBloc, BannerHistoryState>(
      'no state change',
      build: () => BannerHistoryBloc(_genshinService, _telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryEvent.init())
        ..add(const BannerHistoryEvent.typeChanged(type: BannerHistoryItemType.character)),
      skip: 1,
      expect: () => [],
    );
  });

  group('Sort changed', () {
    blocTest<BannerHistoryBloc, BannerHistoryState>(
      'sorted by name desc.',
      build: () => BannerHistoryBloc(_genshinService, _telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryEvent.init())
        ..add(const BannerHistoryEvent.sortTypeChanged(type: BannerHistorySortType.nameDesc)),
      verify: (bloc) => bloc.state.map(
        initial: (state) {
          checkCommonState(bloc.state, sortType: BannerHistorySortType.nameDesc);
          final names = state.banners.map((e) => e.name).toList();
          final sorted = [...names]..sort((x, y) => y.compareTo(x));
          expect(names, sorted);
        },
      ),
    );

    blocTest<BannerHistoryBloc, BannerHistoryState>(
      'sorted by version desc.',
      build: () => BannerHistoryBloc(_genshinService, _telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryEvent.init())
        ..add(const BannerHistoryEvent.sortTypeChanged(type: BannerHistorySortType.versionDesc)),
      verify: (bloc) => bloc.state.map(
        initial: (state) {
          checkCommonState(bloc.state, sortType: BannerHistorySortType.versionDesc);
          final versions = state.versions.map((e) => e).toList();
          final sorted = [...versions]..sort((x, y) => y.compareTo(x));
          expect(versions, sorted);
        },
      ),
    );

    blocTest<BannerHistoryBloc, BannerHistoryState>(
      'no state change',
      build: () => BannerHistoryBloc(_genshinService, _telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryEvent.init())
        ..add(const BannerHistoryEvent.sortTypeChanged(type: BannerHistorySortType.versionAsc)),
      skip: 1,
      expect: () => [],
    );
  });

  group('Version selected', () {
    blocTest<BannerHistoryBloc, BannerHistoryState>(
      'to 2.5 and 2.4',
      build: () => BannerHistoryBloc(_genshinService, _telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryEvent.init())
        ..add(const BannerHistoryEvent.versionSelected(version: 2.5))
        ..add(const BannerHistoryEvent.versionSelected(version: 2.4)),
      verify: (bloc) => checkCommonState(bloc.state, selectedVersions: [2.5, 2.4]),
    );

    blocTest<BannerHistoryBloc, BannerHistoryState>(
      'to 2.5 but it gets deselected',
      build: () => BannerHistoryBloc(_genshinService, _telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryEvent.init())
        ..add(const BannerHistoryEvent.versionSelected(version: 2.5))
        ..add(const BannerHistoryEvent.versionSelected(version: 2.5)),
      verify: (bloc) => checkCommonState(bloc.state),
    );
  });

  group('Item selected', () {
    blocTest<BannerHistoryBloc, BannerHistoryState>(
      'to 2.5 but it gets deselected',
      build: () => BannerHistoryBloc(_genshinService, _telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryEvent.init())
        ..add(const BannerHistoryEvent.itemsSelected(keys: ['keqing', 'xiangling'])),
      verify: (bloc) => checkCommonState(bloc.state, selectedItemKeys: ['keqing', 'xiangling']),
    );

    blocTest<BannerHistoryBloc, BannerHistoryState>(
      'empty array',
      build: () => BannerHistoryBloc(_genshinService, _telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryEvent.init())
        ..add(const BannerHistoryEvent.itemsSelected(keys: [])),
      verify: (bloc) => checkCommonState(bloc.state, selectedItemKeys: []),
    );
  });

  blocTest<BannerHistoryBloc, BannerHistoryState>(
    'Items for search',
    build: () => BannerHistoryBloc(_genshinService, _telemetryService),
    act: (bloc) => bloc
      ..add(const BannerHistoryEvent.init())
      ..add(const BannerHistoryEvent.sortTypeChanged(type: BannerHistorySortType.nameDesc))
      ..add(const BannerHistoryEvent.typeChanged(type: BannerHistoryItemType.weapon))
      ..add(const BannerHistoryEvent.versionSelected(version: 1.1)),
    verify: (bloc) {
      checkCommonState(bloc.state, type: BannerHistoryItemType.weapon, sortType: BannerHistorySortType.nameDesc, selectedVersions: [1.1]);
      final itemsForSearch = bloc.getItemsForSearch();
      final banners = _genshinService.bannerHistory.getBanners(bloc.state.selectedVersions.first);
      final expectedCount = banners.where((el) => el.type == BannerHistoryItemType.weapon).expand((el) => el.items).map((e) => e.key).toSet().length;
      final expectedItems = bloc.state.banners.map((e) => e.key).toSet().toList();
      expect(expectedCount, 14);
      expect(expectedItems.length, expectedCount);
      for (final key in expectedItems) {
        expect(itemsForSearch.any((el) => el.key == key), isTrue);
      }
    },
  );
}
