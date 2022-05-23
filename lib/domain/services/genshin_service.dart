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
  Future<void> initBannerHistory();
  Future<void> initTranslations(AppLanguageType languageType);

  List<CharacterCardModel> getCharactersForCard();
  CharacterCardModel getCharacterForCard(String key);
  CharacterFileModel getCharacter(String key);
  List<CharacterFileModel> getCharactersForBirthday(DateTime date);
  List<TierListRowModel> getDefaultCharacterTierList(List<int> colors);
  List<String> getUpcomingCharactersKeys();
  List<CharacterSkillStatModel> getCharacterSkillStats(List<CharacterFileSkillStatModel> skillStats, List<String> statsTranslations);

  List<WeaponCardModel> getWeaponsForCard();
  WeaponCardModel getWeaponForCard(String key);
  WeaponFileModel getWeapon(String key);
  List<String> getUpcomingWeaponsKeys();

  List<ArtifactCardModel> getArtifactsForCard({ArtifactType? type});
  ArtifactCardModel getArtifactForCard(String key);
  ArtifactFileModel getArtifact(String key);

  List<ItemCommon> getCharacterForItemsUsingWeapon(String key);
  List<ItemCommon> getCharacterForItemsUsingArtifact(String key);
  List<ItemCommon> getCharacterForItemsUsingMaterial(String key);
  List<ItemCommon> getWeaponForItemsUsingMaterial(String key);
  List<ItemCommon> getRelatedMonsterToMaterialForItems(String key);
  List<ItemCommon> getRelatedMonsterToArtifactForItems(String key);

  TranslationArtifactFile getArtifactTranslation(String key);
  TranslationCharacterFile getCharacterTranslation(String key);
  TranslationWeaponFile getWeaponTranslation(String key);
  TranslationMaterialFile getMaterialTranslation(String key);
  TranslationMonsterFile getMonsterTranslation(String key);
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
  List<MonsterCardModel> getAllMonstersForCard();
  MonsterCardModel getMonsterForCard(String key);
  List<MonsterFileModel> getMonsters(MonsterType type);

  String getItemImageFromNotificationType(String itemKey, AppNotificationType notificationType, {AppNotificationItemType? notificationItemType});
  String getItemImageFromNotificationItemType(String itemKey, AppNotificationItemType notificationItemType);

  List<GadgetFileModel> getAllGadgetsForNotifications();
  GadgetFileModel getGadget(String key);

  FurnitureFileModel getDefaultFurnitureForNotifications();
  FurnitureFileModel getFurniture(String key);

  DateTime getNextDateForWeeklyBoss(AppServerResetTimeType type);

  List<ArtifactCardBonusModel> getArtifactBonus(TranslationArtifactFile translation);
  List<String> getArtifactRelatedParts(String fullImagePath, String image, int bonus);
  String getArtifactRelatedPart(String fullImagePath, String image, int bonus, ArtifactType type);
  List<StatType> generateSubStatSummary(List<CustomBuildArtifactModel> artifacts);

  List<double> getBannerHistoryVersions(SortDirectionType type);
  List<BannerHistoryItemModel> getBannerHistory(BannerHistoryItemType type);
  List<BannerHistoryPeriodModel> getBanners(double version);
  List<ItemReleaseHistoryModel> getItemReleaseHistory(String itemKey);

  List<ChartTopItemModel> getTopCharts(ChartType type);
  List<ChartBirthdayMonthModel> getCharacterBirthdaysForCharts();
  List<ChartElementItemModel> getElementsForCharts(double fromVersion, double untilVersion);
  List<ChartAscensionStatModel> getItemAscensionStatsForCharts(ItemType itemType);
  List<ChartCharacterRegionModel> getCharacterRegionsForCharts();
  List<ChartGenderModel> getCharacterGendersForCharts();
  ChartGenderModel getCharacterGendersByRegionForCharts(RegionType regionType);
  List<ItemCommonWithName> getCharactersForItemsByRegion(RegionType regionType);
  List<ItemCommonWithName> getCharactersForItemsByRegionAndGender(RegionType regionType, bool onlyFemales);

  List<CharacterBirthdayModel> getCharacterBirthdays({int? month, int? day});

  List<ItemCommonWithName> getItemsAscensionStats(StatType statType, ItemType itemType);
}
