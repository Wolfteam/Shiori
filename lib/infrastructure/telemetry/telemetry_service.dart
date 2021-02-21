import 'package:enum_to_string/enum_to_string.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/device_info_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';
import 'package:genshindb/infrastructure/telemetry/flutter_appcenter_bundle.dart';
import 'package:genshindb/infrastructure/telemetry/secrets.dart';

class TelemetryServiceImpl implements TelemetryService {
  final DeviceInfoService _deviceInfoService;

  TelemetryServiceImpl(this._deviceInfoService);

  //Only call this function from the main.dart
  @override
  Future<void> initTelemetry() async {
    await AppCenter.startAsync(appSecretAndroid: Secrets.appCenterKey, appSecretIOS: '');
  }

  @override
  Future<void> trackEventAsync(String name, [Map<String, String> properties]) {
    properties ??= {};
    properties.addAll(_deviceInfoService.deviceInfo);
    return AppCenter.trackEventAsync(name, properties);
  }

  @override
  Future<void> trackCharacterLoaded(
    String value, {
    bool loadedFromName = true,
  }) async {
    if (loadedFromName) {
      await trackEventAsync('Character-FromName', {'Name': value});
    } else {
      await trackEventAsync('Character-FromImg', {'Image': value});
    }
  }

  @override
  Future<void> trackWeaponLoaded(
    String value, {
    bool loadedFromName = true,
  }) async {
    if (loadedFromName) {
      await trackEventAsync('Weapon-FromName', {'Name': value});
    } else {
      await trackEventAsync('Weapon-FromImg', {'Image': value});
    }
  }

  @override
  Future<void> trackArtifactLoaded(
    String value, {
    bool loadedFromName = true,
  }) async {
    if (loadedFromName) {
      await trackEventAsync('Artifact-FromName', {'Name': value});
    } else {
      await trackEventAsync('Artifact-FromImg', {'Image': value});
    }
  }

  @override
  Future<void> trackAscensionMaterialsOpened() async {
    await trackEventAsync('AscensionMaterials-Opened');
  }

  @override
  Future<void> trackUrlOpened(bool loadMap, bool loadWishSimulator, bool networkAvailable) async {
    await trackEventAsync('Url-Opened', {
      'Map': loadMap.toString(),
      'WishSimulator': loadWishSimulator.toString(),
      'NetworkAvailable': networkAvailable.toString(),
    });
  }

  @override
  Future<void> trackCalculatorItemAscMaterialLoaded(String item) async {
    await trackEventAsync('Calculator-Asc-Mat', {
      'Name': item,
    });
  }

  @override
  Future<void> trackTierListOpened() async {
    await trackEventAsync('TierList-Opened');
  }

  @override
  Future<void> trackInit(AppSettings settings) async {
    await trackEventAsync('Init', {
      'Theme': EnumToString.convertToString(settings.appTheme),
      'AccentColor': EnumToString.convertToString(settings.accentColor),
      'Language': EnumToString.convertToString(settings.appLanguage),
      'ShowCharacterDetails': settings.showCharacterDetails.toString(),
      'ShowWeaponDetails': settings.showWeaponDetails.toString(),
      'IsFirstInstall': settings.isFirstInstall.toString(),
      'ServerResetTime': EnumToString.convertToString(settings.serverResetTime),
    });
  }
}
