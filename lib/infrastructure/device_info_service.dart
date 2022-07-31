import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_user_agentx/flutter_user_agent.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:version_tracker/version_tracker.dart';

class DeviceInfoServiceImpl implements DeviceInfoService {
  late Map<String, String> _deviceInfo;
  late String _version;
  late String _versionWithBuildNumber;
  late String _appName;
  late bool _versionChanged = false;

  @override
  Map<String, String> get deviceInfo => _deviceInfo;

  @override
  String get appName => _appName;

  @override
  String get version => _version;

  @override
  String get versionWithBuildNumber => _versionWithBuildNumber;

  @override
  bool get versionChanged => _versionChanged;

  //TODO: COMPLETE THIS
  @override
  String? get userAgent => Platform.isWindows ? null : FlutterUserAgent.webViewUserAgent!.replaceAll(RegExp(r'wv'), '');

  @override
  Future<void> init() async {
    try {
      //TODO: BUILDNUMBER NOT SHOWING UP ON WINDOWS
      //TODO: VERSION DOES NOT MATCH THE ONE ON THE PUBSPEC
      final packageInfo = await PackageInfo.fromPlatform();
      _appName = packageInfo.appName;
      _version = packageInfo.version;
      _versionWithBuildNumber = Platform.isWindows ? packageInfo.version : '${packageInfo.version}+${packageInfo.buildNumber}';

      await _initVersionTracker();

      if (Platform.isAndroid) {
        await _initForAndroid();
      }

      if (Platform.isWindows) {
        await _initForWindows();
      }

      if (!Platform.isWindows) {
        await FlutterUserAgent.init();
      }
    } catch (ex) {
      _deviceInfo = {
        'Model': 'N/A',
        'OsVersion': 'N/A',
        'AppVersion': 'N/A',
      };
      _version = _versionWithBuildNumber = _appName = 'N/A';
    }
  }

  Future<void> _initForWindows() async {
    final deviceInfo = DeviceInfoPlugin();
    final info = await deviceInfo.windowsInfo;
    final model = info.computerName;
    _deviceInfo = {
      'Model': model,
      'OsVersion': 'N/A',
      'AppVersion': _versionWithBuildNumber,
    };
  }

  Future<void> _initForAndroid() async {
    final deviceInfo = DeviceInfoPlugin();
    final info = await deviceInfo.androidInfo;
    _deviceInfo = {
      'Model': info.model ?? 'N/A',
      'OsVersion': '${info.version.sdkInt}',
      'AppVersion': _versionWithBuildNumber,
    };
  }

  Future<void> _initVersionTracker() async {
    final vt = VersionTracker();
    await vt.track();
    _versionChanged = vt.isFirstLaunchForCurrentBuild ?? vt.isFirstLaunchForCurrentVersion ?? vt.isFirstLaunchEver ?? false;
  }
}
