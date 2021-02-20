import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../enums/app_accent_color_type.dart';
import '../../enums/app_language_type.dart';
import '../../enums/app_theme_type.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
abstract class AppSettings implements _$AppSettings {
  factory AppSettings({
    @required AppThemeType appTheme,
    @required bool useDarkAmoled,
    @required AppAccentColorType accentColor,
    @required AppLanguageType appLanguage,
    @required bool showCharacterDetails,
    @required bool showWeaponDetails,
    @required bool isFirstInstall,
  }) = _AppSettings;
  const AppSettings._();

  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
}
