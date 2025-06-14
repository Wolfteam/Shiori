import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

void main() {
  late final GenshinService genshinService;
  late final ResourceService resourceService;
  final TelemetryService telemetryService = MockTelemetryService();

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    when(settingsService.showWeaponDetails).thenReturn(true);
    final localeService = LocaleServiceImpl(settingsService);
    resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);

    return Future(() async {
      await genshinService.init(AppLanguageType.english);
    });
  });

  WishSimulatorBloc getBloc() => WishSimulatorBloc(genshinService, resourceService, telemetryService);

  void checkState(
    double expectedVersion,
    String wishIconImage,
    int selectedBannerIndex,
    WishSimulatorBannerItemsPerPeriodModel period, {
    int expectedSelectedBannerIndex = 0,
  }) {
    expect(selectedBannerIndex == expectedSelectedBannerIndex, isTrue);
    checkAsset(wishIconImage);
    expect(period.version == expectedVersion, isTrue);

    for (final type in BannerItemType.values) {
      expect(period.banners.any((el) => el.type == type), isTrue);
    }
    for (final banner in period.banners) {
      checkAsset(banner.image);
      expect(banner.featuredImages.isNotEmpty, isTrue);

      if (banner.type == BannerItemType.standard) {
        expect(banner.featuredItems.isEmpty, isTrue);
      } else {
        expect(banner.featuredItems.isNotEmpty, isTrue);
      }

      expect(banner.characters.isNotEmpty, isTrue);
      expect(banner.weapons.isNotEmpty, isTrue);

      for (final img in banner.featuredImages) {
        checkAsset(img);
      }

      for (final item in banner.featuredItems) {
        checkItemKeyAndImage(item.key, item.iconImage);
        checkBannerRarity(item.rarity);
        expect(item.type, isIn([ItemType.character, ItemType.weapon]));
      }

      for (final item in banner.characters) {
        checkItemKeyAndImage(item.key, item.iconImage);
        checkAsset(item.image);
        checkBannerRarity(item.rarity);
      }

      for (final item in banner.weapons) {
        checkItemKeyAndImage(item.key, item.iconImage);
        checkAsset(item.image);
        checkBannerRarity(item.rarity, min: 3);
      }
    }
  }

  test(
    'Initial state',
    () => expect(getBloc().state, const WishSimulatorState.loading()),
  );

  blocTest(
    'Init',
    build: () => WishSimulatorBloc(genshinService, resourceService, telemetryService),
    act: (bloc) => bloc..add(const WishSimulatorEvent.init()),
    verify: (bloc) {
      final state = bloc.state;
      switch (state) {
        case WishSimulatorStateLoading():
          throw Exception('Invalid state');
        case WishSimulatorStateLoaded():
          final version = genshinService.bannerHistory.getBannerHistoryVersions(SortDirectionType.desc).first;
          checkState(version, state.wishIconImage, state.selectedBannerIndex, state.period);
      }
    },
  );

  group('Period changed', () {
    blocTest(
      'invalid version, throws exception',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const WishSimulatorEvent.init())
        ..add(
          WishSimulatorEvent.periodChanged(version: 0, from: DateTime.now(), until: DateTime.now().add(const Duration(days: 3))),
        ),
      errors: () => [isA<Exception>()],
    );

    blocTest(
      'invalid date range, throws exception',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const WishSimulatorEvent.init())
        ..add(WishSimulatorEvent.periodChanged(version: 1.0, from: DateTime.now(), until: DateTime.now())),
      errors: () => [isA<Exception>()],
    );

    const double version = 1.3;
    blocTest(
      'valid period',
      build: () => getBloc(),
      act: (bloc) {
        final banner = genshinService.bannerHistory.getBanners(version).first;
        return bloc
          ..add(const WishSimulatorEvent.init())
          ..add(WishSimulatorEvent.periodChanged(version: version, from: banner.from, until: banner.until));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case WishSimulatorStateLoading():
            throw Exception('Invalid state');
          case WishSimulatorStateLoaded():
            checkState(version, state.wishIconImage, state.selectedBannerIndex, state.period);
        }
      },
    );
  });

  group('Banner changed', () {
    blocTest(
      'invalid index, throws exception',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const WishSimulatorEvent.init())
        ..add(const WishSimulatorEvent.bannerSelected(index: -1)),
      errors: () => [isA<Exception>()],
    );

    const int bannerIndex = 1;
    const double version = 1.3;
    blocTest(
      'valid index',
      build: () => getBloc(),
      act: (bloc) {
        final banner = genshinService.bannerHistory.getBanners(version).first;
        return bloc
          ..add(const WishSimulatorEvent.init())
          ..add(WishSimulatorEvent.periodChanged(version: version, from: banner.from, until: banner.until))
          ..add(const WishSimulatorEvent.bannerSelected(index: bannerIndex));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case WishSimulatorStateLoading():
            throw Exception('Invalid state');
          case WishSimulatorStateLoaded():
            checkState(
              version,
              state.wishIconImage,
              state.selectedBannerIndex,
              state.period,
              expectedSelectedBannerIndex: bannerIndex,
            );
        }
      },
    );
  });
}
