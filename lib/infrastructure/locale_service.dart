import 'package:genshindb/domain/app_constants.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/locale_service.dart';
import 'package:genshindb/domain/services/settings_service.dart';
import 'package:intl/intl.dart';

class LocaleServiceImpl implements LocaleService {
  final SettingsService _settingsService;

  LocaleServiceImpl(this._settingsService);

  @override
  DateTime getCharBirthDate(String birthday) {
    if (birthday.isNullEmptyOrWhitespace) {
      throw Exception('Character birthday must not be null');
    }
    final locale = getFormattedLocale(_settingsService.language);
    final format = DateFormat('MM/dd', locale);
    return format.parse(birthday);
  }

  @override
  String formatCharBirthDate(String birthday) {
    if (birthday.isNullEmptyOrWhitespace) {
      return '';
    }
    final locale = getFormattedLocale(_settingsService.language);
    final birthdayDate = getCharBirthDate(birthday);
    return toBeginningOfSentenceCase(DateFormat('MMMM d', locale).format(birthdayDate));
  }

  @override
  String getFormattedLocale(AppLanguageType language) {
    final locale = getLocale(language);
    return '${locale.code}_${locale.countryCode}';
  }

  @override
  LanguageModel getLocaleWithoutLang() {
    return getLocale(_settingsService.language);
  }

  @override
  LanguageModel getLocale(AppLanguageType language) {
    if (!languagesMap.entries.any((kvp) => kvp.key == language)) {
      throw Exception('The language = $language is not a valid value');
    }

    return languagesMap.entries.firstWhere((kvp) => kvp.key == language).value;
  }
}
