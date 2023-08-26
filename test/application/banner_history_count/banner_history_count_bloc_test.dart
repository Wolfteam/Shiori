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
  late GenshinService genshinService;
  late TelemetryService telemetryService;

  final List<BannerHistoryItemModel> characterBanners = [];
  final List<BannerHistoryItemModel> weaponBanners = [];

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

      characterBanners.addAll(genshinService.bannerHistory.getBannerHistory(BannerHistoryItemType.character));
      weaponBanners.addAll(genshinService.bannerHistory.getBannerHistory(BannerHistoryItemType.weapon));
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
    BannerHistoryCountState state, {
    BannerHistoryItemType type = BannerHistoryItemType.character,
    BannerHistorySortType sortType = BannerHistorySortType.versionAsc,
    List<String> selectedItemKeys = const [],
    List<double> selectedVersions = const [],
    bool bannersAreNotEmpty = true,
  }) {
    expect(state.type, type);
    expect(state.versions, isNotEmpty);
    expect(state.versions.length, state.versions.toSet().length);
    expect(bannersAreNotEmpty ? state.banners.isNotEmpty : state.banners.isEmpty, isTrue);
    for (final banner in state.banners) {
      checkBannerItem(banner, type);
    }
    expect(state.sortType, sortType);
    expect(state.selectedItemKeys, selectedItemKeys);
    expect(state.selectedVersions, selectedVersions);

    if (selectedItemKeys.isNotEmpty && bannersAreNotEmpty) {
      expect(state.banners.length, state.selectedItemKeys.length);
    }

    if (selectedVersions.isNotEmpty && bannersAreNotEmpty) {
      final versions = state.banners
          .expand((el) => el.versions)
          .where((e) => e.released && selectedVersions.contains(e.version))
          .map((e) => e.version)
          .toSet()
          .toList();
      expect(versions.length, selectedVersions.length);
    }

    final maxCount = max(characterBanners.length, weaponBanners.length);
    expect(state.maxNumberOfItems, maxCount);
  }

  test(
    'Initial state',
    () => expect(
      BannerHistoryCountBloc(genshinService, telemetryService).state,
      const BannerHistoryCountState.initial(
        type: BannerHistoryItemType.character,
        sortType: BannerHistorySortType.versionAsc,
        banners: [],
        versions: [],
        maxNumberOfItems: 0,
      ),
    ),
  );

  blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
    'Init',
    build: () => BannerHistoryCountBloc(genshinService, telemetryService),
    act: (bloc) => bloc.add(const BannerHistoryCountEvent.init()),
    verify: (bloc) => checkCommonState(bloc.state),
  );

  blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
    'Characters must exist in banner',
    build: () => BannerHistoryCountBloc(genshinService, telemetryService),
    act: (bloc) => bloc.add(const BannerHistoryCountEvent.init()),
    verify: (bloc) {
      final charsWithoutBanner = ['aloy', 'mona', 'qiqi', 'amber', 'kaeya', 'lisa', 'diluc', 'jean'];
      final allCharsCount = genshinService.characters
          .getCharactersForCard()
          .where((el) => !el.isComingSoon && !el.key.startsWith('traveler') && !charsWithoutBanner.contains(el.key))
          .length;
      final bannerCount = bloc.state.banners.map((e) => e.key).length;
      expect(allCharsCount, bannerCount);
    },
  );

  group('Type changed', () {
    blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
      'weapon selected',
      build: () => BannerHistoryCountBloc(genshinService, telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryCountEvent.init())
        ..add(const BannerHistoryCountEvent.typeChanged(type: BannerHistoryItemType.weapon)),
      verify: (bloc) => checkCommonState(bloc.state, type: BannerHistoryItemType.weapon),
    );

    blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
      'no state change',
      build: () => BannerHistoryCountBloc(genshinService, telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryCountEvent.init())
        ..add(const BannerHistoryCountEvent.typeChanged(type: BannerHistoryItemType.character)),
      skip: 1,
      expect: () => [],
    );
  });

  group('Sort changed', () {
    blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
      'sorted by name desc.',
      build: () => BannerHistoryCountBloc(genshinService, telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryCountEvent.init())
        ..add(const BannerHistoryCountEvent.sortTypeChanged(type: BannerHistorySortType.nameDesc)),
      verify: (bloc) => bloc.state.map(
        initial: (state) {
          checkCommonState(bloc.state, sortType: BannerHistorySortType.nameDesc);
          final names = state.banners.map((e) => e.name).toList();
          final sorted = [...names]..sort((x, y) => y.compareTo(x));
          expect(names, sorted);
        },
      ),
    );

    blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
      'sorted by version desc.',
      build: () => BannerHistoryCountBloc(genshinService, telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryCountEvent.init())
        ..add(const BannerHistoryCountEvent.sortTypeChanged(type: BannerHistorySortType.versionDesc)),
      verify: (bloc) => bloc.state.map(
        initial: (state) {
          checkCommonState(bloc.state, sortType: BannerHistorySortType.versionDesc);
          final versions = state.versions.map((e) => e).toList();
          final sorted = [...versions]..sort((x, y) => y.compareTo(x));
          expect(versions, sorted);
        },
      ),
    );

    blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
      'no state change',
      build: () => BannerHistoryCountBloc(genshinService, telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryCountEvent.init())
        ..add(const BannerHistoryCountEvent.sortTypeChanged(type: BannerHistorySortType.versionAsc)),
      skip: 1,
      expect: () => [],
    );
  });

  group('Version selected', () {
    blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
      'to 2.5 and 2.4',
      build: () => BannerHistoryCountBloc(genshinService, telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryCountEvent.init())
        ..add(const BannerHistoryCountEvent.versionSelected(version: 2.5))
        ..add(const BannerHistoryCountEvent.versionSelected(version: 2.4)),
      verify: (bloc) => checkCommonState(bloc.state, selectedVersions: [2.5, 2.4]),
    );

    blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
      'to 2.5 but it gets deselected',
      build: () => BannerHistoryCountBloc(genshinService, telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryCountEvent.init())
        ..add(const BannerHistoryCountEvent.versionSelected(version: 2.5))
        ..add(const BannerHistoryCountEvent.versionSelected(version: 2.5)),
      verify: (bloc) => checkCommonState(bloc.state),
    );

    blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
      'items was previously selected and should be cleared after version change',
      build: () => BannerHistoryCountBloc(genshinService, telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryCountEvent.init())
        ..add(const BannerHistoryCountEvent.itemsSelected(keys: ['keqing']))
        ..add(const BannerHistoryCountEvent.versionSelected(version: 2.5)),
      verify: (bloc) => checkCommonState(bloc.state, selectedVersions: [2.5]),
    );

    blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
      'to 1.3, user did not select any item thus the banners should be kept',
      build: () => BannerHistoryCountBloc(genshinService, telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryCountEvent.init())
        ..add(const BannerHistoryCountEvent.versionSelected(version: 1.3))
        ..add(const BannerHistoryCountEvent.itemsSelected(keys: [])),
      verify: (bloc) {
        checkCommonState(bloc.state, selectedVersions: [1.3]);
        expect(bloc.state.banners.length, 12);
      },
    );

    blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
      'to 1.3, and user changes the banner type',
      build: () => BannerHistoryCountBloc(genshinService, telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryCountEvent.init())
        ..add(const BannerHistoryCountEvent.versionSelected(version: 1.3))
        ..add(const BannerHistoryCountEvent.typeChanged(type: BannerHistoryItemType.weapon)),
      verify: (bloc) {
        checkCommonState(bloc.state, type: BannerHistoryItemType.weapon, selectedVersions: [1.3]);
        expect(bloc.state.banners.length, 14);
      },
    );

    blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
      'to 1.3, user selects and deselects item key thus the items in the banners should be kept',
      build: () => BannerHistoryCountBloc(genshinService, telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryCountEvent.init())
        ..add(const BannerHistoryCountEvent.versionSelected(version: 1.3))
        ..add(const BannerHistoryCountEvent.itemsSelected(keys: ['keqing']))
        ..add(const BannerHistoryCountEvent.itemsSelected(keys: [])),
      verify: (bloc) {
        checkCommonState(bloc.state, selectedVersions: [1.3]);
        expect(bloc.state.banners.length, 12);
      },
    );

    blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
      'to 1.0, user selects item key which is not released on this version thus the banners are empty',
      build: () => BannerHistoryCountBloc(genshinService, telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryCountEvent.init())
        ..add(const BannerHistoryCountEvent.versionSelected(version: 1.0))
        ..add(const BannerHistoryCountEvent.itemsSelected(keys: ['keqing'])),
      verify: (bloc) {
        checkCommonState(bloc.state, selectedVersions: [1.0], selectedItemKeys: ['keqing'], bannersAreNotEmpty: false);
        expect(bloc.state.banners.length, 0);
      },
    );
  });

  group('Item selected', () {
    blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
      'to 2.5 but it gets deselected',
      build: () => BannerHistoryCountBloc(genshinService, telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryCountEvent.init())
        ..add(const BannerHistoryCountEvent.itemsSelected(keys: ['keqing', 'xiangling'])),
      verify: (bloc) => checkCommonState(bloc.state, selectedItemKeys: ['keqing', 'xiangling']),
    );

    blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
      'empty array',
      build: () => BannerHistoryCountBloc(genshinService, telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryCountEvent.init())
        ..add(const BannerHistoryCountEvent.itemsSelected(keys: [])),
      verify: (bloc) => checkCommonState(bloc.state, selectedItemKeys: []),
    );
  });

  blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
    'Items for search',
    build: () => BannerHistoryCountBloc(genshinService, telemetryService),
    act: (bloc) => bloc
      ..add(const BannerHistoryCountEvent.init())
      ..add(const BannerHistoryCountEvent.sortTypeChanged(type: BannerHistorySortType.nameDesc))
      ..add(const BannerHistoryCountEvent.typeChanged(type: BannerHistoryItemType.weapon))
      ..add(const BannerHistoryCountEvent.versionSelected(version: 1.1)),
    verify: (bloc) {
      checkCommonState(bloc.state, type: BannerHistoryItemType.weapon, sortType: BannerHistorySortType.nameDesc, selectedVersions: [1.1]);
      final itemsForSearch = bloc.getItemsForSearch();
      final banners = genshinService.bannerHistory.getBanners(bloc.state.selectedVersions.first);
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
