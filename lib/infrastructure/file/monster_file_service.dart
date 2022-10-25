import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/monster_file_service.dart';
import 'package:shiori/domain/services/file/translation_file_service.dart';
import 'package:shiori/domain/services/resources_service.dart';

class MonsterFileServiceImpl extends MonsterFileService {
  final ResourceService _resourceService;
  final TranslationFileService _translations;

  late MonstersFile _monstersFile;

  @override
  ResourceService get resources => _resourceService;

  @override
  TranslationFileService get translations => _translations;

  MonsterFileServiceImpl(this._resourceService, this._translations);

  @override
  Future<void> init(String assetPath) async {
    final json = await readJson(assetPath);
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
    return _monstersFile.monsters
        .where((monster) => monster.drops.any((el) => el.type == MonsterDropType.material && el.key == key))
        .map((monster) => ItemCommon(monster.key, _resourceService.getMonsterImagePath(monster.image)))
        .toList();
  }

  @override
  List<ItemCommon> getRelatedMonsterToArtifactForItems(String key) {
    return _monstersFile.monsters
        .where((monster) => monster.drops.any((el) => el.type == MonsterDropType.artifact && el.key == key))
        .map((monster) => ItemCommon(monster.key, _resourceService.getMonsterImagePath(monster.image)))
        .toList();
  }

  MonsterCardModel _toMonsterForCard(MonsterFileModel monster) {
    final translation = _translations.getMonsterTranslation(monster.key);
    return MonsterCardModel(
      key: monster.key,
      image: _resourceService.getMonsterImagePath(monster.image),
      name: translation.name,
      type: monster.type,
      isComingSoon: monster.isComingSoon,
    );
  }
}
