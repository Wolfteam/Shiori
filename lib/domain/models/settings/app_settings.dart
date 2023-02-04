import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
class AppSettings with _$AppSettings {
  factory AppSettings({
    required AppThemeType appTheme,
    required bool useDarkAmoled,
    required AppAccentColorType accentColor,
    required AppLanguageType appLanguage,
    required bool showCharacterDetails,
    required bool showWeaponDetails,
    required bool isFirstInstall,
    required AppServerResetTimeType serverResetTime,
    required bool doubleBackToClose,
    required bool useOfficialMap,
    required bool useTwentyFourHoursFormat,
    required int resourceVersion,
    required bool checkForUpdatesOnStartup,
  }) = _AppSettings;
  const AppSettings._();

  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
}
