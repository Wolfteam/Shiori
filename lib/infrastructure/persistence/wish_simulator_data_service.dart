import 'package:darq/darq.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/persistence/wish_simulator_data_service.dart';

class WishSimulatorDataServiceImpl implements WishSimulatorDataService {
  late final Box<WishSimulatorBannerPullHistory> _pullHistory;
  late final Box<WishSimulatorBannerItemPullHistory> _itemPullHistory;

  WishSimulatorDataServiceImpl();

  @override
  Future<void> init() async {
    _pullHistory = await Hive.openBox<WishSimulatorBannerPullHistory>('wishSimulatorBannerPullHistory');
    _itemPullHistory = await Hive.openBox<WishSimulatorBannerItemPullHistory>('wishSimulatorBannerItemPullHistory');
  }

  @override
  Future<void> deleteThemAll() {
    return Future.wait([
      _pullHistory.clear(),
      clearAllBannerItemPullHistory(),
    ]);
  }

  @override
  Future<WishSimulatorBannerPullHistory> getBannerPullHistory(BannerItemType type) async {
    WishSimulatorBannerPullHistory? value = _pullHistory.values.firstWhereOrDefault((el) => el.type == type.index);
    if (value == null) {
      value = WishSimulatorBannerPullHistory.newOne(type);
      await _pullHistory.add(value);
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
        ? WishSimulatorBannerItemPullHistory.character(bannerType, itemKey)
        : WishSimulatorBannerItemPullHistory.weapon(bannerType, itemKey);
    return _itemPullHistory.add(value);
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
    final pullHistory = data.pullHistory
        .map((e) => WishSimulatorBannerPullHistory(e.type.index, e.currentXStarCount, e.fiftyFiftyXStarGuaranteed))
        .toList();
    await _pullHistory.addAll(pullHistory);

    final pulledItems = data.itemPullHistory
        .map((e) => WishSimulatorBannerItemPullHistory(e.bannerType.index, e.itemType.index, e.itemKey, e.pulledOn))
        .toList();
    await _itemPullHistory.addAll(pulledItems);
  }
}
