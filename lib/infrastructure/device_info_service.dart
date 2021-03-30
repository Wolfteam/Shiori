import 'package:device_info/device_info.dart';
import 'package:genshindb/domain/services/device_info_service.dart';
import 'package:package_info/package_info.dart';

class DeviceInfoServiceImpl implements DeviceInfoService {
  Map<String, String> _deviceInfo;
  String _version;

  @override
  Map<String, String> get deviceInfo => _deviceInfo;

  @override
  String get version => _version;

  @override
  Future<void> init() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final packageInfo = await PackageInfo.fromPlatform();
      _version = packageInfo.version;
      _deviceInfo = {
        'Model': androidInfo.model,
        'OsVersion': '${androidInfo.version.sdkInt}',
        'AppVersion': '${packageInfo.version}_${packageInfo.buildNumber}'
      };
    } catch (ex) {
      _deviceInfo = {'Model': 'N/A', 'OsVersion': 'N/A', 'AppVersion': 'N/A'};
      _version = 'N/A';
    }
  }
}
