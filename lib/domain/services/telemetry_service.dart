import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';

abstract class TelemetryService {
  Future<void> initTelemetry();

  Future<void> trackEventAsync(String name, [Map<String, String>? properties]);

  Future<void> trackCharacterLoaded(
    String value, {
    bool loadedFromName = true,
  });

  Future<void> trackWeaponLoaded(
    String value, {
    bool loadedFromName = true,
  });

  Future<void> trackArtifactLoaded(
    String value, {
    bool loadedFromName = true,
  });

  Future<void> trackAscensionMaterialsOpened();

  Future<void> trackUrlOpened(bool loadMap, bool loadWishSimulator, bool loadDailyCheckIn, bool networkAvailable);

  Future<void> trackCalculatorItemAscMaterialLoaded(String item);

  Future<void> trackTierListOpened();

  Future<void> trackInit(AppSettings settings);

  Future<void> trackGameCodesOpened();

  Future<void> trackTierListBuilderScreenShootTaken();

  Future<void> trackMaterialLoaded(
    String key, {
    bool loadedFromName = true,
  });

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
}
