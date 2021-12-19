part of 'notification_timer_bloc.dart';

@freezed
class NotificationTimerEvent with _$NotificationTimerEvent {
  const factory NotificationTimerEvent.init({required DateTime completesAt}) = _Init;

  const factory NotificationTimerEvent.refresh({required int ticks}) = _Refresh;
}
