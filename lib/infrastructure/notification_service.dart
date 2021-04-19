import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:genshindb/domain/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const _channelId = 'genshindb_channel';
const _channelName = 'Notifications';
const _channelDescription = 'Notifications from the app';
const _largeIcon = 'cost';

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

const _platformChannelSpecifics = NotificationDetails(
  android: _androidPlatformChannelSpecifics,
  iOS: _iOSPlatformChannelSpecifics,
);

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  Future<void> setupNotifications({
    DidReceiveLocalNotificationCallback onIosReceiveLocalNotification,
    SelectNotificationCallback onSelectNotification,
  }) async {
    const initializationSettingsAndroid = AndroidInitializationSettings('ic_notification');
    final initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onIosReceiveLocalNotification,
    );
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );
  }

  @override
  Future<bool> requestIOSPermissions() async {
    final specificImpl = _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final result = await specificImpl?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (result == null) return false;

    return result;
  }

  @override
  Future<void> showNotification(String title, String body, String payload, {int id = 0}) {
    if (body.length > 40) {
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

      final _platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecificsBigStyle,
        iOS: _iOSPlatformChannelSpecifics,
      );

      return _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        _platformChannelSpecifics,
        payload: payload,
      );
    }
    return _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      _platformChannelSpecifics,
      payload: payload,
    );
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
  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime deliveredOn,
  ) async {
    final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    final location = tz.getLocation(currentTimeZone);

    return _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(deliveredOn, location),
      _platformChannelSpecifics,
      uiLocalNotificationDateInterpretation: null,
      androidAllowWhileIdle: true,
    );
  }
}
