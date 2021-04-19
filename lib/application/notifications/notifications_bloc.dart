import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/data_service.dart';
import 'package:meta/meta.dart';

part 'notifications_bloc.freezed.dart';
part 'notifications_event.dart';
part 'notifications_state.dart';

const _initialState = NotificationsState.initial(notifications: []);

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final DataService _dataService;
  // final items = [
  //   NotificationItem(
  //     type: AppNotificationType.resin,
  //     image: Assets.getCurrencyMaterialPath('fragile_resin.png'),
  //     completesAt: '04/11/2021 16:27:40',
  //     createdAt: '04/11/2021 11:27:40',
  //     notificationId: '1',
  //     remaining: Duration(hours: 65),
  //     showNotification: true,
  //   ),
  //   NotificationItem(
  //     type: AppNotificationType.expedition,
  //     image: Assets.getIngredientMaterialPath('fowl.png'),
  //     completesAt: '04/11/2021 16:27:40',
  //     createdAt: '04/11/2021 11:27:40',
  //     notificationId: '2',
  //     remaining: Duration(hours: 8),
  //     showNotification: true,
  //   ),
  //   NotificationItem(
  //     type: AppNotificationType.expedition,
  //     image: Assets.getIngredientMaterialPath('crystal_chunk.png'),
  //     completesAt: '04/11/2021 16:27:40',
  //     createdAt: '04/11/2021 11:27:40',
  //     notificationId: '3',
  //     remaining: Duration(hours: 8),
  //     showNotification: false,
  //     note: 'To forge the materials required by the current weapon that Klee uses',
  //   ),
  //   NotificationItem(
  //     type: AppNotificationType.expedition,
  //     image: Assets.getCurrencyMaterialPath('mora.png'),
  //     completesAt: '04/11/2021 16:27:40',
  //     createdAt: '04/11/2021 11:27:40',
  //     notificationId: '4',
  //     remaining: Duration(hours: 8),
  //     showNotification: true,
  //     note: 'To upgrade the artifacts used by Keqing',
  //   ),
  // ];

  NotificationsBloc(this._dataService) : super(_initialState);

  @override
  Stream<NotificationsState> mapEventToState(NotificationsEvent event) async* {
    final s = await event.map(
      init: (_) async => _buildInitialState(),
      delete: (e) async {
        await _dataService.deleteNotification(e.id);
        return _buildInitialState();
      },
      close: (_) async => _initialState,
    );
    yield s;
  }

  NotificationsState _buildInitialState() {
    final notifications = _dataService.getAllNotifications();
    return NotificationsState.initial(notifications: notifications);
  }
}
