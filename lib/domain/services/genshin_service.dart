import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

abstract class GenshinService {
  Future<void> init(AppLanguageType languageType);
  Future<void> initCharacters();
  Future<void> initWeapons();
  Future<void> initArtifacts();
  Future<void> initMaterials();
  Future<void> initElements();
  Future<void> initMonsters();
  Future<void> initGadgets();
  Future<void> initFurniture();
  Future<void> initTranslations(AppLanguageType languageType);

  List<CharacterCardModel> getCharactersForCard();
  CharacterCardModel getCharacterForCard(String key);
  CharacterFileModel getCharacter(String key);
  CharacterFileModel getCharacterByImg(String img);
  List<CharacterFileModel> getCharactersForBirthday(DateTime date);
  List<TierListRowModel> getDefaultCharacterTierList(List<int> colors);
  List<String> getUpcomingCharactersKeys();

  List<WeaponCardModel> getWeaponsForCard();
  WeaponCardModel getWeaponForCard(String key);
  WeaponCardModel getWeaponForCardByImg(String image);
  WeaponFileModel getWeapon(String key);
  WeaponFileModel getWeaponByImg(String img);
  List<String> getUpcomingWeaponsKeys();

  List<ArtifactCardModel> getArtifactsForCard();
  ArtifactCardModel getArtifactForCardByImg(String image);
  ArtifactFileModel getArtifact(String key);

  //TODO: RENAME THIS METHODS
  List<ItemCommon> getCharacterImgsUsingWeapon(String key);
  List<ItemCommon> getCharacterImgsUsingArtifact(String key);
  List<ItemCommon> getCharacterImgsUsingMaterial(String key);
  List<ItemCommon> getWeaponImgsUsingMaterial(String key);
  List<ItemCommon> getRelatedMonsterImgsToMaterial(String key);
  List<ItemCommon> getRelatedMonsterImgsToArtifact(String key);

  TranslationArtifactFile getArtifactTranslation(String key);
  TranslationCharacterFile getCharacterTranslation(String key);
  TranslationWeaponFile getWeaponTranslation(String key);
  TranslationMaterialFile getMaterialTranslation(String key);
  List<MaterialFileModel> getAllMaterialsThatCanBeObtainedFromAnExpedition();
  List<MaterialFileModel> getAllMaterialsThatHaveAFarmingRespawnDuration();

  List<TodayCharAscensionMaterialsModel> getCharacterAscensionMaterials(int day);
  List<TodayWeaponAscensionMaterialModel> getWeaponAscensionMaterials(int day);

  List<ElementCardModel> getElementDebuffs();
  List<ElementReactionCardModel> getElementReactions();
  List<ElementReactionCardModel> getElementResonances();

  List<MaterialCardModel> getAllMaterialsForCard();
  MaterialCardModel getMaterialForCard(String key);
  MaterialFileModel getMaterial(String key);
  MaterialFileModel getMaterialByImage(String image);
  List<MaterialFileModel> getMaterials(MaterialType type, {bool onlyReadyToBeUsed = true});
  MaterialFileModel getMoraMaterial();
  String getMaterialImg(String key);

  int getServerDay(AppServerResetTimeType type);
  DateTime getServerDate(AppServerResetTimeType type);
  Duration getDurationUntilServerResetDate(AppServerResetTimeType type);

  List<String> getUpcomingKeys();

  MonsterFileModel getMonster(String key);
  MonsterFileModel getMonsterByImg(String image);
  List<MonsterCardModel> getAllMonstersForCard();
  MonsterCardModel getMonsterForCardByImg(String image);
  List<MonsterFileModel> getMonsters(MonsterType type);

  String getItemImageFromNotificationType(String itemKey, AppNotificationType notificationType, {AppNotificationItemType? notificationItemType});
  String getItemImageFromNotificationItemType(String itemKey, AppNotificationItemType notificationItemType);
  String getItemKeyFromNotificationType(String itemImage, AppNotificationType notificationType, {AppNotificationItemType? notificationItemType});

  List<GadgetFileModel> getAllGadgetsForNotifications();
  GadgetFileModel getGadget(String key);
  GadgetFileModel getGadgetByImage(String image);

  FurnitureFileModel getDefaultFurnitureForNotifications();
  FurnitureFileModel getFurniture(String key);
  FurnitureFileModel getFurnitureByImage(String image);

  DateTime getNextDateForWeeklyBoss(AppServerResetTimeType type);
}
