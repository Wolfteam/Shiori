part of 'notifications_bloc.dart';

@freezed
abstract class NotificationsEvent implements _$NotificationsEvent {
  const factory NotificationsEvent.init() = _Init;

  const factory NotificationsEvent.delete({
    @required int id,
  }) = _Delete;

  const factory NotificationsEvent.reset({
    @required int id,
  }) = _Reset;

  const factory NotificationsEvent.stop({
    @required int id,
  }) = _Stop;

  const factory NotificationsEvent.close() = _Close;
}
