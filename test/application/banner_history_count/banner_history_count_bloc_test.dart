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
    expect(banner.rarity, greaterThanOrEqualTo(4), reason: 'Banner item rarity must be >= 4 (key=${banner.key})');
    expect(banner.type, expectedType, reason: 'Banner item type must match requested $expectedType (key=${banner.key})');
    expect(banner.versions, isNotEmpty, reason: 'Banner item must appear in at least one version (key=${banner.key})');
    for (final version in banner.versions) {
      if (version.released) {
        expect(version.number, isNull, reason: 'A released banner version must carry no slot number (key=${banner.key})');
        expect(version.version, greaterThanOrEqualTo(1), reason: 'Released banner version must be >= 1 (key=${banner.key})');
      } else if (version.number == 0) {
        expect(version.released, isFalse, reason: 'A slot-0 version is a gap and must not be released (key=${banner.key})');
      } else {
        expect(version.released, isFalse, reason: 'An upcoming version must not be released (key=${banner.key})');
        expect(version.number! >= 1, isTrue, reason: 'Upcoming banner slot number must be >= 1 (key=${banner.key})');
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
    expect(state.type, type, reason: 'Loaded state banner type must be $type');
    expect(state.versions, isNotEmpty, reason: 'Loaded state must expose the list of game versions');
    expect(state.versions.length, state.versions.toSet().length, reason: 'Loaded state versions must be unique (no duplicates)');
    expect(bannersAreNotEmpty ? state.banners.isNotEmpty : state.banners.isEmpty, isTrue, reason: 'Loaded state banners emptiness must match bannersAreNotEmpty=$bannersAreNotEmpty');
    for (final banner in state.banners) {
      checkBannerItem(banner, type);
    }
    expect(state.sortType, sortType, reason: 'Loaded state sortType must be $sortType');
    expect(state.selectedItemKeys, selectedItemKeys, reason: 'Loaded state selectedItemKeys must be $selectedItemKeys');
    expect(state.selectedVersions, selectedVersions, reason: 'Loaded state selectedVersions must be $selectedVersions');

    if (selectedItemKeys.isNotEmpty && bannersAreNotEmpty) {
      expect(state.banners.length, state.selectedItemKeys.length, reason: 'With item keys selected, one banner must remain per key (${state.selectedItemKeys.length})');
    }

    if (selectedVersions.isNotEmpty && bannersAreNotEmpty) {
      final versions = state.banners
          .expand((el) => el.versions)
          .where((e) => e.released && selectedVersions.contains(e.version))
          .map((e) => e.version)
          .toSet()
          .toList();
      expect(versions.length, selectedVersions.length, reason: 'Every selected version must be represented among released banner versions');
    }

    final maxCount = max(characterBanners.length, weaponBanners.length);
    expect(state.maxNumberOfItems, maxCount, reason: 'maxNumberOfItems must equal the larger of character/weapon banner counts ($maxCount)');
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
      ), reason: 'A freshly built BannerHistoryCountBloc must start in the initial character state'),
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
      expect(allCharsCount, bannerCount, reason: 'Every released, non-traveler character with a banner must appear once ($allCharsCount expected)');
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
      verify: (bloc) {
        checkCommonState(bloc.state, sortType: BannerHistorySortType.nameDesc);
        final names = bloc.state.banners.map((e) => e.name).toList();
        final sorted = [...names]..sort((x, y) => y.compareTo(x));
        expect(names, sorted, reason: 'After sortTypeChanged(nameDesc), banner names must be in descending order');
      },
    );

    blocTest<BannerHistoryCountBloc, BannerHistoryCountState>(
      'sorted by version desc.',
      build: () => BannerHistoryCountBloc(genshinService, telemetryService),
      act: (bloc) => bloc
        ..add(const BannerHistoryCountEvent.init())
        ..add(const BannerHistoryCountEvent.sortTypeChanged(type: BannerHistorySortType.versionDesc)),
      verify: (bloc) {
        checkCommonState(bloc.state, sortType: BannerHistorySortType.versionDesc);
        final versions = bloc.state.versions.map((e) => e).toList();
        final sorted = [...versions]..sort((x, y) => y.compareTo(x));
        expect(versions, sorted, reason: 'After sortTypeChanged(versionDesc), versions must be in descending order');
      },
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
        expect(bloc.state.banners.length, 12, reason: 'Selecting version 1.3 with no item selected must keep all 12 character banners');
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
        expect(bloc.state.banners.length, 14, reason: 'After switching to weapon banners on version 1.3, 14 weapon banners must remain');
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
        expect(bloc.state.banners.length, 12, reason: 'Selecting then deselecting an item on version 1.3 must restore all 12 character banners');
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
        expect(bloc.state.banners.length, 0, reason: 'Selecting keqing on version 1.0 (unreleased then) must yield 0 banners');
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
      checkCommonState(
        bloc.state,
        type: BannerHistoryItemType.weapon,
        sortType: BannerHistorySortType.nameDesc,
        selectedVersions: [1.1],
      );
      final itemsForSearch = bloc.getItemsForSearch();
      final banners = genshinService.bannerHistory.getBanners(bloc.state.selectedVersions.first);
      final expectedCount = banners
          .where((el) => el.type == BannerHistoryItemType.weapon)
          .expand((el) => el.items)
          .map((e) => e.key)
          .toSet()
          .length;
      final expectedItems = bloc.state.banners.map((e) => e.key).toSet().toList();
      expect(expectedCount, 14, reason: 'Version 1.1 weapon banners must expose 14 distinct items');
      expect(expectedItems.length, expectedCount, reason: 'State banner item count must match the 14 distinct weapon items');
      for (final key in expectedItems) {
        expect(itemsForSearch.any((el) => el.key == key), isTrue, reason: 'Every banner item key must be searchable via getItemsForSearch (key=$key)');
      }
    },
  );
}
