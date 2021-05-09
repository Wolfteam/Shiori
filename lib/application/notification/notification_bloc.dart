import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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

part 'notification_bloc.freezed.dart';
part 'notification_event.dart';
part 'notification_state.dart';

final _initialState = NotificationState.resin(
  images: [NotificationItemImage(image: Assets.getOriginalResinPath(), isSelected: true)],
  showNotification: true,
  currentResin: 0,
);

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final DataService _dataService;
  final NotificationService _notificationService;
  final GenshinService _genshinService;
  final LocaleService _localeService;
  final LoggingService _loggingService;

  static int get maxTitleLength => 40;

  static int get maxBodyLength => 40;

  static int get maxNoteLength => 100;

  NotificationBloc(
    this._dataService,
    this._notificationService,
    this._genshinService,
    this._localeService,
    this._loggingService,
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
        isTitleValid: e.newValue.isValidLength(maxLength: maxTitleLength),
        isTitleDirty: true,
      ),
      bodyChanged: (e) async => state.copyWith.call(
        body: e.newValue,
        isBodyValid: e.newValue.isValidLength(maxLength: maxBodyLength),
        isBodyDirty: true,
      ),
      noteChanged: (e) async => state.copyWith.call(
        note: e.newValue,
        isNoteValid: e.newValue.isNullEmptyOrWhitespace || e.newValue.isValidLength(maxLength: maxNoteLength),
        isNoteDirty: true,
      ),
      showNotificationChanged: (e) async => state.copyWith.call(showNotification: e.show),
      expeditionTimeTypeChanged: (e) async => state.map(
        resin: (_) => state,
        expedition: (s) => s.copyWith.call(expeditionTimeType: e.newValue),
        custom: (s) => state,
      ),
      resinChanged: (e) async => state.map(
        resin: (s) => s.copyWith.call(currentResin: e.newValue),
        expedition: (_) => state,
        custom: (_) => state,
      ),
      itemTypeChanged: (e) async => state.map(
        resin: (_) => state,
        expedition: (_) => state,
        custom: (s) => _itemTypeChanged(e.newValue),
      ),
      saveChanges: (e) async => _saveChanges(),
      timeReductionChanged: (e) async => state.map(
        resin: (_) => state,
        expedition: (s) => s.copyWith.call(withTimeReduction: e.withTimeReduction),
        custom: (_) => state,
      ),
      showOtherImages: (e) async => state.copyWith.call(showOtherImages: e.show),
      imageChanged: (e) async {
        final images = state.images.map((el) => el.copyWith.call(isSelected: el.image == e.newValue)).toList();
        return state.copyWith.call(images: images);
      },
      keySelected: (e) async => _itemKeySelected(e.keyName),
      customDateChanged: (e) async => state.map(
        resin: (_) => state,
        expedition: (_) => state,
        custom: (s) => s.copyWith.call(scheduledDate: e.newValue),
      ),
    );

    yield s;
  }

  NotificationState _buildAddState(String title, String body) {
    return _initialState.copyWith.call(title: title, body: body, isTitleValid: true, isBodyValid: true);
  }

  NotificationState _buildEditState(int key) {
    final item = _dataService.getNotification(key);
    switch (item.type) {
      case AppNotificationType.resin:
        return NotificationState.resin(
          key: item.key,
          type: item.type,
          showNotification: item.showNotification,
          currentResin: item.currentResinValue,
          note: item.note,
          title: item.title,
          body: item.body,
        );
      case AppNotificationType.expedition:
        return NotificationState.expedition(
          key: item.key,
          type: item.type,
          showNotification: item.showNotification,
          expeditionTimeType: item.expeditionTimeType,
          note: item.note,
          withTimeReduction: item.withTimeReduction,
          title: item.title,
          body: item.body,
        );
      case AppNotificationType.custom:
        return NotificationState.custom(
          key: item.key,
          type: item.type,
          showNotification: item.showNotification,
          itemType: item.notificationItemType,
          note: item.note,
          title: item.title,
          body: item.body,
          scheduledDate: item.completesAt,
          language: _localeService.getLocaleWithoutLang(),
        );
    }
    throw Exception('Invalid notification type = ${item.type}');
  }

  NotificationState _typeChanged(AppNotificationType newValue) {
    switch (newValue) {
      case AppNotificationType.resin:
        return _initialState.copyWith.call(
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
      case AppNotificationType.expedition:
        final images = _genshinService
            .getAllMaterialsThatCanBeObtainedFromAnExpedition()
            .mapIndex((e, index) => NotificationItemImage(image: e.fullImagePath, isSelected: index == 0))
            .toList();
        return NotificationState.expedition(
          images: images,
          showNotification: state.showNotification,
          expeditionTimeType: ExpeditionTimeType.twentyHours,
          withTimeReduction: false,
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
      case AppNotificationType.custom:
        final material = _genshinService.getAllMaterialsThatCanBeObtainedFromAnExpedition().first;
        return NotificationState.custom(
          images: [NotificationItemImage(image: material.fullImagePath, isSelected: true)],
          itemType: AppNotificationItemType.material,
          showNotification: state.showNotification,
          title: state.title,
          body: state.body,
          note: state.note,
          scheduledDate: DateTime.now().add(const Duration(days: 1)),
          language: _localeService.getLocaleWithoutLang(),
          isTitleValid: state.isTitleValid,
          isTitleDirty: state.isTitleDirty,
          isBodyValid: state.isBodyValid,
          isBodyDirty: state.isBodyDirty,
          isNoteValid: state.isNoteValid,
          isNoteDirty: state.isNoteDirty,
        );
      default:
        throw Exception('The provided app notification type = $newValue is not valid');
    }
  }

  NotificationState _itemTypeChanged(AppNotificationItemType newValue) {
    return state.map(
      resin: (_) => state,
      expedition: (_) => state,
      custom: (s) {
        final images = <NotificationItemImage>[];
        switch (newValue) {
          case AppNotificationItemType.character:
            final character = _genshinService.getCharactersForCard().first;
            images.add(NotificationItemImage(image: character.logoName, isSelected: true));
            break;
          case AppNotificationItemType.weapon:
            final weapon = _genshinService.getWeaponsForCard().first;
            images.add(NotificationItemImage(image: weapon.image, isSelected: true));
            break;
          case AppNotificationItemType.artifact:
            final artifact = _genshinService.getArtifactsForCard().first;
            images.add(NotificationItemImage(image: artifact.image, isSelected: true));
            break;
          case AppNotificationItemType.monster:
            final monster = _genshinService.getAllMonstersForCard().first;
            images.add(NotificationItemImage(image: monster.image, isSelected: true));
            break;
          case AppNotificationItemType.material:
            final material = _genshinService.getAllMaterialsThatCanBeObtainedFromAnExpedition().first;
            images.add(NotificationItemImage(image: material.fullImagePath, isSelected: true));
            break;
          default:
            throw Exception('The provided notification item type = $newValue is not valid');
        }

        return s.copyWith.call(images: images, itemType: newValue);
      },
    );
  }

  NotificationState _itemKeySelected(String itemKey) {
    return state.map(
      resin: (_) => state,
      expedition: (_) => state,
      custom: (s) {
        final img = _genshinService.getItemImageFromNotificationItemType(itemKey, s.itemType);
        return s.copyWith.call(images: [NotificationItemImage(image: img, isSelected: true)]);
      },
    );
  }

  Future<NotificationState> _saveChanges() async {
    //TODO: IMPLEMENT EDITING THE NOTIFICATION
    //TODO: GET THE ITEM KEY WHILE SAVING
    try {
      await state.map(
        resin: _saveResinNotification,
        expedition: _saveExpeditionNotification,
        custom: _saveCustomNotification,
      );
    } catch (e, s) {
      //TODO: SHOW AN ERROR IN THE UI
      _loggingService.error(runtimeType, '_saveChanges: Unknown error while saving changes', e, s);
    }

    return state;
  }

  Future<void> _saveResinNotification(_ResinState s) async {
    final selectedItemKey = _getSelectedItemKey();
    if (s.key != null) {
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

  Future<void> _saveCustomNotification(_CustomState s) async {
    final selectedItemKey = _getSelectedItemKey();
    final now = DateTime.now();
    if (s.key != null) {
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
    return state.map(
      resin: (_) => _genshinService.getItemKeyFromNotificationType(image, state.type),
      expedition: (_) => _genshinService.getItemKeyFromNotificationType(image, state.type),
      custom: (s) => _genshinService.getItemKeyFromNotificationType(image, state.type, notificationItemType: s.itemType),
    );
  }
}
