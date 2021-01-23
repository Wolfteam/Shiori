import 'flutter_appcenter_bundle.dart';
import 'secrets.dart';

//Only call this function from the main.dart
Future<void> initTelemetry() async {
  await AppCenter.startAsync(appSecretAndroid: Secrets.appCenterKey, appSecretIOS: '');
}

Future<void> trackEventAsync(String name, [Map<String, String> properties]) {
  return AppCenter.trackEventAsync(name, properties);
}

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

Future<void> trackAscentionMaterialsOpened() async {
  await trackEventAsync('AscentionMaterials-Opened');
}

Future<void> trackUrlOpened(bool loadMap, bool loadWishSimulator, bool networkAvailable) async {
  await trackEventAsync('Url-Opened', {
    'Map': loadMap.toString(),
    'WishSimulator': loadWishSimulator.toString(),
    'NetworkAvailable': networkAvailable.toString(),
  });
}

Future<void> trackCalculatorItemAscMaterialLoaded(String item) async {
  await trackEventAsync('Calculator-Asc-Mat', {
    'Name': item,
  });
}
