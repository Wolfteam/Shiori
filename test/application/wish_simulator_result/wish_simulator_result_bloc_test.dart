import 'package:bloc_test/bloc_test.dart';
import 'package:darq/darq.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
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
  late final WishBannerItemsPerPeriodModel period;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settingsService = MockSettingsService();
    when(settingsService.language).thenReturn(AppLanguageType.english);
    when(settingsService.useTwentyFourHoursFormat).thenReturn(false);
    when(settingsService.serverResetTime).thenReturn(AppServerResetTimeType.northAmerica);

    resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, LocaleServiceImpl(settingsService));
    dataService = DataServiceImpl(genshinService, CalculatorServiceImpl(genshinService, resourceService), resourceService);

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
    List<WishBannerItemResultModel> results, {
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
      checkBannerRarity(item.rarity, min: item.map(character: (_) => 4, weapon: (_) => 3));
      if (item.maybeMap(character: (_) => true, orElse: () => false)) {
        expect(banner.characters.any((c) => c.key == item.key), isTrue);
      } else {
        expect(banner.weapons.any((c) => c.key == item.key), isTrue);
      }

      if (item.rarity != WishBannerConstants.maxObtainableRarity || bannerType == BannerItemType.standard) {
        break;
      }

      final expectedType = item.map(character: (_) => BannerItemType.character, weapon: (_) => BannerItemType.weapon);
      expect(bannerType, expectedType);
    }
  }

  test('Initial state', () => expect(getBloc().state, const WishSimulatorResultState.loading()));

  group('Init', () {
    blocTest(
      'invalid pulls',
      build: () => getBloc(),
      act: (bloc) => bloc..add(WishSimulatorResultEvent.init(index: 0, qty: 0, period: period)),
      errors: () => [isA<Exception>()],
    );

    blocTest(
      'invalid banner index',
      build: () => getBloc(),
      act: (bloc) => bloc..add(WishSimulatorResultEvent.init(index: -1, qty: 1, period: period)),
      errors: () => [isA<Exception>()],
    );

    blocTest(
      'banner index does not exist in period',
      build: () => getBloc(),
      act: (bloc) => bloc..add(WishSimulatorResultEvent.init(index: period.banners.length + 1, qty: 1, period: period)),
      errors: () => [isA<Exception>()],
    );

    blocTest(
      'pull x100 and gets multiple 4 star and at least one 5 star',
      build: () => getBloc(),
      act: (bloc) => bloc..add(WishSimulatorResultEvent.init(index: 0, qty: 100, period: period)),
      verify: (bloc) => bloc.state.maybeMap(
        orElse: () => throw Exception('Invalid state'),
        loaded: (state) => checkState(0, 100, state.results, minFourStarCount: 9, minFiveStarCount: 1),
      ),
    );
  });
}
