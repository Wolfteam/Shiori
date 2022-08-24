import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';

abstract class GenshinService {
  ArtifactFileService get artifacts;

  BannerHistoryFileService get bannerHistory;

  CharacterFileService get characters;

  ElementFileService get elements;

  FurnitureFileService get furniture;

  GadgetFileService get gadgets;

  MaterialFileService get materials;

  MonsterFileService get monsters;

  WeaponFileService get weapons;

  TranslationFileService get translations;

  Future<void> init(AppLanguageType languageType);

  int getServerDay(AppServerResetTimeType type);

  DateTime getServerDate(AppServerResetTimeType type);

  Duration getDurationUntilServerResetDate(AppServerResetTimeType type);

  List<String> getUpcomingKeys();

  String getItemImageFromNotificationType(String itemKey, AppNotificationType notificationType, {AppNotificationItemType? notificationItemType});

  String getItemImageFromNotificationItemType(String itemKey, AppNotificationItemType notificationItemType);

  DateTime getNextDateForWeeklyBoss(AppServerResetTimeType type);

  List<ChartTopItemModel> getTopCharts(ChartType type);

  List<ChartAscensionStatModel> getItemAscensionStatsForCharts(ItemType itemType);

  List<ItemCommonWithName> getItemsAscensionStats(StatType statType, ItemType itemType);
}
