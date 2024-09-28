import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
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
  static bool isPlatformSupported = [Platform.isAndroid, Platform.isIOS, Platform.isMacOS].any((el) => el);

  final LoggingService _loggingService;

  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  late tz.Location _location;

  NotificationServiceImpl(this._loggingService);

  @override
  Future<void> init() async {
    try {
      //TODO: TIMEZONES ON WINDOWS
      if (!isPlatformSupported) {
        return;
      }
      tz.initializeTimeZones();
      final currentTimeZone = await FlutterTimezone.getLocalTimezone();
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

    try {
      if (!Platform.isMacOS) {
        await Permission.notification.request();
      }

      const android = AndroidInitializationSettings('ic_notification');
      const iOS = DarwinInitializationSettings();
      const macOS = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(android: android, iOS: iOS, macOS: macOS);
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    } catch (e, s) {
      _loggingService.error(runtimeType, 'init: Unknown error occurred', e, s);
    }
  }

  @override
  Future<void> showNotification(int id, AppNotificationType type, String title, String body, {String? payload}) {
    if (!isPlatformSupported) {
      return Future.value();
    }
    final specifics = _getPlatformChannelSpecifics(type, body);
    final newId = _generateUniqueId(id, type);
    return _flutterLocalNotificationsPlugin.show(newId, title, body, specifics, payload: payload);
  }

  @override
  Future<void> cancelNotification(int id, AppNotificationType type) {
    if (!isPlatformSupported) {
      return Future.value();
    }
    final realId = _generateUniqueId(id, type);
    return _flutterLocalNotificationsPlugin.cancel(realId, tag: _getTagFromNotificationType(type));
  }

  @override
  Future<void> cancelAllNotifications() {
    if (!isPlatformSupported) {
      return Future.value();
    }
    return _flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Future<void> scheduleNotification(int id, AppNotificationType type, String title, String body, DateTime toBeDeliveredOn) async {
    if (!isPlatformSupported) {
      return;
    }
    //Due to changes starting from android 14, we need to request for special permissions...
    if (Platform.isAndroid) {
      final bool? granted = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
          .requestExactAlarmsPermission();

      if (granted == null || !granted) {
        return;
      }
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  void _setDefaultTimeZone() {
    _location = tz.getLocation(_fallbackTimeZone);
    tz.setLocalLocation(_location);
  }

  NotificationDetails _getPlatformChannelSpecifics(AppNotificationType type, String body) {
    final style = body.length < 40 ? null : BigTextStyleInformation(body);
    final android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      color: Colors.red,
      styleInformation: style,
      largeIcon: const DrawableResourceAndroidBitmap(_largeIcon),
      tag: _getTagFromNotificationType(type),
    );
    const iOS = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true, threadIdentifier: _channelId);
    const macOS = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true, threadIdentifier: _channelId);

    return NotificationDetails(android: android, iOS: iOS, macOS: macOS);
  }

  String _getTagFromNotificationType(AppNotificationType type) {
    return type.name;
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
