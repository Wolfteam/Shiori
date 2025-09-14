part of 'notification_bloc.dart';

@freezed
sealed class NotificationEvent with _$NotificationEvent {
  //Common
  const factory NotificationEvent.add({
    required String defaultTitle,
    required String defaultBody,
  }) = NotificationEventAdd;

  const factory NotificationEvent.edit({
    required int key,
    required AppNotificationType type,
  }) = NotificationEventEdit;

  const factory NotificationEvent.typeChanged({
    required AppNotificationType newValue,
  }) = NotificationEventTypeChanged;

  const factory NotificationEvent.titleChanged({
    required String newValue,
  }) = NotificationEventTitleChanged;

  const factory NotificationEvent.bodyChanged({
    required String newValue,
  }) = NotificationEventBodyChanged;

  const factory NotificationEvent.noteChanged({
    required String newValue,
  }) = NotificationEventNoteChanged;

  const factory NotificationEvent.showNotificationChanged({
    required bool show,
  }) = NotificationEventShowNotificationChanged;

  const factory NotificationEvent.showOtherImages({
    required bool show,
  }) = NotificationEventShowOtherImages;

  const factory NotificationEvent.imageChanged({
    required String newValue,
  }) = NotificationEventImageChanged;

  const factory NotificationEvent.saveChanges() = NotificationEventSaveChanges;

  //Resin specific
  const factory NotificationEvent.resinChanged({
    required int newValue,
  }) = NotificationEventResinChanged;

  //Expedition specific
  const factory NotificationEvent.expeditionTimeTypeChanged({
    required ExpeditionTimeType newValue,
  }) = NotificationEventExpeditionTimeTypeChanged;

  const factory NotificationEvent.timeReductionChanged({
    required bool withTimeReduction,
  }) = NotificationEventTimeReductionChanged;

  //Farming - Artifact specific
  const factory NotificationEvent.artifactFarmingTimeTypeChanged({
    required ArtifactFarmingTimeType newValue,
  }) = NotificationEventArtifactFarmingTimeTypeChanged;

  //Furniture specific
  const factory NotificationEvent.furnitureCraftingTimeTypeChanged({
    required FurnitureCraftingTimeType newValue,
  }) = NotificationEventFurnitureCraftingTimeTypeChanged;

  //Realm currency specific
  const factory NotificationEvent.realmCurrencyChanged({
    required int newValue,
  }) = NotificationEventRealmCurrencyChanged;

  const factory NotificationEvent.realmRankTypeChanged({
    required RealmRankType newValue,
  }) = NotificationEventRealmRankTypeChanged;

  const factory NotificationEvent.realmTrustRankLevelChanged({
    required int newValue,
  }) = NotificationEventRealmTrustRankLevelChanged;

  //Custom specific
  const factory NotificationEvent.itemTypeChanged({
    required AppNotificationItemType newValue,
  }) = NotificationEventItemTypeChanged;

  const factory NotificationEvent.keySelected({
    required String keyName,
  }) = NotificationEventKeySelected;

  const factory NotificationEvent.customDateChanged({
    required DateTime newValue,
  }) = NotificationEventCustomDateChanged;
}
