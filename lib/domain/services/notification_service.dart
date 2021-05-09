import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class NotificationService {
  void init();

  //TODO: REMOVE THE PLUGIN DEPENDENCY FROM THIS LAYER
  Future<void> registerCallBacks({
    DidReceiveLocalNotificationCallback onIosReceiveLocalNotification,
    SelectNotificationCallback onSelectNotification,
  });

  Future<bool> requestIOSPermissions();

  Future<void> showNotification(int id, String title, String body, {String payload});

  Future<void> cancelNotification(int id);

  Future<void> cancelAllNotifications();

  Future<void> scheduleNotification(int id, String title, String body, DateTime toBeDeliveredOn);

  Future<void> scheduleDailyNotification(int id, String title, String body);

  Future<void> scheduleWeeklyNotification(int id, String title, String body, DateTime startingFrom);
}
