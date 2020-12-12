import 'package:flutter_appcenter/flutter_appcenter.dart';

import 'secrets.dart';

Future<void> initTelemetry() async {
  await FlutterAppCenter.init(appSecretAndroid: Secrets.appCenterKey, tokenAndroid: 'N/A');
}
