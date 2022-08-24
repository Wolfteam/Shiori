import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

abstract class TranslationFileService {
  Future<void> init(AppLanguageType languageType);

  TranslationCharacterFile getCharacterTranslation(String key);

  TranslationWeaponFile getWeaponTranslation(String key);

  TranslationArtifactFile getArtifactTranslation(String key);

  TranslationMaterialFile getMaterialTranslation(String key);

  TranslationMonsterFile getMonsterTranslation(String key);

  TranslationElementFile getDebuffTranslation(String key);

  TranslationElementFile getReactionTranslation(String key);

  TranslationElementFile getResonanceTranslation(String key);
}
