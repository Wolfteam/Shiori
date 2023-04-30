import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

const _methodChannelName = 'com.github.wolfteam.shiori';
const _methodChannel = MethodChannel(_methodChannelName);

/// Static class that provides AppCenter APIs
class AppCenter {
  static bool isPlatformSupported = [Platform.isAndroid, Platform.isIOS, Platform.isMacOS].any((el) => el);

  /// Start appcenter functionalities
  static Future<void> startAsync({
    required String appSecret,
    bool enableAnalytics = true,
    bool enableCrashes = true,
    bool usePrivateDistributeTrack = false,
  }) async {
    if (!isPlatformSupported) {
      return;
    }
    if (appSecret.isEmpty) {
      throw Exception('You need to provide the app center key');
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
    if (!isPlatformSupported) {
      return;
    }
    await _methodChannel.invokeMethod('trackEvent', <String, dynamic>{
      'name': name,
      'properties': properties ?? <String, String>{},
    });
  }

  /// Check whether analytics is enabled
  static Future<bool?> isAnalyticsEnabledAsync() async {
    if (!isPlatformSupported) {
      return false;
    }
    return _methodChannel.invokeMethod('isAnalyticsEnabled');
  }

  /// Get app center installation id
  static Future<String> getInstallIdAsync() async {
    if (!isPlatformSupported) {
      return 'N/A';
    }
    return _methodChannel.invokeMethod('getInstallId').then((r) => r as String);
  }

  /// Enable or disable analytics
  static Future configureAnalyticsAsync({required bool enabled}) async {
    if (!isPlatformSupported) {
      return;
    }
    await _methodChannel.invokeMethod('configureAnalytics', enabled);
  }

  /// Check whether crashes is enabled
  static Future<bool?> isCrashesEnabledAsync() async {
    if (!isPlatformSupported) {
      return false;
    }
    return _methodChannel.invokeMethod('isCrashesEnabled');
  }

  /// Enable or disable app center crash reports
  static Future configureCrashesAsync({required bool enabled}) async {
    if (!isPlatformSupported) {
      return;
    }
    await _methodChannel.invokeMethod('configureCrashes', enabled);
  }
}
