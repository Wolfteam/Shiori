abstract class DeviceInfoService {
  Map<String, String> get deviceInfo;

  Map<String, String> get appInfo;

  String get appName;

  String get version;

  String get versionWithBuildNumber;

  bool get versionChanged;

  String? get userAgent;

  bool get installedFromValidSource;

  Future<void> init();
}
