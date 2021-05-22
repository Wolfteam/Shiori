import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/app_constants.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/extensions/iterable_extensions.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/data_service.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/locale_service.dart';
import 'package:genshindb/domain/services/logging_service.dart';
import 'package:genshindb/domain/services/notification_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';

part 'notification_bloc.freezed.dart';
part 'notification_event.dart';
part 'notification_state.dart';

//just a dummy state
const _initialState = NotificationState.resin(
  images: [],
  showNotification: true,
  currentResin: 0,
);

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final DataService _dataService;
  final NotificationService _notificationService;
  final GenshinService _genshinService;
  final LocaleService _localeService;
  final LoggingService _loggingService;
  final TelemetryService _telemetryService;

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
  ) : super(_initialState);

  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async* {
    //TODO: HANDLE RECURRING NOTIFICATIONS
    final s = await event.map(
      add: (e) async => _buildAddState(e.defaultTitle, e.defaultBody),
      edit: (e) async => _buildEditState(e.key),
      typeChanged: (e) async => _typeChanged(e.newValue),
      titleChanged: (e) async => state.copyWith.call(
        title: e.newValue,
        isTitleValid: _isTitleValid(e.newValue),
        isTitleDirty: true,
      ),
      bodyChanged: (e) async => state.copyWith.call(
        body: e.newValue,
        isBodyValid: _isBodyValid(e.newValue),
        isBodyDirty: true,
      ),
      noteChanged: (e) async => state.copyWith.call(
        note: e.newValue,
        isNoteValid: _isNoteValid(e.newValue),
        isNoteDirty: true,
      ),
      showNotificationChanged: (e) async => state.copyWith.call(showNotification: e.show),
      expeditionTimeTypeChanged: (e) async => state.maybeMap(
        expedition: (s) => s.copyWith.call(expeditionTimeType: e.newValue),
        orElse: () => state,
      ),
      resinChanged: (e) async => state.maybeMap(
        resin: (s) => s.copyWith.call(currentResin: e.newValue),
        orElse: () => state,
      ),
      itemTypeChanged: (e) async => state.maybeMap(
        custom: (s) => _itemTypeChanged(e.newValue),
        orElse: () => state,
      ),
      saveChanges: (e) async => _saveChanges(),
      timeReductionChanged: (e) async => state.maybeMap(
        expedition: (s) => s.copyWith.call(withTimeReduction: e.withTimeReduction),
        orElse: () => state,
      ),
      showOtherImages: (e) async => state.copyWith.call(showOtherImages: e.show),
      imageChanged: (e) async {
        final images = state.images.map((el) => el.copyWith.call(isSelected: el.image == e.newValue)).toList();
        return state.copyWith.call(images: images);
      },
      keySelected: (e) async => _itemKeySelected(e.keyName),
      customDateChanged: (e) async => state.maybeMap(
        custom: (s) => s.copyWith.call(scheduledDate: e.newValue),
        orElse: () => state,
      ),
      furnitureCraftingTimeTypeChanged: (e) async => state.maybeMap(
        furniture: (state) => state.copyWith.call(timeType: e.newValue),
        orElse: () => state,
      ),
      artifactFarmingTimeTypeChanged: (e) async => state.maybeMap(
        farmingArtifact: (state) => state.copyWith.call(artifactFarmingTimeType: e.newValue),
        orElse: () => state,
      ),
      realmRankTypeChanged: (e) async => state.maybeMap(
        realmCurrency: (state) => state.copyWith.call(currentRealmRankType: e.newValue),
        orElse: () => state,
      ),
      realmCurrencyChanged: (e) async => state.maybeMap(
        realmCurrency: (state) => state.copyWith.call(currentRealmCurrency: e.newValue),
        orElse: () => state,
      ),
      realmTrustRankLevelChanged: (e) async => state.maybeMap(
        realmCurrency: (state) {
          final max = getMaxRealmCurrency(e.newValue);
          var currentRealmCurrency = state.currentRealmCurrency;
          if (state.currentRealmCurrency > max) {
            currentRealmCurrency = max - 1;
          }
          return state.copyWith.call(currentTrustRank: e.newValue, currentRealmCurrency: currentRealmCurrency);
        },
        orElse: () => state,
      ),
    );

    yield s;
  }

  bool _isTitleValid(String value) => value.isValidLength(maxLength: maxTitleLength);

  bool _isBodyValid(String value) => value.isValidLength(maxLength: maxBodyLength);

  bool _isNoteValid(String value) => value.isNullEmptyOrWhitespace || value.isValidLength(maxLength: maxNoteLength);

  NotificationState _buildAddState(String title, String body) {
    return NotificationState.resin(
      title: title,
      body: body,
      isTitleValid: true,
      isBodyValid: true,
      images: _getImagesForResin(),
      showNotification: true,
      currentResin: 0,
    );
  }

  NotificationState _buildEditState(int key) {
    final item = _dataService.getNotification(key);
    NotificationState state;
    final images = <NotificationItemImage>[];
    switch (item.type) {
      case AppNotificationType.resin:
        images.addAll(_getImagesForResin());
        state = NotificationState.resin(currentResin: item.currentResinValue);
        break;
      case AppNotificationType.expedition:
        images.addAll(_getImagesForExpeditionNotifications(selectedImage: item.image));
        state = NotificationState.expedition(expeditionTimeType: item.expeditionTimeType, withTimeReduction: item.withTimeReduction);
        break;
      case AppNotificationType.farmingArtifacts:
        images.addAll(_getImagesForFarmingArtifactNotifications(selectedImage: item.image));
        state = NotificationState.farmingArtifact(artifactFarmingTimeType: item.artifactFarmingTimeType);
        break;
      case AppNotificationType.farmingMaterials:
        images.addAll(_getImagesForFarmingMaterialNotifications(selectedImage: item.image));
        state = const NotificationState.farmingMaterial();
        break;
      case AppNotificationType.gadget:
        images.addAll(_getImagesForGadgetNotifications(selectedImage: item.image));
        state = const NotificationState.gadget();
        break;
      case AppNotificationType.furniture:
        images.addAll(_getImagesForFurnitureNotifications(selectedImage: item.image));
        state = NotificationState.furniture(timeType: item.furnitureCraftingTimeType);
        break;
      case AppNotificationType.realmCurrency:
        images.addAll(_getImagesForRealmCurrencyNotifications(selectedImage: item.image));
        state = NotificationState.realmCurrency(
          currentTrustRank: item.realmTrustRank,
          currentRealmCurrency: item.realmCurrency,
          currentRealmRankType: item.realmRankType,
        );
        break;
      case AppNotificationType.weeklyBoss:
        images.addAll(_getImagesForWeeklyBossNotifications(selectedImage: item.image));
        state = const NotificationState.weeklyBoss();
        break;
      case AppNotificationType.custom:
        images.addAll(_getImagesForCustomNotifications(itemKey: item.itemKey, selectedImage: item.image));
        state = NotificationState.custom(
          itemType: item.notificationItemType,
          scheduledDate: item.completesAt,
          language: _localeService.getLocaleWithoutLang(),
        );
        break;
      default:
        throw Exception('Invalid notification type = ${item.type}');
    }

    return state.copyWith.call(
      key: item.key,
      title: item.title,
      body: item.body,
      note: item.note,
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
        break;
      case AppNotificationType.expedition:
        images.addAll(_getImagesForExpeditionNotifications());
        updatedState = const NotificationState.expedition(expeditionTimeType: ExpeditionTimeType.twentyHours, withTimeReduction: false);
        break;
      case AppNotificationType.farmingArtifacts:
        images.addAll(_getImagesForFarmingArtifactNotifications());
        updatedState = const NotificationState.farmingArtifact();
        break;
      case AppNotificationType.farmingMaterials:
        images.addAll(_getImagesForFarmingMaterialNotifications());
        updatedState = const NotificationState.farmingMaterial();
        break;
      case AppNotificationType.gadget:
        images.addAll(_getImagesForGadgetNotifications());
        updatedState = const NotificationState.gadget();
        break;
      case AppNotificationType.furniture:
        images.addAll(_getImagesForFurnitureNotifications());
        updatedState = const NotificationState.furniture();
        break;
      case AppNotificationType.realmCurrency:
        images.addAll(_getImagesForRealmCurrencyNotifications());
        updatedState = const NotificationState.realmCurrency();
        break;
      case AppNotificationType.weeklyBoss:
        images.addAll(_getImagesForWeeklyBossNotifications());
        updatedState = const NotificationState.weeklyBoss();
        break;
      case AppNotificationType.custom:
        images.addAll(_getImagesForCustomNotifications());
        updatedState = NotificationState.custom(
          itemType: AppNotificationItemType.material,
          scheduledDate: DateTime.now().add(const Duration(days: 1)),
          language: _localeService.getLocaleWithoutLang(),
        );
        break;
      default:
        throw Exception('The provided app notification type = $newValue is not valid');
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
    return state.maybeMap(
      custom: (s) {
        final images = <NotificationItemImage>[];
        switch (newValue) {
          case AppNotificationItemType.character:
            final character = _genshinService.getCharactersForCard().first;
            images.add(NotificationItemImage(itemKey: character.key, image: character.logoName, isSelected: true));
            break;
          case AppNotificationItemType.weapon:
            final weapon = _genshinService.getWeaponsForCard().first;
            images.add(NotificationItemImage(itemKey: weapon.key, image: weapon.image, isSelected: true));
            break;
          case AppNotificationItemType.artifact:
            final artifact = _genshinService.getArtifactsForCard().first;
            images.add(NotificationItemImage(itemKey: artifact.key, image: artifact.image, isSelected: true));
            break;
          case AppNotificationItemType.monster:
            final monster = _genshinService.getAllMonstersForCard().first;
            images.add(NotificationItemImage(itemKey: monster.key, image: monster.image, isSelected: true));
            break;
          case AppNotificationItemType.material:
            final material = _genshinService.getAllMaterialsThatCanBeObtainedFromAnExpedition().first;
            images.add(NotificationItemImage(itemKey: material.key, image: material.fullImagePath, isSelected: true));
            break;
          default:
            throw Exception('The provided notification item type = $newValue is not valid');
        }

        return s.copyWith.call(images: images, itemType: newValue);
      },
      orElse: () => state,
    );
  }

  NotificationState _itemKeySelected(String itemKey) {
    return state.maybeMap(
      custom: (s) {
        final img = _genshinService.getItemImageFromNotificationItemType(itemKey, s.itemType);
        return s.copyWith.call(images: [NotificationItemImage(itemKey: itemKey, image: img, isSelected: true)]);
      },
      orElse: () => state,
    );
  }

  Future<NotificationState> _saveChanges() async {
    try {
      await state.map(
        resin: _saveResinNotification,
        expedition: _saveExpeditionNotification,
        custom: _saveCustomNotification,
        farmingArtifact: _saveFarmingArtifactNotification,
        farmingMaterial: _saveFarmingMaterialNotification,
        gadget: _saveGadgetNotification,
        furniture: _saveFurnitureNotification,
        weeklyBoss: _saveWeeklyBossNotification,
        realmCurrency: _saveRealmCurrencyNotification,
      );

      if (state.key == null) {
        await _telemetryService.trackNotificationCreated(state.type);
      }
    } catch (e, s) {
      _loggingService.error(runtimeType, '_saveChanges: Unknown error while saving changes', e, s);
    }

    return state;
  }

  Future<void> _saveResinNotification(_ResinState s) async {
    final selectedItemKey = _getSelectedItemKey();
    if (s.key != null) {
      final updated = await _dataService.updateResinNotification(
        s.key,
        selectedItemKey,
        s.title,
        s.body,
        s.currentResin,
        s.showNotification,
        note: s.note,
      );
      await _afterNotificationWasUpdated(updated);
      return;
    }

    final notif = await _dataService.saveResinNotification(
      selectedItemKey,
      s.title,
      s.body,
      s.currentResin,
      note: s.note,
      showNotification: s.showNotification,
    );

    if (notif.showNotification) {
      await _notificationService.scheduleNotification(notif.key, notif.title, notif.body, notif.completesAt);
    }
  }

  Future<void> _saveExpeditionNotification(_ExpeditionState s) async {
    final selectedItemKey = _getSelectedItemKey();
    if (s.key != null) {
      final updated = await _dataService.updateExpeditionNotification(
        s.key,
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

    final notif = await _dataService.saveExpeditionNotification(
      selectedItemKey,
      s.title,
      s.body,
      s.expeditionTimeType,
      note: s.note,
      showNotification: s.showNotification,
      withTimeReduction: s.withTimeReduction,
    );
    if (notif.showNotification) {
      await _notificationService.scheduleNotification(notif.key, notif.title, notif.body, notif.completesAt);
    }
  }

  Future<void> _saveFarmingArtifactNotification(_FarmingArtifactState s) async {
    final selectedItemKey = _getSelectedItemKey();
    if (s.key != null) {
      final updated = await _dataService.updateFarmingArtifactNotification(
        s.key,
        selectedItemKey,
        s.artifactFarmingTimeType,
        s.title,
        s.body,
        s.showNotification,
        note: s.note,
      );
      await _afterNotificationWasUpdated(updated);
      return;
    }

    final notif = await _dataService.saveFarmingArtifactNotification(
      selectedItemKey,
      s.artifactFarmingTimeType,
      s.title,
      s.body,
      note: s.note,
      showNotification: s.showNotification,
    );
    if (notif.showNotification) {
      await _notificationService.scheduleNotification(notif.key, notif.title, notif.body, notif.completesAt);
    }
  }

  Future<void> _saveFarmingMaterialNotification(_FarmingMaterialState s) async {
    final selectedItemKey = _getSelectedItemKey();
    if (s.key != null) {
      final updated = await _dataService.updateFarmingMaterialNotification(
        s.key,
        selectedItemKey,
        s.title,
        s.body,
        s.showNotification,
        note: s.note,
      );
      await _afterNotificationWasUpdated(updated);
      return;
    }

    final notif = await _dataService.saveFarmingMaterialNotification(
      selectedItemKey,
      s.title,
      s.body,
      note: s.note,
      showNotification: s.showNotification,
    );
    if (notif.showNotification) {
      await _notificationService.scheduleNotification(notif.key, notif.title, notif.body, notif.completesAt);
    }
  }

  Future<void> _saveGadgetNotification(_GadgetState s) async {
    final selectedItemKey = _getSelectedItemKey();
    if (s.key != null) {
      final updated = await _dataService.updateGadgetNotification(
        s.key,
        selectedItemKey,
        s.title,
        s.body,
        s.showNotification,
        note: s.note,
      );
      await _afterNotificationWasUpdated(updated);
      return;
    }

    final notif = await _dataService.saveGadgetNotification(
      selectedItemKey,
      s.title,
      s.body,
      note: s.note,
      showNotification: s.showNotification,
    );
    if (notif.showNotification) {
      await _notificationService.scheduleNotification(notif.key, notif.title, notif.body, notif.completesAt);
    }
  }

  Future<void> _saveFurnitureNotification(_FurnitureState s) async {
    final selectedItemKey = _getSelectedItemKey();
    if (s.key != null) {
      final updated = await _dataService.updateFurnitureNotification(
        s.key,
        selectedItemKey,
        s.timeType,
        s.title,
        s.body,
        s.showNotification,
        note: s.note,
      );
      await _afterNotificationWasUpdated(updated);
      return;
    }

    final notif = await _dataService.saveFurnitureNotification(
      selectedItemKey,
      s.timeType,
      s.title,
      s.body,
      note: s.note,
      showNotification: s.showNotification,
    );
    if (notif.showNotification) {
      await _notificationService.scheduleNotification(notif.key, notif.title, notif.body, notif.completesAt);
    }
  }

  Future<void> _saveRealmCurrencyNotification(_RealmCurrencyState s) async {
    final selectedItemKey = _getSelectedItemKey();
    if (s.key != null) {
      final updated = await _dataService.updateRealmCurrencyNotification(
        s.key,
        selectedItemKey,
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

    final notif = await _dataService.saveRealmCurrencyNotification(
      selectedItemKey,
      s.currentRealmRankType,
      s.currentTrustRank,
      s.currentRealmCurrency,
      s.title,
      s.body,
      note: s.note,
      showNotification: s.showNotification,
    );
    if (notif.showNotification) {
      await _notificationService.scheduleNotification(notif.key, notif.title, notif.body, notif.completesAt);
    }
  }

  Future<void> _saveWeeklyBossNotification(_WeeklyBossState s) async {
    final selectedItemKey = _getSelectedItemKey();
    if (s.key != null) {
      final updated = await _dataService.updateWeeklyBossNotification(
        s.key,
        selectedItemKey,
        s.title,
        s.body,
        s.showNotification,
        note: s.note,
      );
      await _afterNotificationWasUpdated(updated);
      return;
    }

    final notif = await _dataService.saveWeeklyBossNotification(
      selectedItemKey,
      s.title,
      s.body,
      note: s.note,
      showNotification: s.showNotification,
    );
    if (notif.showNotification) {
      await _notificationService.scheduleNotification(notif.key, notif.title, notif.body, notif.completesAt);
    }
  }

  Future<void> _saveCustomNotification(_CustomState s) async {
    final selectedItemKey = _getSelectedItemKey();
    final now = DateTime.now();
    if (s.key != null) {
      final updated = await _dataService.updateCustomNotification(
        s.key,
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

    final notif = await _dataService.saveCustomNotification(
      selectedItemKey,
      s.title,
      s.body,
      now,
      s.scheduledDate,
      s.itemType,
      note: s.note,
      showNotification: s.showNotification,
    );
    if (notif.showNotification) {
      await _notificationService.scheduleNotification(notif.key, notif.title, notif.body, notif.completesAt);
    }
  }

  String _getSelectedItemKey() {
    final image = state.images.firstWhere((el) => el.isSelected).image;
    return state.maybeMap(
      custom: (s) => _genshinService.getItemKeyFromNotificationType(image, state.type, notificationItemType: s.itemType),
      orElse: () => _genshinService.getItemKeyFromNotificationType(image, state.type),
    );
  }

  List<NotificationItemImage> _getImagesForResin() {
    final material = _genshinService.getMaterialByImage(Assets.getOriginalResinPath());
    return [NotificationItemImage(itemKey: material.key, image: material.fullImagePath, isSelected: true)];
  }

  List<NotificationItemImage> _getImagesForExpeditionNotifications({String selectedImage}) {
    final materials = _genshinService.getAllMaterialsThatCanBeObtainedFromAnExpedition();
    if (selectedImage.isNotNullEmptyOrWhitespace) {
      return materials
          .mapIndex((e, index) => NotificationItemImage(itemKey: e.key, image: e.fullImagePath, isSelected: selectedImage == e.fullImagePath))
          .toList();
    }

    return materials.mapIndex((e, index) => NotificationItemImage(itemKey: e.key, image: e.fullImagePath, isSelected: index == 0)).toList();
  }

  List<NotificationItemImage> _getImagesForFarmingArtifactNotifications({String selectedImage}) {
    final artifact = _genshinService.getArtifactsForCard().first;
    final images = <NotificationItemImage>[];
    images.add(NotificationItemImage(itemKey: artifact.key, image: artifact.image));
    return _getImagesForFarmingNotifications(images, selectedImage: selectedImage);
  }

  List<NotificationItemImage> _getImagesForFarmingMaterialNotifications({String selectedImage}) {
    final materials = _genshinService.getAllMaterialsThatHaveAFarmingRespawnDuration();
    final images = materials.mapIndex((e, index) => NotificationItemImage(itemKey: e.key, image: e.fullImagePath)).toList();
    return _getImagesForFarmingNotifications(images, selectedImage: selectedImage);
  }

  List<NotificationItemImage> _getImagesForFarmingNotifications(List<NotificationItemImage> images, {String selectedImage}) {
    final selected = selectedImage.isNotNullEmptyOrWhitespace ? images.firstWhere((el) => el.image == selectedImage) : images.first;
    final index = images.indexOf(selected);
    images.removeAt(index);
    images.insert(index, selected.copyWith.call(isSelected: true));
    return images;
  }

  List<NotificationItemImage> _getImagesForGadgetNotifications({String selectedImage}) {
    final gadgets = _genshinService.getAllGadgetsForNotifications();
    if (selectedImage.isNotNullEmptyOrWhitespace) {
      return gadgets.map((e) => NotificationItemImage(itemKey: e.key, image: e.fullImagePath, isSelected: e.fullImagePath == selectedImage)).toList();
    }

    return gadgets.mapIndex((e, i) => NotificationItemImage(itemKey: e.key, image: e.fullImagePath, isSelected: i == 0)).toList();
  }

  List<NotificationItemImage> _getImagesForFurnitureNotifications({String selectedImage}) {
    final furniture = _genshinService.getDefaultFurnitureForNotifications();
    if (selectedImage.isNotNullEmptyOrWhitespace) {
      return [NotificationItemImage(itemKey: furniture.key, image: furniture.fullImagePath, isSelected: furniture.fullImagePath == selectedImage)];
    }
    return [NotificationItemImage(itemKey: furniture.key, image: furniture.fullImagePath, isSelected: true)];
  }

  List<NotificationItemImage> _getImagesForRealmCurrencyNotifications({String selectedImage}) {
    final materials = _genshinService.getMaterials(MaterialType.currency, onlyReadyToBeUsed: false);
    //TODO: FIGURE OUT HOW CAN I REMOVE THIS KEY FROM HERE
    return materials
        .where((el) => el.key == 'RealmCurrency')
        .mapIndex((e, i) => NotificationItemImage(itemKey: e.key, image: e.fullImagePath, isSelected: i == 0))
        .toList();
  }

  List<NotificationItemImage> _getImagesForWeeklyBossNotifications({String selectedImage}) {
    final monsters = _genshinService.getMonsters(MonsterType.boss);
    if (selectedImage.isNotNullEmptyOrWhitespace) {
      return monsters
          .map((e) => NotificationItemImage(itemKey: e.key, image: e.fullImagePath, isSelected: e.fullImagePath == selectedImage))
          .toList();
    }

    return monsters.mapIndex((e, i) => NotificationItemImage(itemKey: e.key, image: e.fullImagePath, isSelected: i == 0)).toList();
  }

  List<NotificationItemImage> _getImagesForCustomNotifications({String itemKey, String selectedImage}) {
    if (selectedImage.isNotNullEmptyOrWhitespace) {
      return [NotificationItemImage(itemKey: itemKey, image: selectedImage, isSelected: true)];
    }
    final material = _genshinService.getAllMaterialsThatCanBeObtainedFromAnExpedition().first;
    return [NotificationItemImage(itemKey: material.key, image: material.fullImagePath, isSelected: true)];
  }

  Future<void> _afterNotificationWasUpdated(NotificationItem notif) async {
    await _notificationService.cancelNotification(notif.key);
    if (notif.showNotification && !notif.remaining.isNegative) {
      await _notificationService.scheduleNotification(notif.key, notif.title, notif.body, notif.completesAt);
    }
  }
}
