abstract class DeviceInfoService {
  Map<String, String> get deviceInfo;

  String get version;

  Future<void> init();
}
