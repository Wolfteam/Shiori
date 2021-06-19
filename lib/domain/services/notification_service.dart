import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:genshindb/domain/enums/enums.dart';

abstract class NotificationService {
  void init();

  //TODO: REMOVE THE PLUGIN DEPENDENCY FROM THIS LAYER
  Future<void> registerCallBacks({
    DidReceiveLocalNotificationCallback? onIosReceiveLocalNotification,
    SelectNotificationCallback? onSelectNotification,
  });

  Future<bool> requestIOSPermissions();

  Future<void> showNotification(int id, AppNotificationType type, String title, String body, {String? payload});

  Future<void> cancelNotification(int id, AppNotificationType type);

  Future<void> cancelAllNotifications();

  Future<void> scheduleNotification(int id, AppNotificationType type, String title, String body, DateTime toBeDeliveredOn);
}
