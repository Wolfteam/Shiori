import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/infrastructure/app_infra_constants.dart';
import 'package:store_checker/store_checker.dart';
import 'package:version_tracker/version_tracker.dart';

class DeviceInfoServiceImpl implements DeviceInfoService {
  final Map<String, String> _deviceInfo = {};
  final Map<String, String> _appInfo = {};
  late String _version;
  late String _versionWithBuildNumber;
  late String _appName;
  late bool _versionChanged = false;
  late String _packageName;
  Source? _installationSource;
  String? _buildNumber;
  String? _userAgent;

  @override
  Map<String, String> get deviceInfo => _deviceInfo;

  @override
  Map<String, String> get appInfo => _appInfo;

  @override
  String get appName => _appName;

  @override
  String get version => _version;

  @override
  String get versionWithBuildNumber => _versionWithBuildNumber;

  @override
  bool get versionChanged => _versionChanged;

  @override
  String? get userAgent => _userAgent;

  @override
  bool get installedFromValidSource {
    if (Platform.isWindows) {
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
      final packageInfo = await PackageInfo.fromPlatform();
      _appName = packageInfo.appName;
      _version = packageInfo.version;
      _packageName = packageInfo.packageName;
      _versionWithBuildNumber = '$_version+${packageInfo.buildNumber}';
      _buildNumber = packageInfo.buildNumber;
      _userAgent = await AppMethodChannel.getWebViewUserAgent();

      await _setAppInfoProps();

      final vt = VersionTracker();
      await vt.track();
      _versionChanged = vt.isFirstLaunchForCurrentBuild ?? vt.isFirstLaunchForCurrentVersion ?? vt.isFirstLaunchEver ?? false;

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
    } catch (ex) {
      _version = _versionWithBuildNumber = _appName = _packageName = na;
      _setDefaultDeviceInfoProps(na, na);
    }
  }

  Future<void> _initForWindows() async {
    final deviceInfo = DeviceInfoPlugin();
    final info = await deviceInfo.windowsInfo;
    final osVersion = '${info.productName}: ${info.displayVersion}';
    _setDefaultDeviceInfoProps(null, osVersion);
  }

  Future<void> _initForAndroid() async {
    final deviceInfo = DeviceInfoPlugin();
    final info = await deviceInfo.androidInfo;
    _setDefaultDeviceInfoProps(info.model, '${info.version.sdkInt}', info.manufacturer, info.isPhysicalDevice);
    _deviceInfo.putIfAbsent('device', () => info.device);
  }

  Future<void> _initForIOs() async {
    final deviceInfo = DeviceInfoPlugin();
    final info = await deviceInfo.iosInfo;
    final osVersion = '${info.systemName}: ${info.systemVersion}';
    _setDefaultDeviceInfoProps(info.model, osVersion, 'Apple', info.isPhysicalDevice);
  }

  Future<void> _initForMac() async {
    final deviceInfo = DeviceInfoPlugin();
    final info = await deviceInfo.macOsInfo;
    _setDefaultDeviceInfoProps(info.model, info.osRelease, 'Apple');
  }

  void _setDefaultDeviceInfoProps(String? model, String osVersion, [String? manufacturer, bool? isPhysicalDevice]) {
    if (model.isNotNullEmptyOrWhitespace) {
      _deviceInfo.putIfAbsent('model', () => model!);
    }
    _deviceInfo.putIfAbsent('osVersion', () => osVersion);
    _deviceInfo.putIfAbsent('platform', () => Platform.operatingSystem);

    if (manufacturer.isNotNullEmptyOrWhitespace) {
      _deviceInfo.putIfAbsent('manufacturer', () => manufacturer!);
    }

    if (isPhysicalDevice != null) {
      _deviceInfo.putIfAbsent('isPhysicalDevice', () => '$isPhysicalDevice');
    }
  }

  Future<void> _setAppInfoProps() async {
    _appInfo.putIfAbsent('version', () => _version);
    _appInfo.putIfAbsent('packageName', () => _packageName);
    if (_buildNumber.isNotNullEmptyOrWhitespace) {
      _appInfo.putIfAbsent('buildNumber', () => _buildNumber!);
    }

    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      final installationSource = await StoreChecker.getSource;
      _installationSource = installationSource;
      _appInfo.putIfAbsent('installationSource', () => installationSource.name);
    }
  }
}
