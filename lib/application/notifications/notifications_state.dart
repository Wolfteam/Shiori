part of 'notifications_bloc.dart';

@freezed
abstract class NotificationsState implements _$NotificationsState {
  const factory NotificationsState.initial({
    @required List<NotificationItem> notifications,
    @required int ticks,
    @Default(false) bool useTwentyFourHoursFormat,
  }) = _InitialState;
}
