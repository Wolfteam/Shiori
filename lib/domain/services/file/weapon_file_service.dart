import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/base_file_service.dart';

abstract class WeaponFileService extends BaseFileService {
  List<WeaponCardModel> getWeaponsForCard();

  WeaponCardModel getWeaponForCard(String key);

  WeaponFileModel getWeapon(String key);

  List<String> getUpcomingWeaponsKeys();

  List<ItemCommon> getWeaponForItemsUsingMaterial(String key);

  List<TodayWeaponAscensionMaterialModel> getWeaponAscensionMaterials(int day);

  int countByStatType(StatType statType);

  List<ItemCommonWithName> getItemCommonWithNameByRarity(int rarity);

  List<ItemCommonWithName> getItemCommonWithNameByStatType(StatType statType);
}
