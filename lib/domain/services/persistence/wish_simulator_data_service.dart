import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/persistence/base_data_service.dart';

abstract class WishSimulatorDataService implements BaseDataService {
  Future<WishSimulatorBannerPullHistoryPerType> getBannerPullHistoryCountPerType(BannerItemType type);

  Future<void> saveBannerItemPullHistory(BannerItemType bannerType, String itemKey, ItemType itemType);

  Future<void> clearBannerItemPullHistory(BannerItemType bannerType);

  Future<void> clearAllBannerItemPullHistory();

  List<WishSimulatorBannerPullHistory> getBannerItemsPullHistoryPerType(BannerItemType bannerType);

  Future<BackupWishSimulatorModel> getDataForBackup();

  Future<void> restoreFromBackup(BackupWishSimulatorModel data);
}
