import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/translation_file_service.dart';
import 'package:shiori/domain/services/resources_service.dart';

class TranslationFileServiceImpl extends TranslationFileService {
  late TranslationFile _translationFile;

  late AppLanguageType _currentLanguage;

  AppLanguageType get currentLanguage => _currentLanguage;

  @override
  ResourceService get resources => throw UnimplementedError('Resource service is not required in this file');

  @override
  TranslationFileService get translations => this;

  @override
  Future<void> init(String assetPath, {bool noResourcesHaveBeenDownloaded = false}) {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  Future<void> initTranslations(AppLanguageType languageType, String assetPath, {bool noResourcesHaveBeenDownloaded = false}) async {
    _currentLanguage = languageType;
    if (noResourcesHaveBeenDownloaded) {
      _translationFile = TranslationFile(
        characters: [],
        weapons: [],
        artifacts: [],
        materials: [],
        debuffs: [],
        reactions: [],
        resonance: [],
        monsters: [],
      );
      return;
    }
    final json = await readJson(assetPath);
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
