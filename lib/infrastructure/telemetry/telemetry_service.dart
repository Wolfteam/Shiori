import 'dart:io';

import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/env.dart';
import 'package:shiori/infrastructure/telemetry/flutter_appcenter_bundle.dart';

class TelemetryServiceImpl implements TelemetryService {
  final DeviceInfoService _deviceInfoService;

  TelemetryServiceImpl(this._deviceInfoService);

  //Only call this function from the main.dart
  @override
  Future<void> initTelemetry() async {
    String secret = '';
    if (Platform.isAndroid) {
      secret = Env.androidAppCenterKey;
    } else if (Platform.isIOS) {
      secret = Env.iosAppCenterKey;
    } else if (Platform.isMacOS) {
      secret = Env.macosAppCenterKey;
    }
    await AppCenter.startAsync(appSecret: secret);
  }

  @override
  Future<void> trackEventAsync(String name, [Map<String, String>? properties]) {
    properties ??= {};
    properties.addAll(_deviceInfoService.deviceInfo);

    if (_deviceInfoService.installedFromValidSource) {
      return AppCenter.trackEventAsync(name, properties);
    }
    return Future.value();
  }

  @override
  Future<void> trackCharacterLoaded(String value) async {
    await trackEventAsync('Character-FromKey', {'Key': value});
  }

  @override
  Future<void> trackWeaponLoaded(String value) async {
    await trackEventAsync('Weapon-FromKey', {'Key': value});
  }

  @override
  Future<void> trackArtifactLoaded(String value) async {
    await trackEventAsync('Artifact-FromKey', {'Key': value});
  }

  @override
  Future<void> trackAscensionMaterialsOpened() async {
    await trackEventAsync('AscensionMaterials-Opened');
  }

  @override
  Future<void> trackUrlOpened(bool loadMap, bool loadDailyCheckIn, bool networkAvailable) async {
    final props = {
      'NetworkAvailable': networkAvailable.toString(),
    };

    if (loadMap) {
      await trackEventAsync('Map-Opened', props);
    } else if (loadDailyCheckIn) {
      await trackEventAsync('DailyCheckIn-Opened', props);
    }
  }

  @override
  Future<void> trackCalculatorItemAscMaterialLoaded(String item) async {
    await trackEventAsync('Calculator-Asc-Mat', {
      'Name': item,
    });
  }

  @override
  Future<void> trackTierListOpened() => trackEventAsync('TierListBuilder-Opened');

  @override
  Future<void> trackInit(AppSettings settings) async {
    await trackEventAsync('Init', {
      'Theme': settings.appTheme.name,
      'AccentColor': settings.accentColor.name,
      'Language': settings.appLanguage.name,
      'ShowCharacterDetails': settings.showCharacterDetails.toString(),
      'ShowWeaponDetails': settings.showWeaponDetails.toString(),
      'IsFirstInstall': settings.isFirstInstall.toString(),
      'ServerResetTime': settings.serverResetTime.name,
      'DoubleBackToClose': settings.doubleBackToClose.toString(),
      'UseOfficialMap': settings.useOfficialMap.toString(),
      'ResourcesVersion': settings.resourceVersion.toString(),
    });
  }

  @override
  Future<void> trackGameCodesOpened() => trackEventAsync('GameCodes-Opened');

  @override
  Future<void> trackTierListBuilderScreenShootTaken() => trackEventAsync('TierListBuilder-ScreenShootTaken');

  @override
  Future<void> trackMaterialLoaded(String key) async {
    await trackEventAsync('Material-FromKey', {'Key': key});
  }

  @override
  Future<void> trackCalculatorAscMaterialsSessionsLoaded() => trackEventAsync('Calculator-Asc-Mat-Sessions-Loaded');

  @override
  Future<void> trackCalculatorAscMaterialsSessionsCreated() => trackEventAsync('Calculator-Asc-Mat-Sessions-Created');

  @override
  Future<void> trackCalculatorAscMaterialsSessionsUpdated() => trackEventAsync('Calculator-Asc-Mat-Sessions-Updated');

  @override
  Future<void> trackCalculatorAscMaterialsSessionsDeleted({bool all = false}) =>
      trackEventAsync('Calculator-Asc-Mat-Sessions-Deleted${all ? '-All' : ''}');

  @override
  Future<void> trackItemAddedToInventory(String key, int quantity) => trackEventAsync('MyInventory-Added', {'Key_Qty': '${key}_$quantity'});

  @override
  Future<void> trackItemDeletedFromInventory(String key) => trackEventAsync('MyInventory-Deleted', {'Key': key});

  @override
  Future<void> trackItemUpdatedInInventory(String key, int quantity) => trackEventAsync('MyInventory-Updated', {'Key_Qty': '${key}_$quantity'});

  @override
  Future<void> trackItemsDeletedFromInventory(ItemType type) => trackEventAsync('MyInventory-Clear-All', {'Type': type.name});

  @override
  Future<void> trackNotificationCreated(AppNotificationType type) => trackEventAsync('Notification-Created', {'Type': type.name});

  @override
  Future<void> trackNotificationDeleted(AppNotificationType type) => trackEventAsync('Notification-Deleted', {'Type': type.name});

  @override
  Future<void> trackNotificationRestarted(AppNotificationType type) => trackEventAsync('Notification-Restarted', {'Type': type.name});

  @override
  Future<void> trackNotificationStopped(AppNotificationType type) => trackEventAsync('Notification-Stopped', {'Type': type.name});

  @override
  Future<void> trackNotificationUpdated(AppNotificationType type) => trackEventAsync('Notification-Updated', {'Type': type.name});

  @override
  Future<void> trackCustomBuildSaved(String charKey, CharacterRoleType roleType, CharacterRoleSubType subType) => trackEventAsync(
        'Custom-Build-Saved',
        {'Char_RoleType_SubType': '${charKey}_${roleType.name}_${subType.name}'},
      );

  @override
  Future<void> trackCustomBuildScreenShootTaken(String charKey, CharacterRoleType roleType, CharacterRoleSubType subType) => trackEventAsync(
        'Custom-Build-ScreenShootTaken',
        {'Char_RoleType_SubType': '${charKey}_${roleType.name}_${subType.name}'},
      );

  @override
  Future<void> trackPurchase(String identifier, bool succeed) =>
      trackEventAsync('Donations-Purchase', {'UserId_Identifier_Succeed': '${identifier}_$succeed'});

  @override
  Future<void> trackRestore(bool succeed) => trackEventAsync('Donations-Restore', {'UserId_Succeed': '$succeed'});

  @override
  Future<void> trackBannerHistoryOpened() => trackEventAsync('Banner-History-Opened');

  @override
  Future<void> trackBannerHistoryItemOpened(double version) => trackEventAsync('Banner-History-Item-Opened', {'Version': '$version'});

  @override
  Future<void> trackItemReleaseHistoryOpened(String itemKey) => trackEventAsync('Banner-History-Item-Release-History-Opened', {'ItemKey': itemKey});

  @override
  Future<void> trackChartsOpened() => trackEventAsync('Charts-Opened');

  @override
  Future<void> trackBirthdaysPerMonthOpened(int month) => trackEventAsync('BirthdaysPerMonth-Opened', {'Month': '$month'});

  @override
  Future<void> trackCheckForResourceUpdates(AppResourceUpdateResultType result) => trackEventAsync('Resource-Updates-Check', {'Result': result.name});

  @override
  Future<void> trackResourceUpdateCompleted(bool applied, int targetResourceVersion) => trackEventAsync(
        'Resource-Updates-Completed',
        {'Applied': '$applied', 'TargetResourceVersion': '$targetResourceVersion'},
      );

  @override
  Future<void> trackResourceUpdateDownload(int targetResourceVersion) => trackEventAsync(
        'Resource-Updates-Download',
        {'TargetResourceVersion': '$targetResourceVersion'},
      );

  @override
  Future<void> trackBackupCreated(bool succeed) => trackEventAsync('Backup-Created', {'Succeed': '$succeed'});

  @override
  Future<void> trackBackupRestored(bool succeed) => trackEventAsync('Backup-Restored', {'Succeed': '$succeed'});

  @override
  Future<void> trackWishSimulatorOpened(double version) => trackEventAsync('WishSimulator-Opened', {'Version': '$version'});

  @override
  Future<void> trackWishSimulatorResult(int bannerIndex, double version, BannerItemType type, String range) => trackEventAsync(
        'WishSimulator-Result',
        {
          'Summary': '$version / ${type.name} / $bannerIndex',
          'Version': '$version',
          'Type': type.name,
          'Range': range,
        },
      );
}
