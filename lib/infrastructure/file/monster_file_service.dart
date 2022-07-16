import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/monster_file_service.dart';
import 'package:shiori/domain/services/file/translation_file_service.dart';

class MonsterFileServiceImpl implements MonsterFileService {
  final TranslationFileService _translations;

  late MonstersFile _monstersFile;

  MonsterFileServiceImpl(this._translations);

  @override
  Future<void> init() async {
    final json = await Assets.getJsonFromPath(Assets.monstersDbPath);
    _monstersFile = MonstersFile.fromJson(json);
  }

  @override
  MonsterFileModel getMonster(String key) {
    return _monstersFile.monsters.firstWhere((el) => el.key == key);
  }

  @override
  List<MonsterCardModel> getAllMonstersForCard() {
    return _monstersFile.monsters.map((e) => _toMonsterForCard(e)).toList();
  }

  @override
  MonsterCardModel getMonsterForCard(String key) {
    final monster = _monstersFile.monsters.firstWhere((el) => el.key == key);
    return _toMonsterForCard(monster);
  }

  @override
  List<MonsterFileModel> getMonsters(MonsterType type) {
    return _monstersFile.monsters.where((el) => el.type == type).toList();
  }

  @override
  List<ItemCommon> getRelatedMonsterToMaterialForItems(String key) {
    final items = <ItemCommon>[];
    for (final monster in _monstersFile.monsters) {
      if (!monster.drops.any((el) => el.type == MonsterDropType.material && el.key == key)) {
        continue;
      }
      items.add(ItemCommon(monster.key, monster.fullImagePath));
    }
    return items;
  }

  @override
  List<ItemCommon> getRelatedMonsterToArtifactForItems(String key) {
    final items = <ItemCommon>[];
    for (final monster in _monstersFile.monsters) {
      if (!monster.drops.any((el) => el.type == MonsterDropType.artifact && key == el.key)) {
        continue;
      }
      items.add(ItemCommon(monster.key, monster.fullImagePath));
    }
    return items;
  }

  MonsterCardModel _toMonsterForCard(MonsterFileModel monster) {
    final translation = _translations.getMonsterTranslation(monster.key);
    return MonsterCardModel(
      key: monster.key,
      image: monster.fullImagePath,
      name: translation.name,
      type: monster.type,
      isComingSoon: monster.isComingSoon,
    );
  }
}
