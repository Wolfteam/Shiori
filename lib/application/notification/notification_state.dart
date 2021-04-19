part of 'notification_bloc.dart';

abstract class _CommonBaseState {
  AppNotificationType get type;

  bool get showNotification;

  String get note;
}

@freezed
abstract class NotificationState implements _$NotificationState {
  const factory NotificationState.loading() = _LoadingState;

  @Implements(_CommonBaseState)
  const factory NotificationState.resin({
    int key,
    @required AppNotificationType type,
    @required bool showNotification,
    @required int currentResin,
    String note,
  }) = _ResinState;

  @Implements(_CommonBaseState)
  const factory NotificationState.expedition({
    int key,
    @required AppNotificationType type,
    @required bool showNotification,
    @required ExpeditionType expeditionType,
    @required ExpeditionTimeType expeditionTimeType,
    @required bool withTimeReduction,
    String note,
  }) = _ExpeditionState;
}
