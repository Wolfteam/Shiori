import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const _dbFolder = 'shiori_wish_simulator_pull_history_bloc_test';

void main() {
  late final GenshinService genshinService;
  late final ResourceService resourceService;
  late final DataService dataService;
  late final String dbPath;
  final Map<BannerItemType, int> pullsOnBanner = {};

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    when(settingsService.useTwentyFourHoursFormat).thenReturn(false);
    when(settingsService.serverResetTime).thenReturn(AppServerResetTimeType.northAmerica);

    resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, LocaleServiceImpl(settingsService));
    dataService = DataServiceImpl(
      genshinService,
      CalculatorAscMaterialsServiceImpl(genshinService, resourceService),
      resourceService,
    );

    return Future(() async {
      await genshinService.init(settingsService.language);
      dbPath = await getDbPath(_dbFolder);
      await dataService.initForTests(dbPath);

      final random = Random();
      final banner = genshinService.bannerHistory.getBanners(1.3).first;
      final period = genshinService.bannerHistory.getWishSimulatorBannerPerPeriod(
        banner.version,
        banner.from,
        banner.until,
      );

      final historyMap = <BannerItemType, WishSimulatorBannerPullHistory>{};
      for (final type in BannerItemType.values) {
        final history = await dataService.wishSimulator.getBannerPullHistory(type);
        historyMap[type] = history;
      }

      for (int i = 0; i < 1000; i++) {
        final bannerIndex = random.nextInt(period.banners.length);

        final pickedBanner = period.banners[bannerIndex];
        final history = historyMap[pickedBanner.type]!;

        String itemKey;
        ItemType itemType;
        int rarity;
        final pickCharacters =
            pickedBanner.type == BannerItemType.character || (pickedBanner.type == BannerItemType.standard && random.nextBool());

        if (pickCharacters) {
          final character = pickedBanner.characters[random.nextInt(pickedBanner.characters.length)];
          itemKey = character.key;
          itemType = ItemType.character;
          rarity = character.rarity;
        } else {
          final weapon = pickedBanner.weapons[random.nextInt(pickedBanner.weapons.length)];
          itemKey = weapon.key;
          itemType = ItemType.weapon;
          rarity = weapon.rarity;
        }
        await history.pull(rarity, pickedBanner.featuredItems.any((el) => el.key == itemKey));

        await dataService.wishSimulator.saveBannerItemPullHistory(pickedBanner.type, itemKey, itemType);

        pullsOnBanner.update(pickedBanner.type, (value) => value + 1, ifAbsent: () => 1);
      }
    });
  });

  tearDownAll(() {
    return Future(() async {
      await dataService.closeThemAll();
      await deleteDbFolder(dbPath);
    });
  });

  WishSimulatorPullHistoryBloc getBloc() => WishSimulatorPullHistoryBloc(genshinService, dataService);

  test(
    'Initial state',
    () => expect(
      getBloc().state,
      const WishSimulatorPullHistoryState.loading(),
      reason: 'A fresh WishSimulatorPullHistoryBloc should start in loading state',
    ),
  );

  void checkState(
    BannerItemType bannerType,
    BannerItemType expectedBannerType,
    List<WishSimulatorBannerItemPullHistoryModel> allItems,
    List<WishSimulatorBannerItemPullHistoryModel> items,
    int maxPage,
    int currentPage, {
    int expectedCurrentPage = 1,
    bool shouldBeEmpty = false,
  }) {
    expect(bannerType, expectedBannerType, reason: 'Loaded banner type should match the requested ${expectedBannerType.name}, got ${bannerType.name}');
    expect(allItems.isEmpty == shouldBeEmpty, isTrue, reason: 'allItems emptiness should match shouldBeEmpty ($shouldBeEmpty) for banner ${bannerType.name}');
    expect(items.isEmpty == shouldBeEmpty, isTrue, reason: 'items emptiness should match shouldBeEmpty ($shouldBeEmpty) for banner ${bannerType.name}');
    if (shouldBeEmpty) {
      expect(currentPage, 1, reason: 'Empty pull history should stay on page 1, got $currentPage');
      expect(maxPage, 1, reason: 'Empty pull history should have a single page, got $maxPage');
      return;
    }
    expect(currentPage, expectedCurrentPage, reason: 'Current page should be $expectedCurrentPage, got $currentPage');
    final expectedMaxPages = (pullsOnBanner[bannerType]! / WishSimulatorPullHistoryBloc.take).ceil();
    expect(maxPage, expectedMaxPages, reason: 'maxPage should be $expectedMaxPages for ${pullsOnBanner[bannerType]} pulls, got $maxPage');

    final allItemKeys = allItems.map((e) => e.key).toSet();
    final expectedItemTypes = [ItemType.character, ItemType.weapon];
    for (final item in allItems) {
      checkItemKeyAndName(item.key, item.name);
      checkBannerRarity(item.rarity);
      expect(item.type, isIn(expectedItemTypes), reason: 'Pulled item type should be character or weapon (key=${item.key}), got ${item.type}');
      expect(item.pulledOn.isNotEmpty, isTrue, reason: 'Pulled item should carry a pulledOn timestamp (key=${item.key})');
    }

    for (final item in items) {
      checkItemKeyAndName(item.key, item.name);
      checkBannerRarity(item.rarity);
      expect(item.type, isIn(expectedItemTypes), reason: 'Paged item type should be character or weapon (key=${item.key}), got ${item.type}');
      expect(item.pulledOn.isNotEmpty, isTrue, reason: 'Paged item should carry a pulledOn timestamp (key=${item.key})');
      expect(item.key, isIn(allItemKeys), reason: 'Paged item ${item.key} should also appear in allItems');
    }
  }

  group('Init', () {
    for (final type in BannerItemType.values) {
      blocTest(
        'empty with banner = ${type.name}',
        build: () {
          final wishSimulatorMock = MockWishSimulatorDataService();
          when(wishSimulatorMock.getBannerItemsPullHistoryPerType(captureThat(isIn(BannerItemType.values)))).thenReturn([]);
          final dataServiceMock = MockDataService();
          when(dataServiceMock.wishSimulator).thenReturn(wishSimulatorMock);
          return WishSimulatorPullHistoryBloc(genshinService, dataServiceMock);
        },
        act: (bloc) => bloc..add(WishSimulatorPullHistoryEvent.init(bannerType: type)),
        verify: (bloc) {
          final state = bloc.state;
          switch (state) {
            case WishSimulatorPullHistoryStateLoading():
              throw InvalidStateError();
            case WishSimulatorPullHistoryStateLoaded():
              checkState(
                state.bannerType,
                type,
                state.allItems,
                state.items,
                state.maxPage,
                state.currentPage,
                shouldBeEmpty: true,
              );
          }
        },
      );
    }

    for (final type in BannerItemType.values) {
      blocTest(
        'with banner = ${type.name}',
        build: () => getBloc(),
        act: (bloc) => bloc..add(WishSimulatorPullHistoryEvent.init(bannerType: type)),
        verify: (bloc) {
          final state = bloc.state;
          switch (state) {
            case WishSimulatorPullHistoryStateLoading():
              throw InvalidStateError();
            case WishSimulatorPullHistoryStateLoaded():
              checkState(
                state.bannerType,
                type,
                state.allItems,
                state.items,
                state.maxPage,
                state.currentPage,
              );
          }
        },
      );
    }

    blocTest(
      'twice with same type, resulting in the last state not being emitted',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const WishSimulatorPullHistoryEvent.init(bannerType: BannerItemType.standard))
        ..add(const WishSimulatorPullHistoryEvent.init(bannerType: BannerItemType.standard)),
      skip: 1,
      expect: () => [],
    );
  });

  group('Page changed', () {
    blocTest(
      'invalid page change',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const WishSimulatorPullHistoryEvent.init(bannerType: BannerItemType.character))
        ..add(const WishSimulatorPullHistoryEvent.pageChanged(page: 0)),
      errors: () => [predicate<RangeError>((e) => e.name == 'newPage')],
    );

    blocTest(
      'valid page change',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const WishSimulatorPullHistoryEvent.init(bannerType: BannerItemType.character))
        ..add(const WishSimulatorPullHistoryEvent.pageChanged(page: 2)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case WishSimulatorPullHistoryStateLoading():
            throw InvalidStateError();
          case WishSimulatorPullHistoryStateLoaded():
            checkState(
              state.bannerType,
              BannerItemType.character,
              state.allItems,
              state.items,
              state.maxPage,
              state.currentPage,
              expectedCurrentPage: 2,
            );
        }
      },
    );

    blocTest(
      'page changed twice to the same value thus no generating a new state',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const WishSimulatorPullHistoryEvent.init(bannerType: BannerItemType.character))
        ..add(const WishSimulatorPullHistoryEvent.pageChanged(page: 2))
        ..add(const WishSimulatorPullHistoryEvent.pageChanged(page: 2)),
      skip: 2,
      expect: () => [],
    );
  });

  for (final type in BannerItemType.values) {
    final wishSimulatorMock = MockWishSimulatorDataService();
    when(wishSimulatorMock.getBannerItemsPullHistoryPerType(captureThat(equals(type)))).thenReturn([]);
    when(wishSimulatorMock.clearBannerItemPullHistory(captureThat(equals(type)))).thenAnswer((_) => Future.value());

    final dataServiceMock = MockDataService();
    when(dataServiceMock.wishSimulator).thenReturn(wishSimulatorMock);

    blocTest(
      'Delete data from banner = ${type.name}',
      build: () => WishSimulatorPullHistoryBloc(genshinService, dataServiceMock),
      act: (bloc) => bloc
        ..add(WishSimulatorPullHistoryEvent.init(bannerType: type))
        ..add(WishSimulatorPullHistoryEvent.deleteData(bannerType: type)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case WishSimulatorPullHistoryStateLoading():
            throw InvalidStateError();
          case WishSimulatorPullHistoryStateLoaded():
            checkState(
              state.bannerType,
              type,
              state.allItems,
              state.items,
              state.maxPage,
              state.currentPage,
              shouldBeEmpty: true,
            );
            verify(wishSimulatorMock.clearBannerItemPullHistory(type)).called(1);
        }
      },
    );
  }
}
