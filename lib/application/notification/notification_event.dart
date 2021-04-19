part of 'notification_bloc.dart';

@freezed
abstract class NotificationEvent implements _$NotificationEvent {
  const factory NotificationEvent.init({
    int key,
  }) = _Init;

  const factory NotificationEvent.typeChanged({
    @required AppNotificationType newValue,
  }) = _TypeChanged;

  const factory NotificationEvent.noteChanged({
    @required String newValue,
  }) = _NoteChanged;

  const factory NotificationEvent.showNotificationChanged({
    @required bool show,
  }) = _ShowNotificationChanged;

  const factory NotificationEvent.resinChanged({
    @required int newValue,
  }) = _ResinChanged;

  const factory NotificationEvent.expeditionTypeChanged({
    @required ExpeditionType newValue,
  }) = _ExpeditionTypeChanged;

  const factory NotificationEvent.expeditionTimeTypeChanged({
    @required ExpeditionTimeType newValue,
  }) = _ExpeditionTimeTypeChanged;

  const factory NotificationEvent.saveChanges() = _SaveChanges;
}
