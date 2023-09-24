import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/base_file_service.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';

abstract class CharacterFileService extends BaseFileService {
  ArtifactFileService get artifacts;

  MaterialFileService get materials;

  WeaponFileService get weapons;

  List<CharacterCardModel> getCharactersForCard();

  CharacterCardModel getCharacterForCard(String key);

  CharacterFileModel getCharacter(String key);

  List<TierListRowModel> getDefaultCharacterTierList(List<int> colors);

  List<ItemCommon> getCharacterForItemsUsingWeapon(String key);

  List<ItemCommon> getCharacterForItemsUsingArtifact(String key);

  List<ItemCommon> getCharacterForItemsUsingMaterial(String key);

  List<String> getUpcomingCharactersKeys();

  List<CharacterSkillStatModel> getCharacterSkillStats(List<CharacterFileSkillStatModel> skillStats, List<String> statsTranslations);

  List<ChartBirthdayMonthModel> getCharacterBirthdaysForCharts();

  List<ChartCharacterRegionModel> getCharacterRegionsForCharts();

  List<ChartGenderModel> getCharacterGendersForCharts();

  ChartGenderModel getCharacterGendersByRegionForCharts(RegionType regionType);

  List<ItemCommonWithName> getCharactersForItemsByRegion(RegionType regionType);

  List<ItemCommonWithName> getCharactersForItemsByRegionAndGender(RegionType regionType, bool onlyFemales);

  List<CharacterBirthdayModel> getCharacterBirthdays({int? month, int? day});

  List<TodayCharAscensionMaterialsModel> getCharacterAscensionMaterials(int day);

  int countByStatType(StatType statType);

  List<ItemCommonWithName> getItemCommonWithNameByRarity(int rarity);

  List<ItemCommonWithName> getItemCommonWithNameByStatType(StatType statType);

  List<ItemCommonWithName> getItemCommonWithName();
}
