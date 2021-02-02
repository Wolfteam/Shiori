import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';

abstract class LocaleService {
  LanguageModel getLocaleWithoutLang();

  LanguageModel getLocale(AppLanguageType language);

  String getFormattedLocale(AppLanguageType language);

  DateTime getCharBirthDate(String birthday);

  String formatCharBirthDate(String birthday);
}
