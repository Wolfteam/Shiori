import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:darq/darq.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/double_extensions.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/domain/wish_banner_constants.dart';

part 'wish_simulator_result_bloc.freezed.dart';
part 'wish_simulator_result_event.dart';
part 'wish_simulator_result_state.dart';

class WishSimulatorResultBloc extends Bloc<WishSimulatorResultEvent, WishSimulatorResultState> {
  final DataService _dataService;
  final TelemetryService _telemetryService;
  final Random _random;

  WishSimulatorResultBloc(this._dataService, this._telemetryService)
    : _random = Random(),
      super(const WishSimulatorResultState.loading()) {
    on<WishSimulatorResultEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(WishSimulatorResultEvent event, Emitter<WishSimulatorResultState> emit) async {
    switch (event) {
      case WishSimulatorResultEventInit():
        emit(await _pull(event.pulls, event.bannerIndex, event.period));
    }
  }

  Future<WishSimulatorResultState> _pull(int pulls, int bannerIndex, WishSimulatorBannerItemsPerPeriodModel period) async {
    if (pulls <= 0) {
      throw Exception('The provided pulls = $pulls is not valid');
    }

    if (bannerIndex < 0 || period.banners.elementAtOrNull(bannerIndex) == null) {
      throw Exception('The provided bannerIndex = $bannerIndex is not valid');
    }

    final banner = period.banners[bannerIndex];
    final bannerRates = _RatesPerBannerType(banner.type);
    final history = await _dataService.wishSimulator.getBannerPullHistory(
      banner.type,
      defaultXStarCount: bannerRates.defaultXStarCount,
    );
    final results = <WishSimulatorBannerItemResultModel>[];
    for (int i = 1; i <= pulls; i++) {
      final int randomRarity =
          bannerRates.getRarityIfGuaranteed(history) ?? _getRandomItemRarity(history.currentXStarCount, bannerRates);
      history.initXStarCountIfNeeded(randomRarity);

      final isRarityInFeatured = banner.featuredItems.isEmpty || banner.featuredItems.any((el) => el.rarity == randomRarity);
      final winsFiftyFifty = isRarityInFeatured && history.shouldWinFiftyFifty(randomRarity);
      final pool =
          [
            ...banner.characters.map(
              (e) => WishSimulatorBannerItemResultModel.character(
                key: e.key,
                image: e.image,
                rarity: e.rarity,
                elementType: e.elementType,
              ),
            ),
            ...banner.weapons.map(
              (e) => WishSimulatorBannerItemResultModel.weapon(
                key: e.key,
                image: e.image,
                rarity: e.rarity,
                weaponType: e.weaponType,
              ),
            ),
          ].where((el) {
            if (el.rarity != randomRarity) {
              return false;
            }

            if (!isRarityInFeatured) {
              return true;
            }

            return banner.featuredItems.isEmpty ||
                banner.featuredItems.any((p) => winsFiftyFifty ? p.key == el.key : p.key != el.key);
          }).toList();

      assert(pool.isNotEmpty);
      pool.shuffle(_random);
      final pickedItem = pool[_random.nextInt(pool.length)];
      results.add(pickedItem);

      final bool? gotFeaturedItem = !bannerRates.canBeGuaranteed(randomRarity)
          ? true
          : !isRarityInFeatured
          ? null
          : winsFiftyFifty;
      await history.pull(randomRarity, gotFeaturedItem);

      final itemType = switch (pickedItem) {
        WishSimulatorBannerCharacterResultModel() => ItemType.character,
        WishSimulatorBannerWeaponResultModel() => ItemType.weapon,
      };
      await _dataService.wishSimulator.saveBannerItemPullHistory(banner.type, pickedItem.key, itemType);
    }
    final fromUntilString =
        '${WishBannerConstants.dateFormat.format(period.from)}/${WishBannerConstants.dateFormat.format(period.until)}';
    await _telemetryService.trackWishSimulatorResult(bannerIndex, period.version, banner.type, fromUntilString);

    final sortedResults = results.orderByDescending((el) => el.rarity).thenBy((el) {
      final typeName = switch (el) {
        WishSimulatorBannerCharacterResultModel() => ItemType.character.name,
        WishSimulatorBannerWeaponResultModel() => ItemType.weapon.name,
      };
      return '$typeName-${el.key}';
    }).toList();
    return WishSimulatorResultState.loaded(results: sortedResults);
  }

  int _getRandomItemRarity(Map<int, int> currentXStarCount, _RatesPerBannerType bannerRates) {
    assert(bannerRates._rates.isNotEmpty);

    final probs = <double>[];
    final randomRarities = <int>[];
    for (final rate in bannerRates._rates) {
      final int pullCount = currentXStarCount[rate.rarity] ?? 0;
      final considerPullCount = rate.canBeGuaranteed && pullCount > rate.softRateIncreasesAt;
      final double prob = rate.getProb(pullCount, considerPullCount);

      final remainingProb = (100 - probs.sum).round();
      if (remainingProb <= 0) {
        continue;
      }
      probs.add(prob);
      randomRarities.addAll(List.filled(prob.round(), rate.rarity));
    }

    randomRarities.shuffle();
    assert(randomRarities.isNotEmpty);

    return randomRarities[_random.nextInt(randomRarities.length)];
  }
}

class _BannerRate {
  final int rarity;
  final int guaranteedAt;
  final double initialRate;
  final int softRateIncreasesAt;
  final int hardRateIncreasesAt;

  bool get canBeGuaranteed => !(guaranteedAt == -1);

  const _BannerRate(
    this.rarity,
    this.guaranteedAt,
    this.initialRate,
    this.softRateIncreasesAt,
    this.hardRateIncreasesAt,
  ) : assert(rarity >= WishBannerConstants.minObtainableRarity),
      assert(guaranteedAt > 0 && guaranteedAt > hardRateIncreasesAt),
      assert(initialRate > 0 && initialRate < 100),
      assert(softRateIncreasesAt > 0 && softRateIncreasesAt < hardRateIncreasesAt);

  const _BannerRate.simple(this.rarity, this.initialRate) : guaranteedAt = -1, softRateIncreasesAt = -1, hardRateIncreasesAt = -1;

  double _getSoftRateMultiplier() {
    if (rarity == WishBannerConstants.maxObtainableRarity) {
      return 0.5;
    }

    return 1.5;
  }

  double _getHardRateMultiplier() {
    if (rarity == WishBannerConstants.maxObtainableRarity) {
      return 2;
    }
    return 3;
  }

  double _getRate(int pullCount) {
    double rate = initialRate / 100;
    if (!canBeGuaranteed) {
      return rate;
    }
    if (pullCount >= softRateIncreasesAt && pullCount < hardRateIncreasesAt) {
      rate *= _getSoftRateMultiplier();
    } else if (pullCount >= hardRateIncreasesAt) {
      rate *= _getHardRateMultiplier();
    }

    return rate;
  }

  double getProb(int pullCount, bool considerPullCount) {
    final double rate = _getRate(pullCount);
    double x = -1 * rate;
    if (considerPullCount) {
      x *= pullCount;
    }

    final double y = ((1 - exp(x)) * 100).truncateToDecimalPlaces(fractionalDigits: 4);
    if (y > 100) {
      return 100;
    }
    return y;
  }
}

class _RatesPerBannerType {
  final BannerItemType type;
  final List<_BannerRate> _rates = [];
  final Map<int, int> _defaultXStarCount = {};

  Map<int, int> get defaultXStarCount => _defaultXStarCount;

  _RatesPerBannerType(this.type) {
    switch (type) {
      case BannerItemType.character:
      case BannerItemType.standard:
        _rates.add(const _BannerRate(5, 90, 0.6, 40, 74));
        _rates.add(const _BannerRate(4, 10, 5.1, 4, 7));
        _rates.add(const _BannerRate.simple(3, 94.3));
      case BannerItemType.weapon:
        _rates.add(const _BannerRate(5, 80, 0.7, 30, 64));
        _rates.add(const _BannerRate(4, 10, 6.0, 4, 7));
        _rates.add(const _BannerRate.simple(3, 93.3));
    }
    _defaultXStarCount.addAll({for (final v in _rates) v.rarity: 0});
  }

  bool canBeGuaranteed(int rarity) {
    final rate = _rates.firstWhereOrNull((el) => el.rarity == rarity);
    if (rate == null) {
      throw Exception('Rarity = $rarity does not have an associated rate');
    }

    return rate.canBeGuaranteed;
  }

  int? getRarityIfGuaranteed(WishSimulatorBannerPullHistory history) {
    if (history.type != type.index) {
      throw Exception('The rates only apply to banners of type = $type');
    }
    for (final rate in _rates) {
      if (!rate.canBeGuaranteed) {
        continue;
      }

      if (history.isItemGuaranteed(rate.rarity, rate.guaranteedAt)) {
        return rate.rarity;
      }
    }

    return null;
  }
}
