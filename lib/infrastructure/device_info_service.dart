import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
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
  Source? _installationSource;
  String? _buildNumber;

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
  String? get userAgent => Platform.isWindows || Platform.isMacOS ? null : FkUserAgent.webViewUserAgent!.replaceAll(RegExp('wv'), '');

  @override
  bool get installedFromValidSource {
    if (Platform.isWindows || Platform.isMacOS) {
      return true;
    }

    if (_installationSource == null) {
      return false;
    }

    final notValidSources = [Source.UNKNOWN, Source.IS_INSTALLED_FROM_OTHER_SOURCE];
    return !notValidSources.contains(_installationSource);
  }

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
      _buildNumber = packageInfo.buildNumber;

      await _initVersionTracker();

      if (Platform.isAndroid) {
        await _initForAndroid();
      }

      if (Platform.isWindows) {
        await _initForWindows();
      }

      if (Platform.isIOS) {
        await _initForIOs();
      }

      if (Platform.isMacOS) {
        await _initForMac();
      }

      if (!Platform.isWindows && !Platform.isMacOS) {
        await FkUserAgent.init();
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
    _setDefaultDeviceInfoProps(info.model, '${info.version.sdkInt}');
    _setOtherDeviceInfoProps(info.isPhysicalDevice);
    _deviceInfo.putIfAbsent('device', () => info.device);
    _deviceInfo.putIfAbsent('manufacturer', () => info.manufacturer);
  }

  Future<void> _initForIOs() async {
    final deviceInfo = DeviceInfoPlugin();
    final info = await deviceInfo.iosInfo;
    final osVersion = '${info.systemName}: ${info.systemVersion}';
    _setDefaultDeviceInfoProps(info.model, osVersion);
    _setOtherDeviceInfoProps(info.isPhysicalDevice);
  }

  Future<void> _initForMac() async {
    final deviceInfo = DeviceInfoPlugin();
    final info = await deviceInfo.macOsInfo;
    _setDefaultDeviceInfoProps(info.model, info.osRelease);
  }

  Future<void> _initVersionTracker() async {
    final vt = VersionTracker();
    await vt.track();
    _versionChanged = vt.isFirstLaunchForCurrentBuild ?? vt.isFirstLaunchForCurrentVersion ?? vt.isFirstLaunchEver ?? false;
  }

  void _setDefaultDeviceInfoProps(String model, String osVersion) {
    _deviceInfo.putIfAbsent('model', () => model);
    _deviceInfo.putIfAbsent('osVersion', () => osVersion);
    _deviceInfo.putIfAbsent('appVersion', () => _version);
    _deviceInfo.putIfAbsent('packageName', () => _packageName);
    if (_buildNumber.isNotNullEmptyOrWhitespace) {
      _deviceInfo.putIfAbsent('buildNumber', () => _buildNumber!);
    }
  }

  Future<void> _setOtherDeviceInfoProps(bool? isPhysicalDevice) async {
    _deviceInfo.putIfAbsent('isPhysicalDevice', () => '${isPhysicalDevice ?? na}');
    if (Platform.isAndroid || Platform.isIOS) {
      final installationSource = await StoreChecker.getSource;
      _installationSource = installationSource;
      _deviceInfo.putIfAbsent('installationSource', () => installationSource.name);
    }
  }
}
