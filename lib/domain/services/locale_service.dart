import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

abstract class LocaleService {
  LanguageModel getLocaleWithoutLang();

  LanguageModel getLocale(AppLanguageType language);

  String getFormattedLocale(AppLanguageType language);

  DateTime getCharBirthDate(String? birthday, {bool useCurrentYear = false});

  String formatCharBirthDate(String? birthday);

  String getDayNameFromDate(DateTime date);

  String getDayNameFromDay(int day);
}
