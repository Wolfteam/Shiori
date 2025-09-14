part of 'notifications_bloc.dart';

@freezed
sealed class NotificationsState with _$NotificationsState {
  const factory NotificationsState.initial({
    required List<NotificationItem> notifications,
    @Default(false) bool useTwentyFourHoursFormat,
  }) = NotificationsStateInitial;
}
