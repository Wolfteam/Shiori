import 'dart:io';

import 'package:flutter/services.dart';

const String _channelName = 'com.github.wolfteam.shiori';
const MethodChannel _appMethodChannel = MethodChannel(_channelName);

class AppMethodChannel {
  static Future<String?> getWebViewUserAgent() async {
    if (Platform.isWindows || Platform.isMacOS) {
      return null;
    }
    final String? value = await _appMethodChannel.invokeMethod<String?>('getWebViewUserAgent');
    return value?.replaceAll(RegExp('wv'), '');
  }
}
