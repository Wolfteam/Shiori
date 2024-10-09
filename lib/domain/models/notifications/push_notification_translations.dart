import 'package:shiori/generated/l10n.dart';

class PushNotificationTranslations {
  final String newGameCodesAvailableTitle;
  final String newGameCodesAvailableMessage;

  const PushNotificationTranslations({
    required this.newGameCodesAvailableTitle,
    required this.newGameCodesAvailableMessage,
  });

  PushNotificationTranslations.fromS({required S s})
      : newGameCodesAvailableTitle = s.appName,
        newGameCodesAvailableMessage = s.newGameCodesAvailable;
}
