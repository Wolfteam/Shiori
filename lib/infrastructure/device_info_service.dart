import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:genshindb/domain/services/device_info_service.dart';
import 'package:package_info/package_info.dart';

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

  //TODO: COMPLETE THIS
  @override
  String get userAgent => Platform.isWindows ? '' : FlutterUserAgent.webViewUserAgent.replaceAll(RegExp(r'wv'), '');

  @override
  Future<void> init() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final packageInfo = await PackageInfo.fromPlatform();
      _version = packageInfo.version;
      _appName = packageInfo.appName;
      _deviceInfo = {
        'Model': androidInfo.model,
        'OsVersion': '${androidInfo.version.sdkInt}',
        'AppVersion': '${packageInfo.version}+${packageInfo.buildNumber}'
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
