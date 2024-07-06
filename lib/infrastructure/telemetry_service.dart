import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

class TelemetryServiceImpl implements TelemetryService {
  final DeviceInfoService _deviceInfoService;
  DataService? _dataService;

  TelemetryServiceImpl(this._deviceInfoService);

  @override
  void init(DataService dataService) {
    _dataService = dataService;
  }

  @override
  Future<void> trackEventAsync(String name, [Map<String, dynamic>? properties]) {
    final data = <String, dynamic>{};
    data['event'] = name;
    data['deviceInfo'] = _deviceInfoService.deviceInfo;
    data['data'] = properties;

    if (_deviceInfoService.installedFromValidSource) {
      return _dataService?.telemetry.saveTelemetry(data) ?? Future.value();
    }
    return Future.value();
  }

  @override
  Future<void> trackCharacterLoaded(String value) {
    return trackEventAsync('Character_FromKey', <String, dynamic>{}.addKey(value));
  }

  @override
  Future<void> trackWeaponLoaded(String value) {
    return trackEventAsync('Weapon_FromKey', <String, dynamic>{}.addKey(value));
  }

  @override
  Future<void> trackArtifactLoaded(String value) {
    return trackEventAsync('Artifact_FromKey', <String, dynamic>{}.addKey(value));
  }

  @override
  Future<void> trackAscensionMaterialsOpened() {
    return trackEventAsync('AscensionMaterials_Opened');
  }

  @override
  Future<void> trackUrlOpened(bool loadMap, bool loadDailyCheckIn, bool networkAvailable) {
    final props = {'networkAvailable': networkAvailable};

    if (loadMap) {
      return trackEventAsync('Map_Opened', props);
    }
    if (loadDailyCheckIn) {
      return trackEventAsync('DailyCheckIn_Opened', props);
    }

    return Future.value();
  }

  @override
  Future<void> trackCalculatorItemAscMaterialLoaded(String key) {
    return trackEventAsync('Calculator_Asc_Mat', <String, dynamic>{}.addKey(key));
  }

  @override
  Future<void> trackTierListOpened() {
    return trackEventAsync('TierListBuilder_Opened');
  }

  @override
  Future<void> trackInit(AppSettings settings) {
    return trackEventAsync('Init', settings.toJson());
  }

  @override
  Future<void> trackGameCodesOpened() {
    return trackEventAsync('GameCodes_Opened');
  }

  @override
  Future<void> trackTierListBuilderScreenShootTaken() {
    return trackEventAsync('TierListBuilder_ScreenShootTaken');
  }

  @override
  Future<void> trackMaterialLoaded(String key) {
    return trackEventAsync('Material_FromKey', <String, dynamic>{}.addKey(key));
  }

  @override
  Future<void> trackCalculatorAscMaterialsSessionsLoaded() {
    return trackEventAsync('Calculator_Asc_Mat_Sessions_Loaded');
  }

  @override
  Future<void> trackCalculatorAscMaterialsSessionsCreated() {
    return trackEventAsync('Calculator_Asc_Mat_Sessions_Created');
  }

  @override
  Future<void> trackCalculatorAscMaterialsSessionsUpdated() {
    return trackEventAsync('Calculator_Asc_Mat_Sessions_Updated');
  }

  @override
  Future<void> trackCalculatorAscMaterialsSessionsDeleted({bool all = false}) {
    return trackEventAsync('Calculator_Asc_Mat_Sessions_Deleted${all ? '_All' : ''}');
  }

  @override
  Future<void> trackItemAddedToInventory(String key, int quantity) {
    final props = <String, dynamic>{}.addKey(key).addQuantity(quantity);
    return trackEventAsync('MyInventory_Added', props);
  }

  @override
  Future<void> trackItemDeletedFromInventory(String key) {
    return trackEventAsync('MyInventory_Deleted', <String, dynamic>{}.addKey(key));
  }

  @override
  Future<void> trackItemUpdatedInInventory(String key, int quantity) {
    final props = <String, dynamic>{}.addKey(key).addQuantity(quantity);
    return trackEventAsync('MyInventory_Updated', props);
  }

  @override
  Future<void> trackItemsDeletedFromInventory(ItemType type) {
    return trackEventAsync('MyInventory_Clear_All', <String, dynamic>{}.addEnumTypeName(type));
  }

  @override
  Future<void> trackNotificationCreated(AppNotificationType type) {
    return trackEventAsync('Notification_Created', <String, dynamic>{}.addEnumTypeName(type));
  }

  @override
  Future<void> trackNotificationDeleted(AppNotificationType type) {
    return trackEventAsync('Notification_Deleted', <String, dynamic>{}.addEnumTypeName(type));
  }

  @override
  Future<void> trackNotificationRestarted(AppNotificationType type) {
    return trackEventAsync('Notification_Restarted', <String, dynamic>{}.addEnumTypeName(type));
  }

  @override
  Future<void> trackNotificationStopped(AppNotificationType type) {
    return trackEventAsync('Notification_Stopped', <String, dynamic>{}.addEnumTypeName(type));
  }

  @override
  Future<void> trackNotificationUpdated(AppNotificationType type) {
    return trackEventAsync('Notification_Updated', <String, dynamic>{}.addEnumTypeName(type));
  }

  @override
  Future<void> trackCustomBuildSaved(String charKey, CharacterRoleType roleType, CharacterRoleSubType subType) {
    final props = <String, dynamic>{}.addKey(charKey).addEnumTypeName(roleType, 'roleType').addEnumTypeName(subType, 'subType');
    return trackEventAsync('Custom_Build_Saved', props);
  }

  @override
  Future<void> trackCustomBuildScreenShootTaken(String charKey, CharacterRoleType roleType, CharacterRoleSubType subType) {
    final props = <String, dynamic>{}.addKey(charKey).addEnumTypeName(roleType, 'roleType').addEnumTypeName(subType, 'subType');
    return trackEventAsync('Custom_Build_ScreenShootTaken', props);
  }

  @override
  Future<void> trackPurchase(String identifier, bool succeed) {
    final props = <String, dynamic>{'identifier': identifier}.addSucceed(succeed);
    return trackEventAsync('Donations_Purchase', props);
  }

  @override
  Future<void> trackRestore(bool succeed) {
    return trackEventAsync('Donations_Restore', <String, dynamic>{}.addSucceed(succeed));
  }

  @override
  Future<void> trackBannerHistoryOpened() {
    return trackEventAsync('Banner_History_Opened');
  }

  @override
  Future<void> trackBannerHistoryItemOpened(double version) {
    return trackEventAsync('Banner_History_Item_Opened', {'version': version});
  }

  @override
  Future<void> trackItemReleaseHistoryOpened(String itemKey) {
    return trackEventAsync('Banner_History_Item_Release_History_Opened', <String, dynamic>{}.addKey(itemKey));
  }

  @override
  Future<void> trackChartsOpened() {
    return trackEventAsync('Charts_Opened');
  }

  @override
  Future<void> trackBirthdaysPerMonthOpened(int month) {
    return trackEventAsync('BirthdaysPerMonth_Opened', {'month': month});
  }

  @override
  Future<void> trackCheckForResourceUpdates(AppResourceUpdateResultType result) {
    return trackEventAsync('Resource_Updates_Check', <String, dynamic>{}.addEnumTypeName(result));
  }

  @override
  Future<void> trackResourceUpdateCompleted(bool applied, int targetResourceVersion) {
    return trackEventAsync(
      'Resource_Updates_Completed',
      {'applied': applied, 'targetResourceVersion': targetResourceVersion},
    );
  }

  @override
  Future<void> trackResourceUpdateDownload(int targetResourceVersion) {
    return trackEventAsync(
      'Resource_Updates_Download',
      {'targetResourceVersion': targetResourceVersion},
    );
  }

  @override
  Future<void> trackBackupCreated(bool succeed) {
    return trackEventAsync('Backup_Created', <String, dynamic>{}.addSucceed(succeed));
  }

  @override
  Future<void> trackBackupRestored(bool succeed) {
    return trackEventAsync('Backup_Restored', <String, dynamic>{}.addSucceed(succeed));
  }

  @override
  Future<void> trackWishSimulatorOpened(double version) {
    return trackEventAsync('WishSimulator_Opened', {'version': version});
  }

  @override
  Future<void> trackWishSimulatorResult(int bannerIndex, double version, BannerItemType type, String range) {
    final props = {
      'summary': '$version / ${type.name} / $bannerIndex',
      'version': '$version',
      'range': range,
      'bannerIndex': bannerIndex,
    }.addEnumTypeName(type);
    return trackEventAsync('WishSimulator_Result', props);
  }
}

extension _MapExtension on Map<String, dynamic> {
  Map<String, dynamic> addKey(String value) {
    putIfAbsent('key', () => value);
    return this;
  }

  Map<String, dynamic> addQuantity(int value) {
    putIfAbsent('quantity', () => value);
    return this;
  }

  Map<String, dynamic> addEnumTypeName(Enum value, [String? keyName]) {
    final String key = keyName ?? 'type';
    putIfAbsent(key, () => value.name);
    return this;
  }

  Map<String, dynamic> addSucceed(bool value) {
    putIfAbsent('succeed', () => value);
    return this;
  }
}
