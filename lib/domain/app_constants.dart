//This order matches the one in the game, and the numbers represent each image
import 'package:genshindb/domain/enums/enums.dart';

import 'models/models.dart';

const artifactOrder = [4, 2, 5, 1, 3];

final languagesMap = {
  AppLanguageType.english: LanguageModel('en', 'US'),
  AppLanguageType.spanish: LanguageModel('es', 'ES'),
  AppLanguageType.simplifiedChinese: LanguageModel('zh', 'CN'),
  // AppLanguageType.french: LanguageModel('fr', 'FR'),
};
