part of 'notification_timer_bloc.dart';

@freezed
sealed class NotificationTimerEvent with _$NotificationTimerEvent {
  const factory NotificationTimerEvent.init({required DateTime completesAt}) = NotificationTimerEventInit;

  const factory NotificationTimerEvent.refresh({required int ticks}) = NotificationTimerEventRefresh;
}
