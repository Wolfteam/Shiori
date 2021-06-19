part of 'notifications_bloc.dart';

@freezed
class NotificationsState with _$NotificationsState {
  const factory NotificationsState.initial({
    required List<NotificationItem> notifications,
    required int ticks,
    @Default(false) bool useTwentyFourHoursFormat,
  }) = _InitialState;
}
