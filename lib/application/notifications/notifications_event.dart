part of 'notifications_bloc.dart';

@freezed
sealed class NotificationsEvent with _$NotificationsEvent {
  const factory NotificationsEvent.init() = NotificationsEventInit;

  const factory NotificationsEvent.delete({
    required int id,
    required AppNotificationType type,
  }) = NotificationsEventDelete;

  const factory NotificationsEvent.reset({
    required int id,
    required AppNotificationType type,
  }) = NotificationsEventReset;

  const factory NotificationsEvent.stop({
    required int id,
    required AppNotificationType type,
  }) = NotificationsEventStop;

  const factory NotificationsEvent.reduceHours({
    required int id,
    required AppNotificationType type,
    required int hoursToReduce,
  }) = NotificationsEventReduceHour;
}
