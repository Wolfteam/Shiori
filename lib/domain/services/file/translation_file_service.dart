import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/base_file_service.dart';

abstract class TranslationFileService extends BaseFileService {
  Future<void> initTranslations(AppLanguageType languageType, String assetPath, {bool noResourcesHaveBeenDownloaded = false});

  TranslationCharacterFile getCharacterTranslation(String key);

  TranslationWeaponFile getWeaponTranslation(String key);

  TranslationArtifactFile getArtifactTranslation(String key);

  TranslationMaterialFile getMaterialTranslation(String key);

  TranslationMonsterFile getMonsterTranslation(String key);

  TranslationElementFile getDebuffTranslation(String key);

  TranslationElementFile getReactionTranslation(String key);

  TranslationElementFile getResonanceTranslation(String key);
}
