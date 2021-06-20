abstract class DeviceInfoService {
  Map<String, String> get deviceInfo;

  String get appName;

  String get version;

  String? get userAgent;

  Future<void> init();
}
