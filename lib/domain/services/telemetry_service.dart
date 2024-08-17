import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/settings_service.dart';

abstract class TelemetryService {
  void init(SettingsService settingsService, DataService dataService);

  Future<void> trackEventAsync(String name, [Map<String, dynamic>? properties]);

  Future<void> trackCharacterLoaded(String value);

  Future<void> trackWeaponLoaded(String value);

  Future<void> trackArtifactLoaded(String value);

  Future<void> trackAscensionMaterialsOpened();

  Future<void> trackUrlOpened(bool loadMap, bool loadDailyCheckIn, bool networkAvailable);

  Future<void> trackCalculatorItemAscMaterialLoaded(String key);

  Future<void> trackTierListOpened();

  Future<void> trackInit(AppSettings settings);

  Future<void> trackGameCodesOpened();

  Future<void> trackTierListBuilderScreenShootTaken();

  Future<void> trackMaterialLoaded(String key);

  Future<void> trackCalculatorAscMaterialsSessionsLoaded();

  Future<void> trackCalculatorAscMaterialsSessionsCreated();

  Future<void> trackCalculatorAscMaterialsSessionsUpdated();

  Future<void> trackCalculatorAscMaterialsSessionsDeleted({bool all = false});

  Future<void> trackItemAddedToInventory(String key, int quantity);

  Future<void> trackItemUpdatedInInventory(String key, int quantity);

  Future<void> trackItemDeletedFromInventory(String key);

  Future<void> trackItemsDeletedFromInventory(ItemType type);

  Future<void> trackNotificationCreated(AppNotificationType type);

  Future<void> trackNotificationUpdated(AppNotificationType type);

  Future<void> trackNotificationDeleted(AppNotificationType type);

  Future<void> trackNotificationRestarted(AppNotificationType type);

  Future<void> trackNotificationStopped(AppNotificationType type);

  Future<void> trackCustomBuildSaved(String charKey, CharacterRoleType roleType, CharacterRoleSubType subType);

  Future<void> trackCustomBuildScreenShootTaken(String charKey, CharacterRoleType roleType, CharacterRoleSubType subType);

  Future<void> trackRestore(bool succeed);

  Future<void> trackPurchase(String identifier, bool succeed);

  Future<void> trackBannerHistoryOpened();

  Future<void> trackBannerHistoryItemOpened(double version);

  Future<void> trackItemReleaseHistoryOpened(String itemKey);

  Future<void> trackChartsOpened();

  Future<void> trackBirthdaysPerMonthOpened(int month);

  Future<void> trackCheckForResourceUpdates(AppResourceUpdateResultType result);

  Future<void> trackResourceUpdateDownload(int targetResourceVersion);

  Future<void> trackResourceUpdateCompleted(bool applied, int targetResourceVersion);

  Future<void> trackBackupCreated(bool succeed);

  Future<void> trackBackupRestored(bool succeed);

  Future<void> trackWishSimulatorOpened(double version);

  Future<void> trackWishSimulatorResult(int bannerIndex, double version, BannerItemType type, String range);
}
