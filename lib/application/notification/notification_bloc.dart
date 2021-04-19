import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/app_constants.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/data_service.dart';
import 'package:meta/meta.dart';

part 'notification_bloc.freezed.dart';
part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final DataService _dataService;

  NotificationBloc(this._dataService) : super(const NotificationState.loading());

  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async* {
    final s = event.map(
      init: (e) {
        if (e.key == null) {
          return const NotificationState.resin(type: AppNotificationType.resin, showNotification: true, currentResin: 1);
        }

        final item = _dataService.getNotification(e.key);
        switch (item.type) {
          case AppNotificationType.resin:
            return NotificationState.resin(
              type: item.type,
              showNotification: item.showNotification,
              currentResin: item.currentResinValue,
              note: item.note,
            );
          case AppNotificationType.expedition:
            return NotificationState.expedition(
              type: item.type,
              showNotification: item.showNotification,
              expeditionType: item.expeditionType,
              expeditionTimeType: item.expeditionTimeType,
              note: item.note,
              withTimeReduction: item.withTimeReduction,
            );
          case AppNotificationType.item:
            // TODO: Handle this case.
            break;
        }
      },
      typeChanged: (e) => state.map(
        loading: (_) => state,
        resin: (s) => NotificationState.resin(type: AppNotificationType.resin, showNotification: s.showNotification, currentResin: 1),
        expedition: (s) => NotificationState.expedition(
          type: AppNotificationType.expedition,
          showNotification: s.showNotification,
          expeditionType: ExpeditionType.mora,
          expeditionTimeType: ExpeditionTimeType.fourHours,
          withTimeReduction: false,
        ),
      ),
      noteChanged: (e) => state.map(
        loading: (_) => state,
        resin: (s) => s.copyWith.call(note: e.newValue),
        expedition: (s) => s.copyWith.call(note: e.newValue),
      ),
      showNotificationChanged: (e) => state.map(
        loading: (_) => state,
        resin: (s) => s.copyWith.call(showNotification: e.show),
        expedition: (s) => s.copyWith.call(showNotification: e.show),
      ),
      expeditionTypeChanged: (e) => state.map(
        loading: (_) => state,
        resin: (_) => state,
        expedition: (s) => s.copyWith.call(expeditionType: e.newValue),
      ),
      expeditionTimeTypeChanged: (e) => state.map(
        loading: (_) => state,
        resin: (_) => state,
        expedition: (s) => s.copyWith.call(expeditionTimeType: e.newValue),
      ),
      resinChanged: (e) => state.map(
        loading: (_) => state,
        resin: (s) => s.copyWith.call(currentResin: e.newValue),
        expedition: (_) => state,
      ),
      saveChanges: (e) {
        final now = DateTime.now();
        state.map(
            loading: (_) => state,
            resin: (s) {
              final diff = maxResinValue - s.currentResin;
              final item = NotificationItem.resin(
                key: s.key,
                notificationId: '',
                type: s.type,
                image: '',
                remaining: null,
                createdAt: '',
                completesAt: '',
                showNotification: s.showNotification,
                currentResinValue: s.currentResin,
              );
              _dataService.saveNotification(item);
            },
            expedition: (s) {});
        return state;
      },
    );

    yield s;
  }
}
