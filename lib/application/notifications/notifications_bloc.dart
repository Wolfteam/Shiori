import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/notification_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'notifications_bloc.freezed.dart';
part 'notifications_event.dart';
part 'notifications_state.dart';

const _initialState = NotificationsState.initial(notifications: []);

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final DataService _dataService;
  final NotificationService _notificationService;
  final SettingsService _settingsService;
  final TelemetryService _telemetryService;

  NotificationsBloc(this._dataService, this._notificationService, this._settingsService, this._telemetryService)
    : super(_initialState);

  @override
  Stream<NotificationsState> mapEventToState(NotificationsEvent event) async* {
    switch (event) {
      case NotificationsEventInit():
        yield _buildInitialState();
      case NotificationsEventDelete():
        yield await _deleteNotification(event.id, event.type);
      case NotificationsEventReset():
        yield await _resetNotification(event.id, event.type);
      case NotificationsEventStop():
        yield await _stopNotification(event.id, event.type);
      case NotificationsEventReduceHour():
        yield await _reduceHours(event.id, event.type, event.hoursToReduce);
    }
  }

  NotificationsState _buildInitialState() {
    final notifications = _dataService.notifications.getAllNotifications();
    return NotificationsState.initial(
      notifications: notifications,
      useTwentyFourHoursFormat: _settingsService.useTwentyFourHoursFormat,
    );
  }

  Future<NotificationsState> _deleteNotification(int key, AppNotificationType type) async {
    await _dataService.notifications.deleteNotification(key, type);
    await _notificationService.cancelNotification(key, type);
    final notifications = [...state.notifications];
    notifications.removeWhere((el) => el.key == key && el.type == type);
    await _telemetryService.trackNotificationDeleted(type);
    return state.copyWith.call(notifications: notifications);
  }

  Future<NotificationsState> _resetNotification(int key, AppNotificationType type) async {
    final notif = await _dataService.notifications.resetNotification(key, type, _settingsService.serverResetTime);
    await _notificationService.cancelNotification(key, type);
    await _notificationService.scheduleNotification(key, type, notif.title, notif.body, notif.completesAt);
    await _telemetryService.trackNotificationRestarted(type);
    return _afterUpdatingNotification(notif);
  }

  Future<NotificationsState> _stopNotification(int key, AppNotificationType type) async {
    final notif = await _dataService.notifications.stopNotification(key, type);
    await _notificationService.cancelNotification(key, type);
    await _telemetryService.trackNotificationStopped(type);
    return _afterUpdatingNotification(notif);
  }

  NotificationsState _afterUpdatingNotification(NotificationItem updated) {
    final index = state.notifications.indexWhere((el) => el.key == updated.key && el.type == updated.type);
    final notifications = [...state.notifications];
    notifications.removeAt(index);
    notifications.insert(index, updated);
    return state.copyWith.call(notifications: notifications);
  }

  Future<NotificationsState> _reduceHours(int key, AppNotificationType type, int hours) async {
    final notif = await _dataService.notifications.reduceNotificationHours(key, type, hours);
    await _notificationService.cancelNotification(key, type);
    await _notificationService.scheduleNotification(key, type, notif.title, notif.body, notif.completesAt);
    return _afterUpdatingNotification(notif);
  }
}
