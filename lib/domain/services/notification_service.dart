import 'dart:async';

import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

abstract class NotificationService {
  Future<void> init();

  Future<List<StreamSubscription>> initPushNotifications(PushNotificationTranslations translations);

  Future<void> showNotification(int id, AppNotificationType type, String title, String body, {String? payload});

  Future<void> showPushNotification(AppPushNotificationType type, PushNotificationTranslations translations, {String? payload});

  Future<void> cancelNotification(int id, AppNotificationType type);

  Future<void> cancelAllNotifications();

  Future<void> scheduleNotification(int id, AppNotificationType type, String title, String body, DateTime toBeDeliveredOn);
}
