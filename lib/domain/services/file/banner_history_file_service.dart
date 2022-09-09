import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/base_file_service.dart';

abstract class BannerHistoryFileService extends BaseFileService {
  List<double> getBannerHistoryVersions(SortDirectionType type);

  List<BannerHistoryItemModel> getBannerHistory(BannerHistoryItemType type);

  List<BannerHistoryPeriodModel> getBanners(double version);

  List<ItemReleaseHistoryModel> getItemReleaseHistory(String itemKey);

  List<ChartElementItemModel> getElementsForCharts(double fromVersion, double untilVersion);

  List<ChartTopItemModel> getTopCharts(bool mostReruns, ChartType type, BannerHistoryItemType bannerType, List<ItemCommonWithName> items);
}
