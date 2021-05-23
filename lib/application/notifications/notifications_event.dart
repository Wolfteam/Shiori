part of 'notifications_bloc.dart';

@freezed
abstract class NotificationsEvent implements _$NotificationsEvent {
  const factory NotificationsEvent.init() = _Init;

  const factory NotificationsEvent.delete({
    @required int id,
    @required AppNotificationType type,
  }) = _Delete;

  const factory NotificationsEvent.reset({
    @required int id,
    @required AppNotificationType type,
  }) = _Reset;

  const factory NotificationsEvent.stop({
    @required int id,
    @required AppNotificationType type,
  }) = _Stop;

  const factory NotificationsEvent.close() = _Close;

  const factory NotificationsEvent.refresh({
    @required int ticks,
  }) = _Refresh;
}
