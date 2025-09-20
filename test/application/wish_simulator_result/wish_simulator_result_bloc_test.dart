import 'package:bloc_test/bloc_test.dart';
import 'package:darq/darq.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/domain/wish_banner_constants.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const _dbFolder = 'shiori_wish_simulator_result_bloc_test';

void main() {
  late final GenshinService genshinService;
  late final ResourceService resourceService;
  late final DataService dataService;
  final TelemetryService telemetryService = MockTelemetryService();
  late final String dbPath;
  late final WishSimulatorBannerItemsPerPeriodModel period;

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

      const double version = 1.3;
      final banner = genshinService.bannerHistory.getBanners(version).last;
      period = genshinService.bannerHistory.getWishSimulatorBannerPerPeriod(version, banner.from, banner.until);
    });
  });

  tearDownAll(() {
    return Future(() async {
      await dataService.closeThemAll();
      await deleteDbFolder(dbPath);
    });
  });

  WishSimulatorResultBloc getBloc() => WishSimulatorResultBloc(dataService, telemetryService);

  void checkState(
    int bannerIndex,
    int pulls,
    List<WishSimulatorBannerItemResultModel> results, {
    int? minFourStarCount,
    int? minFiveStarCount,
  }) {
    final banner = period.banners[bannerIndex];
    final bannerType = banner.type;
    expect(results.length == pulls, isTrue);

    final gotFourStar = results.any((r) => r.rarity == 4);
    final gotFiveStar = results.any((r) => r.rarity == WishBannerConstants.maxObtainableRarity);
    expect(gotFourStar || gotFiveStar, isTrue);

    if (minFourStarCount != null) {
      expect(results.count((r) => r.rarity == 4) >= minFourStarCount, isTrue);
    }

    if (minFiveStarCount != null) {
      expect(results.count((r) => r.rarity == WishBannerConstants.maxObtainableRarity) >= minFiveStarCount, isTrue);
    }

    for (final item in results) {
      checkItemKeyAndImage(item.key, item.image);
      checkBannerRarity(
        item.rarity,
        min: switch (item) {
          WishSimulatorBannerCharacterResultModel() => 4,
          WishSimulatorBannerWeaponResultModel() => 3,
        },
      );
      switch (item) {
        case WishSimulatorBannerCharacterResultModel():
          expect(banner.characters.any((c) => c.key == item.key), isTrue);
        case WishSimulatorBannerWeaponResultModel():
          expect(banner.weapons.any((c) => c.key == item.key), isTrue);
      }

      if (item.rarity != WishBannerConstants.maxObtainableRarity || bannerType == BannerItemType.standard) {
        break;
      }

      final expectedType = switch (item) {
        WishSimulatorBannerCharacterResultModel() => BannerItemType.character,
        WishSimulatorBannerWeaponResultModel() => BannerItemType.weapon,
      };
      expect(bannerType, expectedType);
    }
  }

  test('Initial state', () => expect(getBloc().state, const WishSimulatorResultState.loading()));

  group('Init', () {
    blocTest(
      'invalid pulls',
      build: () => getBloc(),
      act: (bloc) => bloc..add(WishSimulatorResultEvent.init(bannerIndex: 0, pulls: 0, period: period)),
      errors: () => [predicate<RangeError>((e) => e.name == 'pulls')],
    );

    blocTest(
      'invalid banner index',
      build: () => getBloc(),
      act: (bloc) => bloc..add(WishSimulatorResultEvent.init(bannerIndex: -1, pulls: 10, period: period)),
      errors: () => [predicate<RangeError>((e) => e.name == 'bannerIndex')],
    );

    blocTest(
      'banner index does not exist in period',
      build: () => getBloc(),
      act: (bloc) => bloc..add(WishSimulatorResultEvent.init(bannerIndex: period.banners.length + 1, pulls: 1, period: period)),
      errors: () => [predicate<RangeError>((e) => e.name == 'bannerIndex')],
    );

    blocTest(
      'pull x100 and gets multiple 4 star and at least one 5 star',
      build: () => getBloc(),
      act: (bloc) => bloc..add(WishSimulatorResultEvent.init(bannerIndex: 0, pulls: 100, period: period)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case WishSimulatorResultStateLoading():
            throw InvalidStateError();
          case WishSimulatorResultStateLoaded():
            checkState(0, 100, state.results, minFourStarCount: 9, minFiveStarCount: 1);
        }
      },
    );
  });
}
