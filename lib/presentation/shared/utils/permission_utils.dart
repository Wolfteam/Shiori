import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static final bool _isPlatformSupported = [Platform.isAndroid, Platform.isIOS].any((el) => el);

  static Future<bool> isStoragePermissionGranted() async {
    if (!_isPlatformSupported) {
      return false;
    }

    // No need to ask this permission on Android 13 (API 33)
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
      if (info.version.sdkInt >= 33) {
        return true;
      }
    }
    if (!await Permission.storage.request().isGranted) {
      // pop up to redirect user to phone settings
      openAppSettings();
      return false;
    }
    return true;
  }
}
