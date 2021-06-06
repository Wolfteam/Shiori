abstract class NotificationBase {
  int get type;

  String itemKey;

  DateTime get createdAt;

  DateTime get originalScheduledDate;

  DateTime completesAt;

  bool showNotification;

  String note;

  String title;

  String body;
}
