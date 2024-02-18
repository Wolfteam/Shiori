import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/base_file_service.dart';

abstract class MonsterFileService extends BaseFileService {
  MonsterFileModel getMonster(String key);

  List<MonsterCardModel> getAllMonstersForCard();

  MonsterCardModel getMonsterForCard(String key);

  List<MonsterFileModel> getMonsters(MonsterType type);

  List<ItemCommonWithName> getRelatedMonsterToMaterialForItems(String key);

  List<ItemCommonWithName> getRelatedMonsterToArtifactForItems(String key);
}
