import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';

abstract class GenshinService {
  Future<void> init(AppLanguageType languageType);
  Future<void> initCharacters();
  Future<void> initWeapons();
  Future<void> initArtifacts();
  Future<void> initMaterials();
  Future<void> initElements();
  Future<void> initTranslations(AppLanguageType languageType);

  List<CharacterCardModel> getCharactersForCard();
  CharacterFileModel getCharacter(String key);
  CharacterFileModel getCharacterByImg(String img);
  List<CharacterFileModel> getCharactersForBirthday(DateTime date);

  List<WeaponCardModel> getWeaponsForCard();
  WeaponCardModel getWeaponForCardByImg(String image);
  WeaponFileModel getWeapon(String key);
  WeaponFileModel getWeaponByImg(String img);
  List<String> getCharactersImgUsingWeapon(String key);

  List<ArtifactCardModel> getArtifactsForCard();
  ArtifactCardModel getArtifactForCardByImg(String image);
  ArtifactFileModel getArtifact(String key);
  List<String> getCharactersImgUsingArtifact(String key);

  TranslationArtifactFile getArtifactTranslation(String key);
  TranslationCharacterFile getCharacterTranslation(String key);
  TranslationWeaponFile getWeaponTranslation(String key);

  List<TodayCharAscensionMaterialsModel> getCharacterAscensionMaterials(int day);
  List<TodayWeaponAscensionMaterialModel> getWeaponAscensionMaterials(int day);

  List<ElementCardModel> getElementDebuffs();
  List<ElementReactionCardModel> getElementReactions();
  List<ElementReactionCardModel> getElementResonances();

  MaterialFileModel getMaterialByImage(String image);
}
