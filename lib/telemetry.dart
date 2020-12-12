import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';

import 'secrets.dart';

//Only call this function from the main.dart
Future<void> initTelemetry() async {
  final isAnalyticsEnalbed = await AppCenter.isAnalyticsEnabledAsync();
  final isCrashesEnabled = await AppCenter.isCrashesEnabledAsync();

  if (isAnalyticsEnalbed && isCrashesEnabled) {
    return;
  }

  await AppCenter.startAsync(appSecretAndroid: Secrets.appCenterKey, appSecretIOS: '');
}

Future<void> trackEventAsync(String name, [Map<String, String> properties]) {
  return AppCenter.trackEventAsync(name, properties);
}
