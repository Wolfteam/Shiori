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
class NotificationState with _$NotificationState {
  @Implements(_CommonBaseState)
  const factory NotificationState.resin({
    int? key,
    @Default(<NotificationItemImage>[]) List<NotificationItemImage> images,
    @Default(AppNotificationType.resin) AppNotificationType type,
    @Default(true) bool showNotification,
    required int currentResin,
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
    int? key,
    @Default(<NotificationItemImage>[]) List<NotificationItemImage> images,
    @Default(AppNotificationType.expedition) AppNotificationType type,
    @Default(true) bool showNotification,
    required ExpeditionTimeType expeditionTimeType,
    required bool withTimeReduction,
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
  const factory NotificationState.farmingArtifact({
    int? key,
    @Default(<NotificationItemImage>[]) List<NotificationItemImage> images,
    @Default(AppNotificationType.farmingArtifacts) AppNotificationType type,
    @Default(ArtifactFarmingTimeType.twelveHours) ArtifactFarmingTimeType artifactFarmingTimeType,
    @Default(true) bool showNotification,
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
  }) = _FarmingArtifactState;

  @Implements(_CommonBaseState)
  const factory NotificationState.farmingMaterial({
    int? key,
    @Default(<NotificationItemImage>[]) List<NotificationItemImage> images,
    @Default(AppNotificationType.farmingMaterials) AppNotificationType type,
    @Default(true) bool showNotification,
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
  }) = _FarmingMaterialState;

  @Implements(_CommonBaseState)
  const factory NotificationState.gadget({
    int? key,
    @Default(<NotificationItemImage>[]) List<NotificationItemImage> images,
    @Default(AppNotificationType.gadget) AppNotificationType type,
    @Default(true) bool showNotification,
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
  }) = _GadgetState;

  @Implements(_CommonBaseState)
  const factory NotificationState.furniture({
    int? key,
    @Default(<NotificationItemImage>[]) List<NotificationItemImage> images,
    @Default(AppNotificationType.furniture) AppNotificationType type,
    @Default(FurnitureCraftingTimeType.fourteenHours) FurnitureCraftingTimeType timeType,
    @Default(true) bool showNotification,
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
  }) = _FurnitureState;

  @Implements(_CommonBaseState)
  const factory NotificationState.realmCurrency({
    int? key,
    @Default(<NotificationItemImage>[]) List<NotificationItemImage> images,
    @Default(AppNotificationType.realmCurrency) AppNotificationType type,
    @Default(RealmRankType.bareBones) RealmRankType currentRealmRankType,
    @Default(1) int currentTrustRank,
    @Default(0) int currentRealmCurrency,
    @Default(true) bool showNotification,
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
  }) = _RealmCurrencyState;

  @Implements(_CommonBaseState)
  const factory NotificationState.weeklyBoss({
    int? key,
    @Default(<NotificationItemImage>[]) List<NotificationItemImage> images,
    @Default(AppNotificationType.weeklyBoss) AppNotificationType type,
    @Default(true) bool showNotification,
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
  }) = _WeeklyBossState;

  @Implements(_CommonBaseState)
  const factory NotificationState.custom({
    int? key,
    @Default(<NotificationItemImage>[]) List<NotificationItemImage> images,
    @Default(AppNotificationType.custom) AppNotificationType type,
    @Default(true) bool showNotification,
    required AppNotificationItemType itemType,
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
    required DateTime scheduledDate,
    required LanguageModel language,
    @Default(false) bool useTwentyFourHoursFormat,
  }) = _CustomState;

  @Implements(_CommonBaseState)
  const factory NotificationState.dailyCheckIn({
    int? key,
    @Default(<NotificationItemImage>[]) List<NotificationItemImage> images,
    @Default(AppNotificationType.dailyCheckIn) AppNotificationType type,
    @Default(true) bool showNotification,
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
  }) = _DailyCheckInState;
}
