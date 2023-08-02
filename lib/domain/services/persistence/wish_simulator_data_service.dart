import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/services/persistence/base_data_service.dart';

abstract class WishSimulatorDataService implements BaseDataService {
  Future<WishSimulatorBannerCountPerType> getBannerCountPerType(BannerItemType type);

  Future<void> saveBannerItemPullHistory(String bannerKey, String itemKey, ItemType itemType);
}
