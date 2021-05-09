part of 'notification_bloc.dart';

abstract class _CommonBaseState {
  AppNotificationType get type;

  List<NotificationItemImage> get images;

  bool get showNotification;

  String get note;

  String get title;

  String get body;

  bool get isTitleValid;

  bool get isTitleDirty;

  bool get isBodyValid;

  bool get isBodyDirty;

  bool get isNoteValid;

  bool get isNoteDirty;

  bool get showOtherImages;
}

@freezed
abstract class NotificationState implements _$NotificationState {
  @Implements(_CommonBaseState)
  const factory NotificationState.resin({
    int key,
    @Default(<NotificationItemImage>[]) List<NotificationItemImage> images,
    @Default(AppNotificationType.resin) AppNotificationType type,
    @required bool showNotification,
    @required int currentResin,
    @Default('') String title,
    @Default('') String body,
    @Default(false) bool isTitleValid,
    @Default(false) bool isTitleDirty,
    @Default(false) bool isBodyValid,
    @Default(false) bool isBodyDirty,
    @Default(true) bool isNoteValid,
    @Default(false) bool isNoteDirty,
    @Default('') String note,
    @Default(false) bool showOtherImages,
  }) = _ResinState;

  @Implements(_CommonBaseState)
  const factory NotificationState.expedition({
    int key,
    @Default(<NotificationItemImage>[]) List<NotificationItemImage> images,
    @Default(AppNotificationType.expedition) AppNotificationType type,
    @required bool showNotification,
    @required ExpeditionTimeType expeditionTimeType,
    @required bool withTimeReduction,
    @Default('') String title,
    @Default('') String body,
    @Default(false) bool isTitleValid,
    @Default(false) bool isTitleDirty,
    @Default(false) bool isBodyValid,
    @Default(false) bool isBodyDirty,
    @Default(true) bool isNoteValid,
    @Default(false) bool isNoteDirty,
    @Default('') String note,
    @Default(false) bool showOtherImages,
  }) = _ExpeditionState;

  @Implements(_CommonBaseState)
  const factory NotificationState.custom({
    int key,
    @Default(<NotificationItemImage>[]) List<NotificationItemImage> images,
    @Default(AppNotificationType.custom) AppNotificationType type,
    @required bool showNotification,
    @required AppNotificationItemType itemType,
    @Default('') String title,
    @Default('') String body,
    @Default(false) bool isTitleValid,
    @Default(false) bool isTitleDirty,
    @Default(false) bool isBodyValid,
    @Default(false) bool isBodyDirty,
    @Default(true) bool isNoteValid,
    @Default(false) bool isNoteDirty,
    @Default('') String note,
    @Default(false) bool showOtherImages,
    @required DateTime scheduledDate,
    @required LanguageModel language,
  }) = _CustomState;
}
