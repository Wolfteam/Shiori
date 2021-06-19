import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_user_agentx/flutter_user_agent.dart';
import 'package:genshindb/domain/services/device_info_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfoServiceImpl implements DeviceInfoService {
  Map<String, String> _deviceInfo;
  String _version;
  String _appName;

  @override
  Map<String, String> get deviceInfo => _deviceInfo;

  @override
  String get appName => _appName;

  @override
  String get version => _version;

  @override
  String get userAgent => Platform.isWindows ? null : FlutterUserAgent.webViewUserAgent.replaceAll(RegExp(r'wv'), '');

  @override
  Future<void> init() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final packageInfo = await PackageInfo.fromPlatform();
      _version = '${packageInfo.version}+${packageInfo.buildNumber}';
      _appName = packageInfo.appName;
      _deviceInfo = {
        'Model': androidInfo.model,
        'OsVersion': '${androidInfo.version.sdkInt}',
        'AppVersion': _version,
      };

      if (!Platform.isWindows) {
        await FlutterUserAgent.init();
      }
    } catch (ex) {
      _deviceInfo = {'Model': 'N/A', 'OsVersion': 'N/A', 'AppVersion': 'N/A'};
      _version = _appName = 'N/A';
    }
  }
}
