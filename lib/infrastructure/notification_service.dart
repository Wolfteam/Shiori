import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/services/logging_service.dart';
import 'package:genshindb/domain/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const _channelId = 'genshindb_channel';
const _channelName = 'Notifications';
const _channelDescription = 'Notifications from the app';
const _largeIcon = 'genshin_db';

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
  Future<void> showNotification(int id, AppNotificationType type, String title, String body, {String payload}) {
    final specifics = _getPlatformChannelSpecifics(type, body);

    if (body.length < 40) {
      return _flutterLocalNotificationsPlugin.show(id, title, body, specifics, payload: payload);
    }

    return _flutterLocalNotificationsPlugin.show(id, title, body, specifics, payload: payload);
  }

  @override
  Future<void> cancelNotification(int id, AppNotificationType type) {
    return _flutterLocalNotificationsPlugin.cancel(id, tag: _getTagFromNotificationType(type));
  }

  @override
  Future<void> cancelAllNotifications() {
    return _flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Future<void> scheduleNotification(int id, AppNotificationType type, String title, String body, DateTime toBeDeliveredOn) async {
    final now = DateTime.now();
    if (toBeDeliveredOn.isBefore(now) || toBeDeliveredOn.isAtSameMomentAs(now)) {
      await showNotification(id, type, title, body);
      return;
    }
    final specifics = _getPlatformChannelSpecifics(type, body);
    final scheduledDate = tz.TZDateTime.from(toBeDeliveredOn, _location);
    return _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      specifics,
      uiLocalNotificationDateInterpretation: null,
      androidAllowWhileIdle: true,
    );
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
}
