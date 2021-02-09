import 'package:device_info/device_info.dart';
import 'package:genshindb/domain/services/device_info_service.dart';

class DeviceInfoServiceImpl implements DeviceInfoService {
  Map<String, String> _deviceInfo;

  @override
  Map<String, String> get deviceInfo => _deviceInfo;

  @override
  Future<void> init() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      _deviceInfo = {
        'model': androidInfo.model,
        'os': '${androidInfo.version.sdkInt}',
      };
    } catch (ex) {
      _deviceInfo = {'model': 'N/A', 'os': 'N/A'};
    }
  }
}
