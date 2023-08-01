import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'wish_simulator_result_bloc.freezed.dart';
part 'wish_simulator_result_event.dart';
part 'wish_simulator_result_state.dart';

class WishSimulatorResultBloc
    extends Bloc<WishSimulatorResultEvent, WishSimulatorResultState> {
  final GenshinService _genshinService;
  final _random = Random();

  WishSimulatorResultBloc(this._genshinService)
      : super(const WishSimulatorResultState.loading());

  @override
  Stream<WishSimulatorResultState> mapEventToState(
      WishSimulatorResultEvent event) async* {
    final banner = event.period.banners[event.index];
    final characters = banner.characters
        .take(3)
        .map((e) => WishBannerItemResultModel.character(
            image: e.image, rarity: e.rarity, elementType: e.elementType))
        .toList();
    final weapons = banner.weapons
        .take(7)
        .map(
          (e) => WishBannerItemResultModel.weapon(
              image: e.image, rarity: e.rarity, weaponType: e.weaponType),
        )
        .toList();

    yield WishSimulatorResultState.loaded(results: [...characters, ...weapons]);
  }

  int _rollRandom(int pullCount, BannerItemType type) {
    BannerRate? fiveStarRate;
    BannerRate? fourStarRate;
    switch (type) {
      case BannerItemType.character:
      case BannerItemType.standard:
        fiveStarRate = BannerRate(5, 90, 0.6, 40, 74);
        fourStarRate = BannerRate(4, 10, 5.1, 4, 7);
        break;
      case BannerItemType.weapon:
        fiveStarRate = BannerRate(5, 80, 0.7, 30, 64);
        fourStarRate = BannerRate(4, 10, 6.0, 4, 7);
        break;
      default:
        throw Exception('Invalid banner item type');
    }

    final double fiveStarProb = _getProb(pullCount, fiveStarRate);
    final double fourStarProb = _getProb(pullCount, fourStarRate);
    final double threeStarProp =
        dp(100 - (fiveStarProb - fourStarProb).abs(), 2);
    print([threeStarProp, fourStarProb, fiveStarProb]);
    final probs = [
      ...List.filled(threeStarProp.toInt(), 3),
      ...List.filled(fourStarProb.toInt(), 4),
      ...List.filled(fiveStarProb.toInt(), 5)
    ]..shuffle();

    print('Picking random...');
    final int picked = probs[Random().nextInt(probs.length)];
    return picked;
  }

  double _getProb(int i, BannerRate rate) {
    double currentDelta = rate.initialRate / 100;
    if (i >= rate.softRateIncreasesAt && i < rate.hardRateIncreasesAt) {
      currentDelta *= 2;
    } else if (i >= rate.hardRateIncreasesAt) {
      currentDelta *= 4;
    }

    //At 40 pulls, the 5* rate increases to 1.18%, and at 75 pulls, the rate increases to 25%.
    double x = -1 * i * currentDelta;
    final maxX = log(1 - 0.99);
    if (maxX > x) {
      x = maxX;
    }

    final double y = dp((1 - exp(x)) * 100, 4);
    return y;
  }
}

class WishSimulatorCountPerType {
  BannerItemType type;
  int wishCount;

  WishSimulatorCountPerType({
    required this.type,
    required this.wishCount,
  });
}

class BannerRate {
  int rarity;
  int maxPull;
  double initialRate;
  int softRateIncreasesAt;
  int hardRateIncreasesAt;

  BannerRate(this.rarity, this.maxPull, this.initialRate,
      this.softRateIncreasesAt, this.hardRateIncreasesAt);
}

double dp(double val, int places) {
  final mod = pow(10.0, places);
  return (val * mod).round().toDouble() / mod;
}

class WishHistory {
  final BannerItemType type;
  int totalCount;
  int fourStarCount;
  int fiveStarCount;

  WishHistory(
      this.type, this.totalCount, this.fourStarCount, this.fiveStarCount);

  bool isFiveStarGuaranteed(int maxCount) {
    return _isXStarGuaranteed(maxCount, fiveStarCount);
  }

  bool isFourStarGuaranteed(int maxCount) {
    return _isXStarGuaranteed(maxCount, fourStarCount);
  }

  void pull(int rarity) {
    totalCount++;
    if (rarity == 4) {
      fourStarCount = 0;
    } else {
      fourStarCount++;
    }
    if (rarity == 5) {
      fiveStarCount = 0;
    } else {
      fiveStarCount++;
    }

    print(
        'totalCount = $totalCount - fourStarCount = $fourStarCount -- fiveStarCount = $fiveStarCount');
  }

  static bool _isXStarGuaranteed(int maxCount, int current) {
    return current + 1 >= maxCount;
  }
}
