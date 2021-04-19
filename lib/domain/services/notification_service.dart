import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class NotificationService {
  Future<void> setupNotifications({
    DidReceiveLocalNotificationCallback onIosReceiveLocalNotification,
    SelectNotificationCallback onSelectNotification,
  });

  Future<bool> requestIOSPermissions();

  Future<void> showNotification(String title, String body, String payload, {int id = 0});

  Future<void> cancelNotification(int id);

  Future<void> cancelAllNotifications();

  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime deliveredOn,
  );
}
