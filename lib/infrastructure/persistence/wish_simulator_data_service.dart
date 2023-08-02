import 'package:darq/darq.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/services/persistence/wish_simulator_data_service.dart';

class WishSimulatorDataServiceImpl implements WishSimulatorDataService {
  late final Box<WishSimulatorBannerCountPerType> _bannerCountPerType;
  late final Box<WishSimulatorBannerPullHistory> _bannerPullHistory;

  WishSimulatorDataServiceImpl();

  @override
  Future<void> init() async {
    _bannerCountPerType = await Hive.openBox<WishSimulatorBannerCountPerType>('wishSimulatorBannerCountPerType');
    _bannerPullHistory = await Hive.openBox<WishSimulatorBannerPullHistory>('wishSimulatorBannerPullHistory');
  }

  @override
  Future<void> deleteThemAll() async {
    await _bannerCountPerType.clear();
  }

//TODO: RENAME TO WishSimulatorBannerPullHistoryPerType
  @override
  Future<WishSimulatorBannerCountPerType> getBannerCountPerType(BannerItemType type) async {
    WishSimulatorBannerCountPerType? value =
        _bannerCountPerType.values.firstWhereOrDefault((el) => el.type == type.index);
    if (value == null) {
      value = WishSimulatorBannerCountPerType(type: type);
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
}
