import 'dart:math';

import 'package:collection/collection.dart';
import 'package:bloc/bloc.dart';
import 'package:darq/darq.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/extensions/double_extensions.dart';
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
    final history = await _dataService.wishSimulator.getBannerCountPerType(banner.type);
    final bannerRates = _RatesPerBannerType(banner.type);
    final bannerKey = _generateBannerKey(banner);
    final results = <WishBannerItemResultModel>[];
    for (int i = 1; i <= pulls; i++) {
      final int randomRarity = bannerRates.getGuaranteedIfExists(history)?.rarity ??
          _getRandomItemRarity(history.currentXStarCount, bannerRates);
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
    final probs = <double>[];
    final randomRarities = <int>[];
    final manuallyAddMinRarity = !currentXStarCount.containsKey(WishBannerConstants.minObtainableRarity);
    for (final kvp in currentXStarCount.entries) {
      final rarity = kvp.key;
      final pullCount = kvp.value;
      final bannerRate = bannerRates.rates.firstWhere((el) => el.rarity == rarity);
      final considerPullCount = pullCount > bannerRate.softRateIncreasesAt;
      final double prob = bannerRate.getProb(pullCount, considerPullCount);
      probs.add(prob);
      randomRarities.addAll(List.filled(prob.round(), rarity));
    }

    if (manuallyAddMinRarity) {
      final remaingProb = (100 - probs.sum).round();
      if (remaingProb > 0) {
        randomRarities.addAll(List.filled(remaingProb, WishBannerConstants.minObtainableRarity));
      }
    }

    randomRarities.shuffle();

    return randomRarities[_random.nextInt(randomRarities.length)];
  }
}

class _BannerRate {
  final int rarity;
  final int guaranteedAt;
  final double initialRate;
  final int softRateIncreasesAt;
  final int hardRateIncreasesAt;

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

  _RatesPerBannerType(this.type) {
    switch (type) {
      case BannerItemType.character:
      case BannerItemType.standard:
        rates.add(const _BannerRate(5, 90, 0.6, 40, 74));
        rates.add(const _BannerRate(4, 10, 5.1, 4, 7));
        break;
      case BannerItemType.weapon:
        rates.add(const _BannerRate(5, 80, 0.7, 30, 64));
        rates.add(const _BannerRate(4, 10, 6.0, 4, 7));
        break;
    }
  }

  _BannerRate? getGuaranteedIfExists(WishSimulatorBannerCountPerType history) {
    if (history.type != type.index) {
      throw Exception('The rates only apply to banners of type = $type');
    }
    for (final item in rates) {
      if (history.isItemGuaranteed(item.rarity, item.guaranteedAt)) {
        return item;
      }
    }

    return null;
  }
}
