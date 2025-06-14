import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:darq/darq.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/notification_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'notification_bloc.freezed.dart';
part 'notification_event.dart';
part 'notification_state.dart';

//just a dummy state
const _initialState = NotificationState.resin(currentResin: 0);

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final DataService _dataService;
  final NotificationService _notificationService;
  final GenshinService _genshinService;
  final LocaleService _localeService;
  final LoggingService _loggingService;
  final TelemetryService _telemetryService;
  final SettingsService _settingsService;
  final ResourceService _resourceService;

  final NotificationsBloc _notificationsBloc;

  static int get maxTitleLength => 40;

  static int get maxBodyLength => 40;

  static int get maxNoteLength => 100;

  NotificationBloc(
    this._dataService,
    this._notificationService,
    this._genshinService,
    this._localeService,
    this._loggingService,
    this._telemetryService,
    this._settingsService,
    this._resourceService,
    this._notificationsBloc,
  ) : super(_initialState);

  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async* {
    //TODO: HANDLE RECURRING NOTIFICATIONS
    switch (event) {
      case NotificationEventAdd():
        yield _buildAddState(event.defaultTitle, event.defaultBody);
      case NotificationEventEdit():
        yield _buildEditState(event.key, event.type);
      case NotificationEventTypeChanged():
        yield _typeChanged(event.newValue);
      case NotificationEventTitleChanged():
        yield state.copyWith.call(
          title: event.newValue,
          isTitleValid: _isTitleValid(event.newValue),
          isTitleDirty: true,
        );
      case NotificationEventBodyChanged():
        yield state.copyWith.call(body: event.newValue, isBodyValid: _isBodyValid(event.newValue), isBodyDirty: true);
      case NotificationEventNoteChanged():
        yield state.copyWith.call(note: event.newValue, isNoteValid: _isNoteValid(event.newValue), isNoteDirty: true);
      case NotificationEventShowNotificationChanged():
        yield state.copyWith.call(showNotification: event.show);
      case NotificationEventShowOtherImages():
        yield state.copyWith.call(showOtherImages: event.show);
      case NotificationEventImageChanged():
        final images = state.images.map((el) => el.copyWith.call(isSelected: el.image == event.newValue)).toList();
        yield state.copyWith.call(images: images);
      case NotificationEventSaveChanges():
        yield await _saveChanges();
      case NotificationEventResinChanged():
        switch (state) {
          case final NotificationStateResin state:
            yield state.copyWith.call(currentResin: event.newValue);
          default:
            break;
        }
      case NotificationEventExpeditionTimeTypeChanged():
        switch (state) {
          case final NotificationStateExpedition state:
            yield state.copyWith.call(expeditionTimeType: event.newValue);
          default:
            break;
        }
      case NotificationEventTimeReductionChanged():
        switch (state) {
          case final NotificationStateExpedition state:
            yield state.copyWith.call(withTimeReduction: event.withTimeReduction);
          default:
            break;
        }
      case NotificationEventArtifactFarmingTimeTypeChanged():
        switch (state) {
          case final NotificationStateFarmingArtifact state:
            yield state.copyWith.call(artifactFarmingTimeType: event.newValue);
          default:
            break;
        }
      case NotificationEventFurnitureCraftingTimeTypeChanged():
        switch (state) {
          case final NotificationStateFurniture state:
            yield state.copyWith.call(timeType: event.newValue);
          default:
            break;
        }
      case NotificationEventRealmCurrencyChanged():
        switch (state) {
          case final NotificationStateRealmCurrency state:
            yield state.copyWith.call(currentRealmCurrency: event.newValue);
          default:
            break;
        }
      case NotificationEventRealmRankTypeChanged():
        switch (state) {
          case final NotificationStateRealmCurrency state:
            yield state.copyWith.call(currentRealmRankType: event.newValue);
          default:
            break;
        }
      case NotificationEventRealmTrustRankLevelChanged():
        switch (state) {
          case final NotificationStateRealmCurrency state:
            final max = getRealmMaxCurrency(event.newValue);
            var currentRealmCurrency = state.currentRealmCurrency;
            if (state.currentRealmCurrency > max) {
              currentRealmCurrency = max - 1;
            }
            yield state.copyWith.call(currentTrustRank: event.newValue, currentRealmCurrency: currentRealmCurrency);
          default:
            break;
        }
      case NotificationEventItemTypeChanged():
        switch (state) {
          case NotificationStateCustom():
            yield _itemTypeChanged(event.newValue);
          default:
            break;
        }
      case NotificationEventKeySelected():
        switch (state) {
          case NotificationStateCustom():
            yield _itemKeySelected(event.keyName);
          default:
            break;
        }
      case NotificationEventCustomDateChanged():
        switch (state) {
          case final NotificationStateCustom state:
            yield state.copyWith.call(scheduledDate: event.newValue);
          default:
            break;
        }
    }
  }

  bool _isTitleValid(String value) => value.isValidLength(maxLength: maxTitleLength);

  bool _isBodyValid(String value) => value.isValidLength(maxLength: maxBodyLength);

  bool _isNoteValid(String? value) => value.isNullEmptyOrWhitespace || value.isValidLength(maxLength: maxNoteLength);

  NotificationState _buildAddState(String title, String body) {
    return NotificationState.resin(
      title: title,
      body: body,
      isTitleValid: true,
      isBodyValid: true,
      images: _getImagesForResin(),
      currentResin: 0,
    );
  }

  NotificationState _buildEditState(int key, AppNotificationType type) {
    final item = _dataService.notifications.getNotification(key, type);
    NotificationState state;
    final images = <NotificationItemImage>[];
    switch (item.type) {
      case AppNotificationType.resin:
        images.addAll(_getImagesForResin());
        state = NotificationState.resin(currentResin: item.currentResinValue);
      case AppNotificationType.expedition:
        images.addAll(_getImagesForExpeditionNotifications(selectedImage: item.image));
        state = NotificationState.expedition(
          expeditionTimeType: item.expeditionTimeType!,
          withTimeReduction: item.withTimeReduction,
        );
      case AppNotificationType.farmingArtifacts:
        images.addAll(_getImagesForFarmingArtifactNotifications(selectedImage: item.image));
        state = NotificationState.farmingArtifact(artifactFarmingTimeType: item.artifactFarmingTimeType!);
      case AppNotificationType.farmingMaterials:
        images.addAll(_getImagesForFarmingMaterialNotifications(selectedImage: item.image));
        state = const NotificationState.farmingMaterial();
      case AppNotificationType.gadget:
        images.addAll(_getImagesForGadgetNotifications(selectedImage: item.image));
        state = const NotificationState.gadget();
      case AppNotificationType.furniture:
        images.addAll(_getImagesForFurnitureNotifications(selectedImage: item.image));
        state = NotificationState.furniture(timeType: item.furnitureCraftingTimeType!);
      case AppNotificationType.realmCurrency:
        images.addAll(_getImagesForRealmCurrencyNotifications(selectedImage: item.image));
        state = NotificationState.realmCurrency(
          currentTrustRank: item.realmTrustRank!,
          currentRealmCurrency: item.realmCurrency!,
          currentRealmRankType: item.realmRankType!,
        );
      case AppNotificationType.weeklyBoss:
        images.addAll(_getImagesForWeeklyBossNotifications(selectedImage: item.image));
        state = const NotificationState.weeklyBoss();
      case AppNotificationType.custom:
        images.addAll(_getImagesForCustomNotifications(itemKey: item.itemKey, selectedImage: item.image));
        state = NotificationState.custom(
          itemType: item.notificationItemType!,
          scheduledDate: item.completesAt,
          language: _localeService.getLocaleWithoutLang(),
          useTwentyFourHoursFormat: _settingsService.useTwentyFourHoursFormat,
        );
      case AppNotificationType.dailyCheckIn:
        images.addAll(_getImagesForDailyCheckIn(itemKey: item.itemKey, selectedImage: item.image));
        state = const NotificationState.dailyCheckIn();
    }

    return state.copyWith.call(
      key: item.key,
      title: item.title,
      body: item.body,
      note: item.note ?? '',
      images: images,
      showNotification: item.showNotification,
      isTitleValid: _isTitleValid(item.title),
      isTitleDirty: item.title.isNotNullEmptyOrWhitespace,
      isBodyValid: _isBodyValid(item.body),
      isBodyDirty: item.body.isNotNullEmptyOrWhitespace,
      isNoteValid: _isNoteValid(item.note),
      isNoteDirty: item.note.isNotNullEmptyOrWhitespace,
    );
  }

  NotificationState _typeChanged(AppNotificationType newValue) {
    //We don't allow changing the type after the notification has been created
    if (state.key != null) {
      return state;
    }

    NotificationState updatedState;
    final images = <NotificationItemImage>[];
    switch (newValue) {
      case AppNotificationType.resin:
        images.addAll(_getImagesForResin());
        updatedState = const NotificationState.resin(currentResin: 0);
      case AppNotificationType.expedition:
        images.addAll(_getImagesForExpeditionNotifications());
        updatedState = const NotificationState.expedition(
          expeditionTimeType: ExpeditionTimeType.twentyHours,
          withTimeReduction: false,
        );
      case AppNotificationType.farmingArtifacts:
        images.addAll(_getImagesForFarmingArtifactNotifications());
        updatedState = const NotificationState.farmingArtifact();
      case AppNotificationType.farmingMaterials:
        images.addAll(_getImagesForFarmingMaterialNotifications());
        updatedState = const NotificationState.farmingMaterial();
      case AppNotificationType.gadget:
        images.addAll(_getImagesForGadgetNotifications());
        updatedState = const NotificationState.gadget();
      case AppNotificationType.furniture:
        images.addAll(_getImagesForFurnitureNotifications());
        updatedState = const NotificationState.furniture();
      case AppNotificationType.realmCurrency:
        images.addAll(_getImagesForRealmCurrencyNotifications());
        updatedState = const NotificationState.realmCurrency();
      case AppNotificationType.weeklyBoss:
        images.addAll(_getImagesForWeeklyBossNotifications());
        updatedState = const NotificationState.weeklyBoss();
      case AppNotificationType.custom:
        images.addAll(_getImagesForCustomNotifications());
        updatedState = NotificationState.custom(
          itemType: AppNotificationItemType.material,
          scheduledDate: DateTime.now().add(const Duration(days: 1)),
          language: _localeService.getLocaleWithoutLang(),
          useTwentyFourHoursFormat: _settingsService.useTwentyFourHoursFormat,
        );
      case AppNotificationType.dailyCheckIn:
        images.addAll(_getImagesForDailyCheckIn());
        updatedState = const NotificationState.dailyCheckIn();
    }

    return updatedState.copyWith.call(
      images: images,
      showNotification: state.showNotification,
      title: state.title,
      body: state.body,
      note: state.note,
      isTitleValid: state.isTitleValid,
      isTitleDirty: state.isTitleDirty,
      isBodyValid: state.isBodyValid,
      isBodyDirty: state.isBodyDirty,
      isNoteValid: state.isNoteValid,
      isNoteDirty: state.isNoteDirty,
    );
  }

  NotificationState _itemTypeChanged(AppNotificationItemType newValue) {
    switch (state) {
      case final NotificationStateCustom state:
        final images = <NotificationItemImage>[];
        switch (newValue) {
          case AppNotificationItemType.character:
            final character = _genshinService.characters.getCharactersForCard().first;
            images.add(NotificationItemImage(itemKey: character.key, image: character.iconImage, isSelected: true));
          case AppNotificationItemType.weapon:
            final weapon = _genshinService.weapons.getWeaponsForCard().first;
            images.add(NotificationItemImage(itemKey: weapon.key, image: weapon.image, isSelected: true));
          case AppNotificationItemType.artifact:
            final artifact = _genshinService.artifacts.getArtifactsForCard().first;
            images.add(NotificationItemImage(itemKey: artifact.key, image: artifact.image, isSelected: true));
          case AppNotificationItemType.monster:
            final monster = _genshinService.monsters.getAllMonstersForCard().first;
            images.add(NotificationItemImage(itemKey: monster.key, image: monster.image, isSelected: true));
          case AppNotificationItemType.material:
            final material = _genshinService.materials.getAllMaterialsThatCanBeObtainedFromAnExpedition().first;
            final imagePath = _resourceService.getMaterialImagePath(material.image, material.type);
            images.add(NotificationItemImage(itemKey: material.key, image: imagePath, isSelected: true));
        }
        return state.copyWith.call(images: images, itemType: newValue);
      default:
        return state;
    }
  }

  NotificationState _itemKeySelected(String itemKey) {
    switch (state) {
      case final NotificationStateCustom state:
        final img = _genshinService.getItemImageFromNotificationItemType(itemKey, state.itemType);
        return state.copyWith.call(
          images: [NotificationItemImage(itemKey: itemKey, image: img, isSelected: true)],
        );
      default:
        return state;
    }
  }

  Future<NotificationState> _saveChanges() async {
    try {
      switch (state) {
        case final NotificationStateResin state:
          await _saveResinNotification(state);
        case final NotificationStateExpedition state:
          await _saveExpeditionNotification(state);
        case final NotificationStateFarmingArtifact state:
          await _saveFarmingArtifactNotification(state);
        case final NotificationStateFarmingMaterial state:
          await _saveFarmingMaterialNotification(state);
        case final NotificationStateGadget state:
          await _saveGadgetNotification(state);
        case final NotificationStateFurniture state:
          await _saveFurnitureNotification(state);
        case final NotificationStateRealmCurrency state:
          await _saveRealmCurrencyNotification(state);
        case final NotificationStateWeeklyBoss state:
          await _saveWeeklyBossNotification(state);
        case final NotificationStateCustom state:
          await _saveCustomNotification(state);
        case final NotificationStateDailyCheckIn state:
          await _saveDailyCheckInNotification(state);
      }

      if (state.key == null) {
        await _telemetryService.trackNotificationCreated(state.type);
      } else {
        await _telemetryService.trackNotificationUpdated(state.type);
      }
    } catch (e, s) {
      _loggingService.error(runtimeType, '_saveChanges: Unknown error while saving changes', e, s);
    }

    _notificationsBloc.add(const NotificationsEvent.init());

    return state;
  }

  Future<void> _saveResinNotification(NotificationStateResin s) async {
    if (s.key != null) {
      final updated = await _dataService.notifications.updateResinNotification(
        s.key!,
        s.title,
        s.body,
        s.currentResin,
        s.showNotification,
        note: s.note,
      );
      await _afterNotificationWasUpdated(updated);
      return;
    }

    final selectedItemKey = _getSelectedItemKey();
    final notif = await _dataService.notifications.saveResinNotification(
      selectedItemKey,
      s.title,
      s.body,
      s.currentResin,
      note: s.note,
      showNotification: s.showNotification,
    );
    await _afterNotificationWasCreated(notif);
  }

  Future<void> _saveExpeditionNotification(NotificationStateExpedition s) async {
    final selectedItemKey = _getSelectedItemKey();
    if (s.key != null) {
      final updated = await _dataService.notifications.updateExpeditionNotification(
        s.key!,
        selectedItemKey,
        s.expeditionTimeType,
        s.title,
        s.body,
        s.showNotification,
        s.withTimeReduction,
        note: s.note,
      );
      await _afterNotificationWasUpdated(updated);
      return;
    }

    final notif = await _dataService.notifications.saveExpeditionNotification(
      selectedItemKey,
      s.title,
      s.body,
      s.expeditionTimeType,
      note: s.note,
      showNotification: s.showNotification,
      withTimeReduction: s.withTimeReduction,
    );
    await _afterNotificationWasCreated(notif);
  }

  Future<void> _saveFarmingArtifactNotification(NotificationStateFarmingArtifact s) async {
    if (s.key != null) {
      final updated = await _dataService.notifications.updateFarmingArtifactNotification(
        s.key!,
        s.artifactFarmingTimeType,
        s.title,
        s.body,
        s.showNotification,
        note: s.note,
      );
      await _afterNotificationWasUpdated(updated);
      return;
    }

    final selectedItemKey = _getSelectedItemKey();
    final notif = await _dataService.notifications.saveFarmingArtifactNotification(
      selectedItemKey,
      s.artifactFarmingTimeType,
      s.title,
      s.body,
      note: s.note,
      showNotification: s.showNotification,
    );
    await _afterNotificationWasCreated(notif);
  }

  Future<void> _saveFarmingMaterialNotification(NotificationStateFarmingMaterial s) async {
    final selectedItemKey = _getSelectedItemKey();
    if (s.key != null) {
      final updated = await _dataService.notifications.updateFarmingMaterialNotification(
        s.key!,
        selectedItemKey,
        s.title,
        s.body,
        s.showNotification,
        note: s.note,
      );
      await _afterNotificationWasUpdated(updated);
      return;
    }

    final notif = await _dataService.notifications.saveFarmingMaterialNotification(
      selectedItemKey,
      s.title,
      s.body,
      note: s.note,
      showNotification: s.showNotification,
    );
    await _afterNotificationWasCreated(notif);
  }

  Future<void> _saveGadgetNotification(NotificationStateGadget s) async {
    final selectedItemKey = _getSelectedItemKey();
    if (s.key != null) {
      final updated = await _dataService.notifications.updateGadgetNotification(
        s.key!,
        selectedItemKey,
        s.title,
        s.body,
        s.showNotification,
        note: s.note,
      );
      await _afterNotificationWasUpdated(updated);
      return;
    }

    final notif = await _dataService.notifications.saveGadgetNotification(
      selectedItemKey,
      s.title,
      s.body,
      note: s.note,
      showNotification: s.showNotification,
    );
    await _afterNotificationWasCreated(notif);
  }

  Future<void> _saveFurnitureNotification(NotificationStateFurniture s) async {
    if (s.key != null) {
      final updated = await _dataService.notifications.updateFurnitureNotification(
        s.key!,
        s.timeType,
        s.title,
        s.body,
        s.showNotification,
        note: s.note,
      );
      await _afterNotificationWasUpdated(updated);
      return;
    }

    final selectedItemKey = _getSelectedItemKey();
    final notif = await _dataService.notifications.saveFurnitureNotification(
      selectedItemKey,
      s.timeType,
      s.title,
      s.body,
      note: s.note,
      showNotification: s.showNotification,
    );
    await _afterNotificationWasCreated(notif);
  }

  Future<void> _saveRealmCurrencyNotification(NotificationStateRealmCurrency s) async {
    if (s.key != null) {
      final updated = await _dataService.notifications.updateRealmCurrencyNotification(
        s.key!,
        s.currentRealmRankType,
        s.currentTrustRank,
        s.currentRealmCurrency,
        s.title,
        s.body,
        s.showNotification,
        note: s.note,
      );
      await _afterNotificationWasUpdated(updated);
      return;
    }

    final selectedItemKey = _getSelectedItemKey();
    final notif = await _dataService.notifications.saveRealmCurrencyNotification(
      selectedItemKey,
      s.currentRealmRankType,
      s.currentTrustRank,
      s.currentRealmCurrency,
      s.title,
      s.body,
      note: s.note,
      showNotification: s.showNotification,
    );
    await _afterNotificationWasCreated(notif);
  }

  Future<void> _saveWeeklyBossNotification(NotificationStateWeeklyBoss s) async {
    final selectedItemKey = _getSelectedItemKey();
    if (s.key != null) {
      final updated = await _dataService.notifications.updateWeeklyBossNotification(
        s.key!,
        _settingsService.serverResetTime,
        selectedItemKey,
        s.title,
        s.body,
        s.showNotification,
        note: s.note,
      );
      await _afterNotificationWasUpdated(updated);
      return;
    }

    final notif = await _dataService.notifications.saveWeeklyBossNotification(
      selectedItemKey,
      _settingsService.serverResetTime,
      s.title,
      s.body,
      note: s.note,
      showNotification: s.showNotification,
    );
    await _afterNotificationWasCreated(notif);
  }

  Future<void> _saveCustomNotification(NotificationStateCustom s) async {
    final selectedItemKey = _getSelectedItemKey();
    if (s.key != null) {
      final updated = await _dataService.notifications.updateCustomNotification(
        s.key!,
        selectedItemKey,
        s.title,
        s.body,
        s.scheduledDate,
        s.showNotification,
        s.itemType,
        note: s.note,
      );
      await _afterNotificationWasUpdated(updated);
      return;
    }

    final notif = await _dataService.notifications.saveCustomNotification(
      selectedItemKey,
      s.title,
      s.body,
      s.scheduledDate,
      s.itemType,
      note: s.note,
      showNotification: s.showNotification,
    );
    await _afterNotificationWasCreated(notif);
  }

  Future<void> _saveDailyCheckInNotification(NotificationStateDailyCheckIn s) async {
    if (s.key != null) {
      final updated = await _dataService.notifications.updateDailyCheckInNotification(
        s.key!,
        s.title,
        s.body,
        s.showNotification,
        note: s.note,
      );
      await _afterNotificationWasUpdated(updated);
      return;
    }

    final selectedItemKey = _getSelectedItemKey();
    final notif = await _dataService.notifications.saveDailyCheckInNotification(
      selectedItemKey,
      s.title,
      s.body,
      note: s.note,
      showNotification: s.showNotification,
    );
    await _afterNotificationWasCreated(notif);
  }

  String _getSelectedItemKey() {
    return state.images.firstWhere((el) => el.isSelected).itemKey;
  }

  List<NotificationItemImage> _getImagesForResin() {
    final material = _genshinService.materials.getFragileResinMaterial();
    final imagePath = _resourceService.getMaterialImagePath(material.image, material.type);
    return [NotificationItemImage(itemKey: material.key, image: imagePath, isSelected: true)];
  }

  List<NotificationItemImage> _getImagesForExpeditionNotifications({String? selectedImage}) {
    final materials = _genshinService.materials
        .getAllMaterialsThatCanBeObtainedFromAnExpedition()
        .orderByDescending((x) => x.rarity)
        .thenBy((x) => x.key)
        .toList();

    if (selectedImage.isNotNullEmptyOrWhitespace) {
      return materials.mapIndex((e, index) {
        final imagePath = _resourceService.getMaterialImagePath(e.image, e.type);
        return NotificationItemImage(itemKey: e.key, image: imagePath, isSelected: selectedImage == imagePath);
      }).toList();
    }

    return materials
        .mapIndex(
          (e, index) => NotificationItemImage(
            itemKey: e.key,
            image: _resourceService.getMaterialImagePath(e.image, e.type),
            isSelected: index == 0,
          ),
        )
        .toList();
  }

  List<NotificationItemImage> _getImagesForFarmingArtifactNotifications({String? selectedImage}) {
    final artifact = _genshinService.artifacts.getArtifactsForCard().first;
    final images = <NotificationItemImage>[];
    images.add(NotificationItemImage(itemKey: artifact.key, image: artifact.image));
    return _getImagesForFarmingNotifications(images, selectedImage: selectedImage);
  }

  List<NotificationItemImage> _getImagesForFarmingMaterialNotifications({String? selectedImage}) {
    final materials = _genshinService.materials
        .getAllMaterialsThatHaveAFarmingRespawnDuration()
        .orderByDescending((x) => x.rarity)
        .thenBy((x) => x.key)
        .toList();
    final images = materials
        .mapIndex(
          (e, index) => NotificationItemImage(itemKey: e.key, image: _resourceService.getMaterialImagePath(e.image, e.type)),
        )
        .toList();
    return _getImagesForFarmingNotifications(images, selectedImage: selectedImage);
  }

  List<NotificationItemImage> _getImagesForFarmingNotifications(List<NotificationItemImage> images, {String? selectedImage}) {
    final selected = selectedImage.isNotNullEmptyOrWhitespace
        ? images.firstWhere((el) => el.image == selectedImage)
        : images.first;
    final index = images.indexOf(selected);
    images.removeAt(index);
    images.insert(index, selected.copyWith.call(isSelected: true));
    return images;
  }

  List<NotificationItemImage> _getImagesForGadgetNotifications({String? selectedImage}) {
    final gadgets = _genshinService.gadgets.getAllGadgetsForNotifications();

    if (selectedImage.isNotNullEmptyOrWhitespace) {
      return gadgets.map((e) {
        final imagePath = _resourceService.getGadgetImagePath(e.image);
        return NotificationItemImage(itemKey: e.key, image: imagePath, isSelected: imagePath == selectedImage);
      }).toList();
    }

    return gadgets
        .mapIndex(
          (e, i) =>
              NotificationItemImage(itemKey: e.key, image: _resourceService.getGadgetImagePath(e.image), isSelected: i == 0),
        )
        .toList();
  }

  List<NotificationItemImage> _getImagesForFurnitureNotifications({String? selectedImage}) {
    final furniture = _genshinService.furniture.getDefaultFurnitureForNotifications();
    final imagePath = _resourceService.getFurnitureImagePath(furniture.image);
    if (selectedImage.isNotNullEmptyOrWhitespace) {
      return [NotificationItemImage(itemKey: furniture.key, image: imagePath, isSelected: imagePath == selectedImage)];
    }
    return [NotificationItemImage(itemKey: furniture.key, image: imagePath, isSelected: true)];
  }

  List<NotificationItemImage> _getImagesForRealmCurrencyNotifications({String? selectedImage}) {
    final material = _genshinService.materials.getRealmCurrencyMaterial();
    return [
      NotificationItemImage(
        itemKey: material.key,
        image: _resourceService.getMaterialImagePath(material.image, material.type),
        isSelected: true,
      ),
    ];
  }

  List<NotificationItemImage> _getImagesForWeeklyBossNotifications({String? selectedImage}) {
    final monsters = _genshinService.monsters.getMonsters(MonsterType.boss).toList();
    if (selectedImage.isNotNullEmptyOrWhitespace) {
      return monsters.map((e) {
        final imagePath = _resourceService.getMonsterImagePath(e.image);
        return NotificationItemImage(itemKey: e.key, image: imagePath, isSelected: imagePath == selectedImage);
      }).toList();
    }

    return monsters
        .mapIndex(
          (e, i) =>
              NotificationItemImage(itemKey: e.key, image: _resourceService.getMonsterImagePath(e.image), isSelected: i == 0),
        )
        .toList();
  }

  List<NotificationItemImage> _getImagesForCustomNotifications({String? itemKey, String? selectedImage}) {
    if (selectedImage.isNotNullEmptyOrWhitespace) {
      return [NotificationItemImage(itemKey: itemKey!, image: selectedImage!, isSelected: true)];
    }
    final material = _genshinService.materials.getAllMaterialsThatCanBeObtainedFromAnExpedition().first;
    final imagePath = _resourceService.getMaterialImagePath(material.image, material.type);
    return [NotificationItemImage(itemKey: material.key, image: imagePath, isSelected: true)];
  }

  List<NotificationItemImage> _getImagesForDailyCheckIn({String? itemKey, String? selectedImage}) {
    if (selectedImage.isNotNullEmptyOrWhitespace) {
      return [NotificationItemImage(itemKey: itemKey!, image: selectedImage!, isSelected: true)];
    }
    final material = _genshinService.materials.getPrimogemMaterial();
    final imagePath = _resourceService.getMaterialImagePath(material.image, material.type);
    return [NotificationItemImage(itemKey: material.key, image: imagePath, isSelected: true)];
  }

  Future<void> _afterNotificationWasCreated(NotificationItem notif) async {
    if (notif.showNotification) {
      await _notificationService.scheduleNotification(notif.key, notif.type, notif.title, notif.body, notif.completesAt);
    }
  }

  Future<void> _afterNotificationWasUpdated(NotificationItem notif) async {
    await _notificationService.cancelNotification(notif.key, notif.type);
    if (notif.showNotification && !notif.remaining.isNegative) {
      await _notificationService.scheduleNotification(notif.key, notif.type, notif.title, notif.body, notif.completesAt);
    }
  }
}
