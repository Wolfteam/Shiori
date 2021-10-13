import 'dart:io';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const _channelId = 'shiori_channel';
const _channelName = 'Notifications';
const _channelDescription = 'Notifications from the app';
const _largeIcon = 'shiori';

//Here we use this one in particular cause this tz uses UTC and does not use any kind of dst.
const _fallbackTimeZone = 'Africa/Accra';

class NotificationServiceImpl implements NotificationService {
  final LoggingService _loggingService;

  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  late tz.Location _location;

  NotificationServiceImpl(this._loggingService);

  @override
  Future<void> init() async {
    try {
      //TODO: TIMEZONES ON WINDWS
      if (Platform.isWindows) {
        return;
      }
      tz.initializeTimeZones();
      final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      _location = tz.getLocation(currentTimeZone);
      tz.setLocalLocation(_location);
    } on tz.LocationNotFoundException catch (e) {
      //https://github.com/srawlins/timezone/issues/92
      _loggingService.info(runtimeType, 'init: ${e.msg}, assigning the generic one...');
      _setDefaultTimeZone();
    } catch (e, s) {
      _loggingService.error(runtimeType, 'init: Failed to get timezone or device is GMT or UTC, assigning the generic one...', e, s);
      _setDefaultTimeZone();
    }
  }

  @override
  Future<void> registerCallBacks({
    DidReceiveLocalNotificationCallback? onIosReceiveLocalNotification,
    SelectNotificationCallback? onSelectNotification,
  }) async {
    try {
      if (Platform.isWindows) {
        return Future.value();
      }
      const initializationSettingsAndroid = AndroidInitializationSettings('ic_notification');
      final initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: onIosReceiveLocalNotification);
      final initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
    } catch (e, s) {
      _loggingService.error(runtimeType, 'registerCallBacks: Unknown error occurred', e, s);
    }
  }

  @override
  Future<bool> requestIOSPermissions() async {
    final specificImpl = _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final result = await specificImpl?.requestPermissions(alert: true, badge: true, sound: true);

    if (result == null) {
      return false;
    }

    return result;
  }

  @override
  Future<void> showNotification(int id, AppNotificationType type, String title, String body, {String? payload}) {
    if (Platform.isWindows) {
      return Future.value();
    }
    final specifics = _getPlatformChannelSpecifics(type, body);
    final newId = _generateUniqueId(id, type);
    return _flutterLocalNotificationsPlugin.show(newId, title, body, specifics, payload: payload);
  }

  @override
  Future<void> cancelNotification(int id, AppNotificationType type) {
    if (Platform.isWindows) {
      return Future.value();
    }
    final realId = _generateUniqueId(id, type);
    return _flutterLocalNotificationsPlugin.cancel(realId, tag: _getTagFromNotificationType(type));
  }

  @override
  Future<void> cancelAllNotifications() {
    if (Platform.isWindows) {
      return Future.value();
    }
    return _flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Future<void> scheduleNotification(int id, AppNotificationType type, String title, String body, DateTime toBeDeliveredOn) async {
    if (Platform.isWindows) {
      return;
    }
    final now = DateTime.now();
    final payload = '${id}_${_getTagFromNotificationType(type)}';
    if (toBeDeliveredOn.isBefore(now) || toBeDeliveredOn.isAtSameMomentAs(now)) {
      await showNotification(id, type, title, body, payload: payload);
      return;
    }
    final newId = _generateUniqueId(id, type);
    final specifics = _getPlatformChannelSpecifics(type, body);
    final scheduledDate = tz.TZDateTime.from(toBeDeliveredOn, _location);
    return _flutterLocalNotificationsPlugin.zonedSchedule(
      newId,
      title,
      body,
      scheduledDate,
      specifics,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: payload,
    );
  }

  void _setDefaultTimeZone() {
    _location = tz.getLocation(_fallbackTimeZone);
    tz.setLocalLocation(_location);
  }

  NotificationDetails _getPlatformChannelSpecifics(AppNotificationType type, String body) {
    final style = body.length < 40 ? null : BigTextStyleInformation(body);
    final _androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      color: Colors.red,
      styleInformation: style,
      largeIcon: const DrawableResourceAndroidBitmap(_largeIcon),
      tag: _getTagFromNotificationType(type),
    );
    const _iOSPlatformChannelSpecifics = IOSNotificationDetails();

    return NotificationDetails(android: _androidPlatformChannelSpecifics, iOS: _iOSPlatformChannelSpecifics);
  }

  String _getTagFromNotificationType(AppNotificationType type) {
    return EnumToString.convertToString(type);
  }

  // For some reason I need to provide a unique id even if I'm providing a custom tag
  // That's why we generate this id here
  int _generateUniqueId(int id, AppNotificationType type) {
    final prefix = _getIdPrefix(type).toString();
    final newId = '$prefix$id';
    return int.parse(newId);
  }

  int _getIdPrefix(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.resin:
        return 10;
      case AppNotificationType.expedition:
        return 20;
      case AppNotificationType.farmingMaterials:
        return 30;
      case AppNotificationType.farmingArtifacts:
        return 40;
      case AppNotificationType.gadget:
        return 50;
      case AppNotificationType.furniture:
        return 60;
      case AppNotificationType.realmCurrency:
        return 70;
      case AppNotificationType.weeklyBoss:
        return 80;
      case AppNotificationType.custom:
        return 90;
      case AppNotificationType.dailyCheckIn:
        return 100;
      default:
        throw Exception('The provided type = $type is not a valid notification type');
    }
  }
}
