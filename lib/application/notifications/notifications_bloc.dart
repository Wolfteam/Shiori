import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/data_service.dart';
import 'package:genshindb/domain/services/notification_service.dart';
import 'package:genshindb/domain/services/settings_service.dart';
import 'package:meta/meta.dart';

part 'notifications_bloc.freezed.dart';
part 'notifications_event.dart';
part 'notifications_state.dart';

const _initialState = NotificationsState.initial(notifications: [], ticks: 0);

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final DataService _dataService;
  final NotificationService _notificationService;
  final SettingsService _settingsService;

  Timer _timer;

  NotificationsBloc(this._dataService, this._notificationService, this._settingsService) : super(_initialState);

  @override
  Stream<NotificationsState> mapEventToState(NotificationsEvent event) async* {
    final s = await event.map(
      init: (_) async => _buildInitialState(),
      delete: (e) async => _deleteNotification(e.id, e.type),
      reset: (e) async => _resetNotification(e.id, e.type),
      stop: (e) async => _stopNotification(e.id, e.type),
      refresh: (e) async => _refreshNotifications(e.ticks),
      close: (_) async {
        cancelTimer();
        return _initialState;
      },
      reduceHours: (e) async => _reduceHours(e.id, e.type, e.hoursToReduce),
    );
    yield s;
  }

  void startTime() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => add(NotificationsEvent.refresh(ticks: timer.tick)));
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  NotificationsState _buildInitialState() {
    cancelTimer();
    final notifications = _dataService.getAllNotifications();
    startTime();
    return NotificationsState.initial(
      notifications: notifications,
      ticks: _timer.tick,
      useTwentyFourHoursFormat: _settingsService.useTwentyFourHoursFormat,
    );
  }

  Future<NotificationsState> _deleteNotification(int key, AppNotificationType type) async {
    await _dataService.deleteNotification(key, type);
    await _notificationService.cancelNotification(key, type);
    final notifications = [...state.notifications];
    notifications.removeWhere((el) => el.key == key && el.type == type);
    return state.copyWith.call(notifications: notifications);
  }

  Future<NotificationsState> _resetNotification(int key, AppNotificationType type) async {
    final notif = await _dataService.resetNotification(key, type, _settingsService.serverResetTime);
    await _notificationService.cancelNotification(key, type);
    await _notificationService.scheduleNotification(key, type, notif.title, notif.body, notif.completesAt);
    return _afterUpdatingNotification(notif);
  }

  Future<NotificationsState> _stopNotification(int key, AppNotificationType type) async {
    final notif = await _dataService.stopNotification(key, type);
    await _notificationService.cancelNotification(key, type);
    return _afterUpdatingNotification(notif);
  }

  NotificationsState _afterUpdatingNotification(NotificationItem updated) {
    final index = state.notifications.indexWhere((el) => el.key == updated.key && el.type == updated.type);
    final notifications = [...state.notifications];
    notifications.removeAt(index);
    notifications.insert(index, updated);
    return state.copyWith.call(notifications: notifications);
  }

  NotificationsState _refreshNotifications(int ticks) {
    if (state is _InitialState) {
      final notifications = state.notifications.map((e) => e.copyWith.call()).toList();
      return state.copyWith.call(notifications: notifications, ticks: ticks);
    }
    return state;
  }

  Future<NotificationsState> _reduceHours(int key, AppNotificationType type, int hours) async {
    final notif = await _dataService.reduceNotificationHours(key, type, hours);
    await _notificationService.cancelNotification(key, type);
    await _notificationService.scheduleNotification(key, type, notif.title, notif.body, notif.completesAt);
    return _afterUpdatingNotification(notif);
  }
}
