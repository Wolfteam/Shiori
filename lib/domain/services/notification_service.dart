import 'package:shiori/domain/enums/enums.dart';

abstract class NotificationService {
  Future<void> init();

  Future<void> showNotification(int id, AppNotificationType type, String title, String body, {String? payload});

  Future<void> cancelNotification(int id, AppNotificationType type);

  Future<void> cancelAllNotifications();

  Future<void> scheduleNotification(int id, AppNotificationType type, String title, String body, DateTime toBeDeliveredOn);
}
