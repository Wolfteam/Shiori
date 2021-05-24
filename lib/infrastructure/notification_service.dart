import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:genshindb/domain/services/logging_service.dart';
import 'package:genshindb/domain/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const _channelId = 'genshindb_channel';
const _channelName = 'Notifications';
const _channelDescription = 'Notifications from the app';
const _largeIcon = 'genshin_db';

const _androidPlatformChannelSpecifics = AndroidNotificationDetails(
  _channelId,
  _channelName,
  _channelDescription,
  importance: Importance.max,
  priority: Priority.high,
  enableLights: true,
  color: Colors.red,
  largeIcon: DrawableResourceAndroidBitmap(_largeIcon),
);

const _iOSPlatformChannelSpecifics = IOSNotificationDetails();

const _platformChannelSpecifics = NotificationDetails(android: _androidPlatformChannelSpecifics, iOS: _iOSPlatformChannelSpecifics);

class NotificationServiceImpl implements NotificationService {
  final LoggingService _loggingService;

  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  tz.Location _location;

  NotificationServiceImpl(this._loggingService);

  @override
  Future<void> init() async {
    try {
      tz.initializeTimeZones();
      final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      _location = tz.getLocation(currentTimeZone) ?? tz.local;
      tz.setLocalLocation(_location);
    } catch (e, s) {
      _loggingService.error(runtimeType, 'init: Unknown error occurred', e, s);
    }
  }

  @override
  Future<void> registerCallBacks({
    DidReceiveLocalNotificationCallback onIosReceiveLocalNotification,
    SelectNotificationCallback onSelectNotification,
  }) async {
    try {
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
  Future<void> showNotification(int id, String title, String body, {String payload}) {
    if (body.length < 40) {
      return _flutterLocalNotificationsPlugin.show(id, title, body, _platformChannelSpecifics, payload: payload);
    }

    final androidPlatformChannelSpecificsBigStyle = AndroidNotificationDetails(
      _channelId,
      _channelName,
      _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      color: Colors.red,
      styleInformation: BigTextStyleInformation(body),
      largeIcon: const DrawableResourceAndroidBitmap(_largeIcon),
    );

    final platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecificsBigStyle, iOS: _iOSPlatformChannelSpecifics);

    return _flutterLocalNotificationsPlugin.show(id, title, body, platformChannelSpecifics, payload: payload);
  }

  @override
  Future<void> cancelNotification(int id) {
    return _flutterLocalNotificationsPlugin.cancel(id);
  }

  @override
  Future<void> cancelAllNotifications() {
    return _flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Future<void> scheduleNotification(int id, String title, String body, DateTime toBeDeliveredOn) async {
    await init();
    final scheduledDate = tz.TZDateTime.from(toBeDeliveredOn, _location);
    return _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _platformChannelSpecifics,
      uiLocalNotificationDateInterpretation: null,
      androidAllowWhileIdle: true,
    );
  }

  @override
  Future<void> scheduleDailyNotification(int id, String title, String body) async {
    final now = DateTime.now();
    //Here we set now so the notification will appear starting from tomorrow
    return _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(now, _location),
      _platformChannelSpecifics,
      uiLocalNotificationDateInterpretation: null,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> scheduleWeeklyNotification(int id, String title, String body, DateTime startingFrom) async {
    return _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(startingFrom, _location),
      _platformChannelSpecifics,
      uiLocalNotificationDateInterpretation: null,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }
}
