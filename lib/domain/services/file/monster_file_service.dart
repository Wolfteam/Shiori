import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/base_file_service.dart';

abstract class MonsterFileService implements BaseFileService {
  MonsterFileModel getMonster(String key);

  List<MonsterCardModel> getAllMonstersForCard();

  MonsterCardModel getMonsterForCard(String key);

  List<MonsterFileModel> getMonsters(MonsterType type);

  List<ItemCommon> getRelatedMonsterToMaterialForItems(String key);

  List<ItemCommon> getRelatedMonsterToArtifactForItems(String key);
}
