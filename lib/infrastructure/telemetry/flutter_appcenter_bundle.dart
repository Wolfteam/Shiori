import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

const _methodChannelName = 'com.github.wolfteam.shiori';
const _methodChannel = MethodChannel(_methodChannelName);

/// Static class that provides AppCenter APIs
class AppCenter {
  /// Start appcenter functionalities
  static Future<void> startAsync({
    required String appSecretAndroid,
    required String appSecretIOS,
    bool enableAnalytics = true,
    bool enableCrashes = true,
    bool enableDistribute = false,
    bool usePrivateDistributeTrack = false,
  }) async {
    String appSecret;
    //TODO: COMPLETE THIS
    if (Platform.isWindows) {
      return;
    }
    if (Platform.isAndroid) {
      appSecret = appSecretAndroid;
    } else if (Platform.isIOS) {
      appSecret = appSecretIOS;
    } else {
      throw UnsupportedError('Current platform is not supported.');
    }

    if (appSecret.isEmpty) {
      return;
    }

    await configureAnalyticsAsync(enabled: enableAnalytics);
    await configureCrashesAsync(enabled: enableCrashes);

    await _methodChannel.invokeMethod('start', <String, dynamic>{
      'secret': appSecret.trim(),
      'usePrivateTrack': usePrivateDistributeTrack,
    });
  }

  /// Track events
  static Future<void> trackEventAsync(String name, [Map<String, String?>? properties]) async {
    if (Platform.isWindows) {
      return;
    }
    await _methodChannel.invokeMethod('trackEvent', <String, dynamic>{
      'name': name,
      'properties': properties ?? <String, String>{},
    });
  }

  /// Check whether analytics is enabled
  static Future<bool?> isAnalyticsEnabledAsync() async {
    if (Platform.isWindows) {
      return false;
    }
    return _methodChannel.invokeMethod('isAnalyticsEnabled');
  }

  /// Get app center installation id
  static Future<String> getInstallIdAsync() async {
    if (Platform.isWindows) {
      return 'N/A';
    }
    return _methodChannel.invokeMethod('getInstallId').then((r) => r as String);
  }

  /// Enable or disable analytics
  static Future configureAnalyticsAsync({required bool enabled}) async {
    if (Platform.isWindows) {
      return;
    }
    await _methodChannel.invokeMethod('configureAnalytics', enabled);
  }

  /// Check whether crashes is enabled
  static Future<bool?> isCrashesEnabledAsync() async {
    if (Platform.isWindows) {
      return false;
    }
    return _methodChannel.invokeMethod('isCrashesEnabled');
  }

  /// Enable or disable app center crash reports
  static Future configureCrashesAsync({required bool enabled}) async {
    if (Platform.isWindows) {
      return;
    }
    await _methodChannel.invokeMethod('configureCrashes', enabled);
  }
}
