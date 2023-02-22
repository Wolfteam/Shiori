import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'backup_app_settings_model.freezed.dart';
part 'backup_app_settings_model.g.dart';

@freezed
class BackupAppSettingsModel with _$BackupAppSettingsModel {
  const factory BackupAppSettingsModel({
    AppThemeType? appTheme,
    bool? useDarkAmoled,
    AppAccentColorType? accentColor,
    AppLanguageType? appLanguage,
    bool? showCharacterDetails,
    bool? showWeaponDetails,
    AppServerResetTimeType? serverResetTime,
    bool? doubleBackToClose,
    bool? useOfficialMap,
    bool? useTwentyFourHoursFormat,
    bool? checkForUpdatesOnStartup,
  }) = _BackupAppSettingsModel;

  factory BackupAppSettingsModel.fromJson(Map<String, dynamic> json) => _$BackupAppSettingsModelFromJson(json);
}
