import 'package:shiori/domain/models/entities/base_entity.dart';

abstract class NotificationBase extends BaseEntity {
  int get type;

  String get itemKey;

  DateTime get createdAt;

  DateTime get originalScheduledDate;

  DateTime get completesAt;
  set completesAt(DateTime value);

  bool get showNotification;
  set showNotification(bool value);

  String? get note;
  set note(String? value);

  String get title;
  set title(String value);

  String get body;
  set body(String value);
}
