import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/notification_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const _channelId = 'shiori_channel';
const _channelName = 'Notifications';
const _channelDescription = 'Notifications from the app';
const _largeIcon = 'shiori';

//Here we use this one in particular cause this tz uses UTC and does not use any kind of dst.
const _fallbackTimeZone = 'Africa/Accra';

AppPushNotificationType? _getPushNotificationType(RemoteMessage message) {
  final String? category = message.data['category']?.toString().toLowerCase();
  if (category.isNullEmptyOrWhitespace) {
    return null;
  }

  return AppPushNotificationType.values.firstWhereOrNull((e) => e.name.toLowerCase() == category);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    final AppPushNotificationType? type = _getPushNotificationType(message);
    if (type == null) {
      return;
    }

    await Injection.init();
    final notificationService = getIt<NotificationService>();
    final localeService = getIt<LocaleService>();

    final LanguageModel language = localeService.getLocaleWithoutLang();
    final s = await S.load(Locale(language.code, language.countryCode));

    final translations = PushNotificationTranslations.fromS(s: s);
    await notificationService.showPushNotification(type, translations);
  } catch (e, s) {
    debugPrint(e.toString());
    debugPrintStack(stackTrace: s);
  }
}

class NotificationServiceImpl implements NotificationService {
  static bool isPlatformSupported = [Platform.isAndroid, Platform.isIOS, Platform.isMacOS].any((el) => el);

  final LoggingService _loggingService;
  final SettingsService _settingsService;

  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  late tz.Location _location;

  NotificationServiceImpl(this._loggingService, this._settingsService);

  @override
  Future<void> init() async {
    try {
      //TODO: TIMEZONES ON WINDOWS
      if (!isPlatformSupported) {
        return;
      }
      tz.initializeTimeZones();
      final currentTimeZone = await FlutterTimezone.getLocalTimezone();
      _location = tz.getLocation(currentTimeZone);
      tz.setLocalLocation(_location);
    } on tz.LocationNotFoundException catch (e) {
      //https://github.com/srawlins/timezone/issues/92
      _loggingService.info(runtimeType, 'init: ${e.msg}, assigning the generic one...');
      _setDefaultTimeZone();
    } catch (e, s) {
      _loggingService.error(runtimeType, 'init: Failed to get timezone or device is GMT or UTC, assigning the generic one...', e, s);
      _setDefaultTimeZone();
    }

    try {
      //This call fails in bg, that's why we try catch this
      if (!Platform.isMacOS) {
        await Permission.notification.request();
      }
    } catch (e, s) {
      _loggingService.error(runtimeType, 'init: Failed to request permission', e, s);
    }

    try {
      const android = AndroidInitializationSettings('ic_notification');
      const iOS = DarwinInitializationSettings();
      const macOS = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(android: android, iOS: iOS, macOS: macOS);
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    } catch (e, s) {
      _loggingService.error(runtimeType, 'init: Unknown error occurred', e, s);
    }
  }

  @override
  Future<List<StreamSubscription>> initPushNotifications(PushNotificationTranslations translations) async {
    final List<StreamSubscription> subscriptions = [];
    final fcm = FirebaseMessaging.instance;
    if (!await fcm.isSupported()) {
      return subscriptions;
    }
    try {
      subscriptions.addAll([
        fcm.onTokenRefresh.listen(_onTokenRefresh),
        FirebaseMessaging.onMessage.listen((msg) => _onForegroundPushNotification(translations, msg)),
      ]);
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await fcm.requestPermission(provisional: true);
      if (Platform.isMacOS || Platform.isIOS) {
        await fcm.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
        await fcm.getAPNSToken();
      }

      final deviceToken = await fcm.getToken();
      if (deviceToken.isNotNullEmptyOrWhitespace) {
        debugPrint(deviceToken);
        await _onTokenRefresh(deviceToken!);
      }
    } catch (e, s) {
      _loggingService.error(runtimeType, 'init: Unknown error occurred', e, s);
    }
    return subscriptions;
  }

  @override
  Future<void> showNotification(int id, AppNotificationType type, String title, String body, {String? payload}) {
    if (!isPlatformSupported) {
      return Future.value();
    }
    final specifics = _getPlatformChannelSpecifics(type, body);
    final newId = _generateUniqueId(id, type);
    return _flutterLocalNotificationsPlugin.show(newId, title, body, specifics, payload: payload);
  }

  @override
  Future<void> showPushNotification(AppPushNotificationType type, PushNotificationTranslations translations, {String? payload}) async {
    if (!isPlatformSupported) {
      return Future.value();
    }

    int id = 0;
    String? title;
    String? body;
    switch (type) {
      case AppPushNotificationType.newGameCodesAvailable:
        id = 1;
        title = translations.newGameCodesAvailableTitle;
        body = translations.newGameCodesAvailableMessage;
        _settingsService.lastGameCodesCheckedDate = null;
      default:
        break;
    }

    final bool show = title.isNotNullEmptyOrWhitespace && body.isNotNullEmptyOrWhitespace;
    if (!show) {
      return;
    }

    final specifics = _getPlatformChannelSpecifics(type, body!);
    final newId = _generateUniqueId(id, type);
    return _flutterLocalNotificationsPlugin.show(newId, title, body, specifics, payload: payload);
  }

  @override
  Future<void> cancelNotification(int id, AppNotificationType type) {
    if (!isPlatformSupported) {
      return Future.value();
    }
    final realId = _generateUniqueId(id, type);
    return _flutterLocalNotificationsPlugin.cancel(realId, tag: _getTagFromNotificationType(type));
  }

  @override
  Future<void> cancelAllNotifications() {
    if (!isPlatformSupported) {
      return Future.value();
    }
    return _flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Future<void> scheduleNotification(int id, AppNotificationType type, String title, String body, DateTime toBeDeliveredOn) async {
    if (!isPlatformSupported) {
      return;
    }
    //Due to changes starting from android 14, we need to request for special permissions...
    if (Platform.isAndroid) {
      final bool? granted = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
          .requestExactAlarmsPermission();

      if (granted == null || !granted) {
        return;
      }
    }
    final now = DateTime.now();
    final payload = '${id}_${_getTagFromNotificationType(type)}';
    if (toBeDeliveredOn.isBefore(now) || toBeDeliveredOn.isAtSameMomentAs(now)) {
      await showNotification(id, type, title, body, payload: payload);
      return;
    }
    final newId = _generateUniqueId(id, type);
    final specifics = _getPlatformChannelSpecifics(type, body);
    final scheduledDate = tz.TZDateTime.from(toBeDeliveredOn, _location);
    return _flutterLocalNotificationsPlugin.zonedSchedule(
      newId,
      title,
      body,
      scheduledDate,
      specifics,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  void _setDefaultTimeZone() {
    _location = tz.getLocation(_fallbackTimeZone);
    tz.setLocalLocation(_location);
  }

  NotificationDetails _getPlatformChannelSpecifics<T extends Enum>(T type, String body) {
    final style = body.length < 40 ? null : BigTextStyleInformation(body);
    final android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      color: Colors.red,
      styleInformation: style,
      largeIcon: const DrawableResourceAndroidBitmap(_largeIcon),
      tag: _getTagFromNotificationType(type),
    );
    const iOS = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true, threadIdentifier: _channelId);
    const macOS = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true, threadIdentifier: _channelId);

    return NotificationDetails(android: android, iOS: iOS, macOS: macOS);
  }

  String _getTagFromNotificationType<T extends Enum>(T type) {
    return type.name;
  }

  // For some reason I need to provide a unique id even if I'm providing a custom tag
  // That's why we generate this id here
  int _generateUniqueId<T extends Enum>(int id, T type) {
    final prefix = _getIdPrefix(type).toString();
    final newId = '$prefix$id';
    return int.parse(newId);
  }

  int _getIdPrefix<T extends Enum>(T type) {
    if (type is AppNotificationType) {
      return switch (type) {
        AppNotificationType.resin => 10,
        AppNotificationType.expedition => 20,
        AppNotificationType.farmingMaterials => 30,
        AppNotificationType.farmingArtifacts => 40,
        AppNotificationType.gadget => 50,
        AppNotificationType.furniture => 60,
        AppNotificationType.realmCurrency => 70,
        AppNotificationType.weeklyBoss => 80,
        AppNotificationType.custom => 90,
        AppNotificationType.dailyCheckIn => 100,
      };
    }

    if (type is AppPushNotificationType) {
      return switch (type) {
        AppPushNotificationType.newGameCodesAvailable => 11,
      };
    }

    throw Exception('Type = ${type.name} is not supported');
  }

  Future<void> _onForegroundPushNotification(PushNotificationTranslations translations, RemoteMessage message) async {
    final AppPushNotificationType? type = _getPushNotificationType(message);
    if (type == null) {
      return;
    }

    await showPushNotification(type, translations);
  }

  Future<void> _onTokenRefresh(String deviceToken) async {
    if (_settingsService.pushNotificationsToken != deviceToken) {
      _settingsService.pushNotificationsToken = deviceToken;
      _settingsService.mustRegisterPushNotificationsToken = true;
    }
    return Future.value();
  }
}
