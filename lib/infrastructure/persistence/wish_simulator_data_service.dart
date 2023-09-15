import 'package:darq/darq.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/persistence/wish_simulator_data_service.dart';

class WishSimulatorDataServiceImpl implements WishSimulatorDataService {
  late final Box<WishSimulatorBannerPullHistoryPerType> _bannerCountPerType;
  late final Box<WishSimulatorBannerPullHistory> _bannerPullHistory;

  WishSimulatorDataServiceImpl();

  @override
  Future<void> init() async {
    //TODO: RENAME THE CLASS + BOXES
    _bannerCountPerType = await Hive.openBox<WishSimulatorBannerPullHistoryPerType>('wishSimulatorBannerCountPerType');
    _bannerPullHistory = await Hive.openBox<WishSimulatorBannerPullHistory>('wishSimulatorBannerPullHistory');
  }

  @override
  Future<void> deleteThemAll() {
    return Future.wait([
      _bannerCountPerType.clear(),
      clearAllBannerItemPullHistory(),
    ]);
  }

  @override
  Future<WishSimulatorBannerPullHistoryPerType> getBannerPullHistoryCountPerType(BannerItemType type) async {
    WishSimulatorBannerPullHistoryPerType? value = _bannerCountPerType.values.firstWhereOrDefault((el) => el.type == type.index);
    if (value == null) {
      value = WishSimulatorBannerPullHistoryPerType.newOne(type);
      await _bannerCountPerType.add(value);
    }
    return value;
  }

  @override
  Future<void> saveBannerItemPullHistory(BannerItemType bannerType, String itemKey, ItemType itemType) {
    if (itemKey.isNullEmptyOrWhitespace) {
      throw Exception('Invalid itemKey');
    }

    if (itemType != ItemType.character && itemType != ItemType.weapon) {
      throw Exception('The provided itemT1ype = $itemType is not valid');
    }

    final value = itemType == ItemType.character
        ? WishSimulatorBannerPullHistory.character(bannerType, itemKey)
        : WishSimulatorBannerPullHistory.weapon(bannerType, itemKey);
    return _bannerPullHistory.add(value);
  }

  @override
  Future<void> clearBannerItemPullHistory(BannerItemType bannerType) async {
    final keys = _bannerPullHistory.values.where((el) => el.bannerType == bannerType.index).map((e) => e.key).toList();
    if (keys.isNotEmpty) {
      await _bannerPullHistory.deleteAll(keys);
    }
  }

  @override
  Future<void> clearAllBannerItemPullHistory() {
    return _bannerPullHistory.clear();
  }

  @override
  List<WishSimulatorBannerPullHistory> getBannerItemsPullHistoryPerType(BannerItemType bannerType) {
    return _bannerPullHistory.values.where((el) => el.bannerType == bannerType.index).toList()
      ..sort((x, y) => y.pulledOnDate.compareTo(x.pulledOnDate));
  }

  @override
  Future<BackupWishSimulatorModel> getDataForBackup() async {
    final pullHistory = <BackupWishSimulatorBannerPullHistory>[];
    final itemPullHistory = <BackupWishSimulatorBannerItemPullHistory>[];
    for (final type in BannerItemType.values) {
      final history = await getBannerPullHistoryCountPerType(type);
      pullHistory.add(BackupWishSimulatorBannerPullHistory(
        type: type,
        currentXStarCount: history.currentXStarCount,
        fiftyFiftyXStarGuaranteed: history.fiftyFiftyXStarGuaranteed,
      ));
    }

    //TODO: ITEMS
    return BackupWishSimulatorModel(pullHistory: pullHistory, itemPullHistory: itemPullHistory);
  }

  @override
  Future<void> restoreFromBackup(BackupWishSimulatorModel data) async {
    await deleteThemAll();
    final pullHistory = data.pullHistory
        .map(
          (e) => WishSimulatorBannerPullHistoryPerType(e.type.index, e.currentXStarCount, e.fiftyFiftyXStarGuaranteed),
        )
        .toList();

    //TODO: ITEMS
    await _bannerCountPerType.addAll(pullHistory);
  }
}
