import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';

abstract class SettingsService {
  AppSettings get appSettings;

  AppThemeType get appTheme;
  set appTheme(AppThemeType theme);

  AppAccentColorType get accentColor;
  set accentColor(AppAccentColorType accentColor);

  AppLanguageType get language;
  set language(AppLanguageType lang);

  bool get isFirstInstall;
  set isFirstInstall(bool itIs);

  bool get showCharacterDetails;
  set showCharacterDetails(bool show);

  bool get showWeaponDetails;
  set showWeaponDetails(bool show);

  Future<void> init();
}
