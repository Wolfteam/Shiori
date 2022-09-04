abstract class DeviceInfoService {
  Map<String, String> get deviceInfo;

  String get appName;

  String get version;

  String get versionWithBuildNumber;

  bool get versionChanged;

  String? get userAgent;

  String get versionWithBuildNumber;

  Future<void> init();
}
