import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/double_extensions.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/wish_banner_constants.dart';

part 'wish_simulator_result_bloc.freezed.dart';
part 'wish_simulator_result_event.dart';
part 'wish_simulator_result_state.dart';

class WishSimulatorResultBloc extends Bloc<WishSimulatorResultEvent, WishSimulatorResultState> {
  final GenshinService _genshinService;
  final DataService _dataService;
  final Random _random;

  WishSimulatorResultBloc(this._genshinService, this._dataService)
      : _random = Random(),
        super(const WishSimulatorResultState.loading());

  @override
  Stream<WishSimulatorResultState> mapEventToState(WishSimulatorResultEvent event) async* {
    final s = await event.map(
      init: (e) => _pull(e.qty, e.index, e.period),
    );

    yield s;
  }

  Future<WishSimulatorResultState> _pull(int pulls, int bannerIndex, WishBannerItemsPerPeriodModel period) async {
    if (pulls <= 0) {
      throw Exception('The provided pulls = $pulls is not valid');
    }

    if (bannerIndex < 0 || period.banners.elementAtOrNull(bannerIndex) == null) {
      throw Exception('The provided bannerIndex = $bannerIndex is not valid');
    }

    final banner = period.banners[bannerIndex];
    final bannerRates = _RatesPerBannerType(banner.type);
    final history = await _dataService.wishSimulator.getBannerPullHistoryPerType(banner.type);
    final bannerKey = _generateBannerKey(banner);
    final results = <WishBannerItemResultModel>[];
    for (int i = 1; i <= pulls; i++) {
      final int randomRarity = bannerRates.getRarityIfGuaranteed(history) ?? _getRandomItemRarity(history.currentXStarCount, bannerRates);
      final isRarityInPromoted = banner.promotedItems.any((el) => el.rarity == randomRarity);
      final winsFiftyFifty = isRarityInPromoted && history.shouldWinFiftyFifty(randomRarity);
      final pool = [
        ...banner.characters.map(
          (e) => WishBannerItemResultModel.character(
            key: e.key,
            image: e.image,
            rarity: e.rarity,
            elementType: e.elementType,
          ),
        ),
        ...banner.weapons.map(
          (e) => WishBannerItemResultModel.weapon(
            key: e.key,
            image: e.image,
            rarity: e.rarity,
            weaponType: e.weaponType,
          ),
        )
      ].where((el) {
        if (el.rarity != randomRarity) {
          return false;
        }

        if (!isRarityInPromoted) {
          return true;
        }

        return banner.promotedItems.any((p) => winsFiftyFifty ? p.key == el.key : p.key != el.key);
      }).toList();

      assert(pool.isNotEmpty);
      final pickedItem = pool[_random.nextInt(pool.length)];
      results.add(pickedItem);

      await history.pull(randomRarity, !isRarityInPromoted ? null : winsFiftyFifty);

      final itemType = pickedItem.map(character: (_) => ItemType.character, weapon: (_) => ItemType.weapon);
      await _dataService.wishSimulator.saveBannerItemPullHistory(bannerKey, pickedItem.key, itemType);
    }

    results.sort((x, y) => y.rarity.compareTo(x.rarity));

    return WishSimulatorResultState.loaded(results: results);
  }

  String _generateBannerKey(WishBannerItemModel banner) {
    switch (banner.type) {
      case BannerItemType.character:
      case BannerItemType.weapon:
        //TODO: THE KEY HERE
        return '${banner.type}';
      case BannerItemType.standard:
        return '${banner.type}';
    }
  }

  int _getRandomItemRarity(Map<int, int> currentXStarCount, _RatesPerBannerType bannerRates) {
    assert(bannerRates.rates.isNotEmpty);

    final probs = <double>[];
    final randomRarities = <int>[];
    for (final rate in bannerRates.rates) {
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
  )   : assert(rarity >= WishBannerConstants.minObtainableRarity),
        assert(guaranteedAt > 0 && guaranteedAt > hardRateIncreasesAt),
        assert(initialRate > 0 && initialRate < 100),
        assert(softRateIncreasesAt > 0 && softRateIncreasesAt < hardRateIncreasesAt);

  const _BannerRate.simple(this.rarity, this.initialRate)
      : guaranteedAt = -1,
        softRateIncreasesAt = -1,
        hardRateIncreasesAt = -1;

  double _getSoftRateMultiplier() {
    if (rarity == WishBannerConstants.promotedRarity) {
      return 0.5;
    }

    return 1.5;
  }

  double _getHardRateMultiplier() {
    if (rarity == WishBannerConstants.promotedRarity) {
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
  final List<_BannerRate> rates = [];

  Map<int, int> get getDefaultXStarCount => {for (var v in rates) v.rarity: 0};

  _RatesPerBannerType(this.type) {
    switch (type) {
      case BannerItemType.character:
      case BannerItemType.standard:
        rates.add(const _BannerRate(5, 90, 0.6, 40, 74));
        rates.add(const _BannerRate(4, 10, 5.1, 4, 7));
        rates.add(const _BannerRate.simple(3, 94.3));
        break;
      case BannerItemType.weapon:
        rates.add(const _BannerRate(5, 80, 0.7, 30, 64));
        rates.add(const _BannerRate(4, 10, 6.0, 4, 7));
        rates.add(const _BannerRate.simple(3, 93.3));
        break;
    }
  }

  int? getRarityIfGuaranteed(WishSimulatorBannerPullHistoryPerType history) {
    if (history.type != type.index) {
      throw Exception('The rates only apply to banners of type = $type');
    }
    for (final rate in rates) {
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
