import 'package:darq/darq.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shiori/domain/check.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/persistence/wish_simulator_data_service.dart';

class WishSimulatorDataServiceImpl implements WishSimulatorDataService {
  late Box<WishSimulatorBannerPullHistory> _pullHistory;
  late Box<WishSimulatorBannerItemPullHistory> _itemPullHistory;

  WishSimulatorDataServiceImpl();

  @override
  Future<void> init() async {
    _pullHistory = await Hive.openBox<WishSimulatorBannerPullHistory>('wishSimulatorBannerPullHistory');
    _itemPullHistory = await Hive.openBox<WishSimulatorBannerItemPullHistory>('wishSimulatorBannerItemPullHistory');
  }

  @override
  Future<void> deleteThemAll() {
    return Future.wait([_pullHistory.clear(), clearAllBannerItemPullHistory()]);
  }

  @override
  Future<WishSimulatorBannerPullHistory> getBannerPullHistory(BannerItemType type, {Map<int, int>? defaultXStarCount}) async {
    WishSimulatorBannerPullHistory? value = _pullHistory.values.firstWhereOrDefault((el) => el.type == type.index);
    if (value == null) {
      value = WishSimulatorBannerPullHistory.newOne(type, defaultXStarCount);
      await _pullHistory.add(value);
    }
    return value;
  }

  @override
  Future<void> saveBannerItemPullHistory(BannerItemType bannerType, String itemKey, ItemType itemType) async {
    Check.notEmpty(itemKey, 'itemKey');
    Check.inList(itemType, [ItemType.character, ItemType.weapon], 'itemType');

    final value =
        itemType == ItemType.character
            ? WishSimulatorBannerItemPullHistory.character(bannerType, itemKey)
            : WishSimulatorBannerItemPullHistory.weapon(bannerType, itemKey);
    await _itemPullHistory.add(value);

    const int maxCount = 5000;
    if (_itemPullHistory.values.length > maxCount) {
      await _itemPullHistory.deleteAt(maxCount - 1);
    }
  }

  @override
  Future<void> clearBannerItemPullHistory(BannerItemType bannerType) async {
    final keys = _itemPullHistory.values.where((el) => el.bannerType == bannerType.index).map((e) => e.key).toList();
    if (keys.isNotEmpty) {
      await _itemPullHistory.deleteAll(keys);
    }
  }

  @override
  Future<void> clearAllBannerItemPullHistory() {
    return _itemPullHistory.clear();
  }

  @override
  List<WishSimulatorBannerItemPullHistory> getBannerItemsPullHistoryPerType(BannerItemType bannerType) {
    return _itemPullHistory.values.where((el) => el.bannerType == bannerType.index).toList()
      ..sort((x, y) => y.pulledOnDate.compareTo(x.pulledOnDate));
  }

  @override
  Future<BackupWishSimulatorModel> getDataForBackup() async {
    final pullHistory = <BackupWishSimulatorBannerPullHistory>[];
    final itemPullHistory = <BackupWishSimulatorBannerItemPullHistory>[];
    for (final type in BannerItemType.values) {
      final history = await getBannerPullHistory(type);
      pullHistory.add(
        BackupWishSimulatorBannerPullHistory(
          type: type,
          currentXStarCount: history.currentXStarCount,
          fiftyFiftyXStarGuaranteed: history.fiftyFiftyXStarGuaranteed,
        ),
      );

      final pulledItems = getBannerItemsPullHistoryPerType(type).map(
        (e) => BackupWishSimulatorBannerItemPullHistory(
          bannerType: type,
          itemKey: e.itemKey,
          itemType: ItemType.values[e.itemType],
          pulledOn: e.pulledOnDate,
        ),
      );

      itemPullHistory.addAll(pulledItems);
    }

    return BackupWishSimulatorModel(pullHistory: pullHistory, itemPullHistory: itemPullHistory);
  }

  @override
  Future<void> restoreFromBackup(BackupWishSimulatorModel data) async {
    await deleteThemAll();
    final pullHistory = data.pullHistory.map((e) => WishSimulatorBannerPullHistory(e.type.index, e.currentXStarCount, e.fiftyFiftyXStarGuaranteed));
    await _pullHistory.addAll(pullHistory);

    final pulledItems = data.itemPullHistory.map(
      (e) => WishSimulatorBannerItemPullHistory(e.bannerType.index, e.itemType.index, e.itemKey, e.pulledOn),
    );
    await _itemPullHistory.addAll(pulledItems);
  }
}
