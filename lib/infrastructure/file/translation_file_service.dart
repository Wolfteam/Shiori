import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/translation_file_service.dart';

class TranslationFileServiceImpl implements TranslationFileService {
  late TranslationFile _translationFile;

  @override
  Future<void> init(AppLanguageType languageType) async {
    final json = await Assets.getJsonFromPath(Assets.getTranslationPath(languageType));
    _translationFile = TranslationFile.fromJson(json);
  }

  @override
  TranslationCharacterFile getCharacterTranslation(String key) {
    return _translationFile.characters.firstWhere((element) => element.key == key);
  }

  @override
  TranslationWeaponFile getWeaponTranslation(String key) {
    return _translationFile.weapons.firstWhere((element) => element.key == key);
  }

  @override
  TranslationArtifactFile getArtifactTranslation(String key) {
    return _translationFile.artifacts.firstWhere((t) => t.key == key);
  }

  @override
  TranslationMaterialFile getMaterialTranslation(String key) {
    return _translationFile.materials.firstWhere((t) => t.key == key);
  }

  @override
  TranslationMonsterFile getMonsterTranslation(String key) {
    return _translationFile.monsters.firstWhere((el) => el.key == key);
  }

  @override
  TranslationElementFile getDebuffTranslation(String key) {
    return _translationFile.debuffs.firstWhere((el) => el.key == key);
  }

  @override
  TranslationElementFile getReactionTranslation(String key) {
    return _translationFile.reactions.firstWhere((el) => el.key == key);
  }

  @override
  TranslationElementFile getResonanceTranslation(String key) {
    return _translationFile.resonance.firstWhere((el) => el.key == key);
  }
}
