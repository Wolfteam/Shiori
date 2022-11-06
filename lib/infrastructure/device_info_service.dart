import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_user_agentx/flutter_user_agent.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:store_checker/store_checker.dart';
import 'package:version_tracker/version_tracker.dart';

class DeviceInfoServiceImpl implements DeviceInfoService {
  final Map<String, String> _deviceInfo = {};
  late String _version;
  late String _versionWithBuildNumber;
  late String _appName;
  late bool _versionChanged = false;
  late String _packageName;

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
  String? get userAgent => Platform.isWindows ? null : FlutterUserAgent.webViewUserAgent!.replaceAll(RegExp('wv'), '');

  @override
  Future<void> init() async {
    try {
      //TODO: BUILDNUMBER NOT SHOWING UP ON WINDOWS
      //TODO: VERSION DOES NOT MATCH THE ONE ON THE PUBSPEC
      final packageInfo = await PackageInfo.fromPlatform();
      _appName = packageInfo.appName;
      _version = packageInfo.version;
      _packageName = packageInfo.packageName;
      _versionWithBuildNumber = Platform.isWindows ? _version : '$_version+${packageInfo.buildNumber}';

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
      _version = _versionWithBuildNumber = _appName = _packageName = na;
      _setDefaultDeviceInfoProps(na, na);
    }
  }

  Future<void> _initForWindows() async {
    final deviceInfo = DeviceInfoPlugin();
    final info = await deviceInfo.windowsInfo;
    _setDefaultDeviceInfoProps(info.computerName, na);
  }

  Future<void> _initForAndroid() async {
    final deviceInfo = DeviceInfoPlugin();
    final info = await deviceInfo.androidInfo;
    final installationSource = await StoreChecker.getSource;
    final model = 'Model: ${info.model} --- Device: ${info.device} --- Manufacturer: ${info.manufacturer}';
    _setDefaultDeviceInfoProps(model, '${info.version.sdkInt}');
    _deviceInfo.putIfAbsent('IsPhysicalDevice', () => '${info.isPhysicalDevice}');
    _deviceInfo.putIfAbsent('InstallationSource', () => installationSource.name);
  }

  Future<void> _initVersionTracker() async {
    final vt = VersionTracker();
    await vt.track();
    _versionChanged = vt.isFirstLaunchForCurrentBuild ?? vt.isFirstLaunchForCurrentVersion ?? vt.isFirstLaunchEver ?? false;
  }

  void _setDefaultDeviceInfoProps(String model, String osVersion) {
    _deviceInfo.putIfAbsent('Model', () => model);
    _deviceInfo.putIfAbsent('OsVersion', () => osVersion);
    _deviceInfo.putIfAbsent('AppVersion', () => _versionWithBuildNumber);
    _deviceInfo.putIfAbsent('PackageName', () => _packageName);
  }
}
