import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/data_service.dart';
import 'package:genshindb/domain/services/notification_service.dart';
import 'package:meta/meta.dart';

part 'notifications_bloc.freezed.dart';
part 'notifications_event.dart';
part 'notifications_state.dart';

const _initialState = NotificationsState.initial(notifications: []);

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final DataService _dataService;
  final NotificationService _notificationService;

  NotificationsBloc(this._dataService, this._notificationService) : super(_initialState);

  @override
  Stream<NotificationsState> mapEventToState(NotificationsEvent event) async* {
    final s = await event.map(
      init: (_) async => _buildInitialState(),
      delete: (e) async => _deleteNotification(e.id),
      reset: (e) async => _resetNotification(e.id),
      close: (_) async => _initialState,
    );
    yield s;
  }

  NotificationsState _buildInitialState() {
    final notifications = _dataService.getAllNotifications();
    return NotificationsState.initial(notifications: notifications);
  }

  Future<NotificationsState> _deleteNotification(int key) async {
    await _dataService.deleteNotification(key);
    await _notificationService.cancelNotification(key);
    final notifications = [...state.notifications];
    notifications.removeWhere((el) => el.key == key);

    return state.copyWith.call(notifications: notifications);
  }

  Future<NotificationsState> _resetNotification(int key) async {
    final notif = await _dataService.resetNotification(key);
    await _notificationService.cancelNotification(notif.key);
    await _notificationService.scheduleNotification(key, notif.title, notif.body, notif.completesAt);

    final index = state.notifications.indexWhere((el) => el.key == key);
    final notifications = [...state.notifications];
    notifications.removeAt(index);
    notifications.insert(index, notif);

    return state.copyWith.call(notifications: notifications);
  }
}
