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
  Future<WishSimulatorBannerPullHistoryPerType> getBannerPullHistoryPerType(BannerItemType type) async {
    WishSimulatorBannerPullHistoryPerType? value = _bannerCountPerType.values.firstWhereOrDefault((el) => el.type == type.index);
    if (value == null) {
      value = WishSimulatorBannerPullHistoryPerType.newOne(type);
      await _bannerCountPerType.add(value);
    }
    return value;
  }

  @override
  Future<void> saveBannerItemPullHistory(String bannerKey, String itemKey, ItemType itemType) {
    if (bannerKey.isNullEmptyOrWhitespace) {
      throw Exception('Invalid bannerKey');
    }

    if (itemKey.isNullEmptyOrWhitespace) {
      throw Exception('Invalid itemKey');
    }

    if (itemType != ItemType.character || itemType != ItemType.weapon) {
      throw Exception('The provided itemT1ype = $itemType is not valid');
    }

    WishSimulatorBannerPullHistory? value = _bannerPullHistory.values.firstWhereOrDefault(
      (el) => el.bannerKey == bannerKey && el.itemKey == itemKey && el.itemType == itemType.index,
    );

    if (value == null) {
      value = itemType == ItemType.character
          ? WishSimulatorBannerPullHistory.character(bannerKey, itemKey)
          : WishSimulatorBannerPullHistory.weapon(bannerKey, itemKey);
      return _bannerPullHistory.add(value);
    }

    value.itemCount++;
    value.pulledOnDates.add(DateTime.now().toUtc());
    return value.save();
  }

  @override
  Future<void> clearBannerItemPullHistory(String bannerKey) async {
    if (bannerKey.isNullEmptyOrWhitespace) {
      throw Exception('Invalid bannerKey');
    }

    final keys = _bannerPullHistory.values.where((el) => el.bannerKey == bannerKey).map((e) => e.key).toList();
    if (keys.isNotEmpty) {
      await _bannerPullHistory.deleteAll(keys);
    }
  }

  @override
  Future<void> clearAllBannerItemPullHistory() {
    return _bannerPullHistory.clear();
  }

  @override
  List<WishSimulatorBannerItemPullHistoryModel> getBannerItemsPullFlatHistory(String bannerKey) {
    if (bannerKey.isNullEmptyOrWhitespace) {
      throw Exception('Invalid bannerKey');
    }

    final items = <WishSimulatorBannerItemPullHistoryModel>[];
    final history = _bannerPullHistory.values.where((el) => el.bannerKey == bannerKey).toList();
    for (final itemHistory in history) {
      final key = itemHistory.itemKey;
      final type = ItemType.values[itemHistory.itemType];
      for (final date in itemHistory.pulledOnDates) {
        items.add(WishSimulatorBannerItemPullHistoryModel(key: key, type: type, pulledOn: date));
      }
    }

    return items..sort((x, y) => y.pulledOn.compareTo(x.pulledOn));
  }
}
