import 'package:genshindb/domain/app_constants.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/domain/models/entities.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/calculator_service.dart';
import 'package:genshindb/domain/services/data_service.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DataServiceImpl implements DataService {
  final GenshinService _genshinService;
  final CalculatorService _calculatorService;
  Box<CalculatorSession> _sessionBox;
  Box<CalculatorItem> _calcItemBox;
  Box<CalculatorCharacterSkill> _calcItemSkillBox;

  DataServiceImpl(this._genshinService, this._calculatorService);

  Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();
    _sessionBox = await Hive.openBox<CalculatorSession>('calculatorSessions');
    _calcItemBox = await Hive.openBox<CalculatorItem>('calculatorSessionsItems');
    _calcItemSkillBox = await Hive.openBox<CalculatorCharacterSkill>('calculatorSessionsItemsSkills');
  }

  @override
  List<CalculatorSessionModel> getAllCalAscMatSessions() {
    return _sessionBox.values.map((s) {
      if (_calcItemBox.values == null) {
        return CalculatorSessionModel(key: s.key as int, name: s.name, items: []);
      }

      final items = _calcItemBox.values.where((el) => el.sessionKey == s.key).map((item) {
        if (item.isCharacter) {
          return _buildForCharacter(item);
        }

        if (item.isWeapon) {
          return _buildForWeapon(item);
        }

        throw Exception('The provided item with key = ${item.key} is not neither a character nor weapon');
      }).toList()
        ..sort((x, y) => x.position.compareTo(y.position));

      return CalculatorSessionModel(key: s.key as int, name: s.name, items: items);
    }).toList()
      ..sort((x, y) => x.name.compareTo(y.name));
  }

  @override
  Future<int> createCalAscMatSession(String name) {
    final session = CalculatorSession(name);
    return _sessionBox.add(session);
  }

  @override
  Future<void> updateCalAscMatSession(int sessionKey, String name) {
    final session = _sessionBox.get(sessionKey);
    session.name = name;
    return session.save();
  }

  @override
  Future<void> deleteCalAscMatSession(int sessionKey) {
    return _sessionBox.delete(sessionKey);
  }

  @override
  Future<void> addCalAscMatSessionItems(int sessionKey, List<ItemAscensionMaterials> items) async {
    for (final item in items) {
      await addCalAscMatSessionItem(sessionKey, item);
    }
  }

  @override
  Future<void> addCalAscMatSessionItem(int sessionKey, ItemAscensionMaterials item) async {
    final mappedItem = CalculatorItem(
      sessionKey,
      item.key,
      item.position,
      item.currentLevel,
      item.desiredLevel,
      item.currentAscensionLevel,
      item.desiredAscensionLevel,
      item.isCharacter,
      item.isWeapon,
      item.isActive,
    );

    final itemKey = await _calcItemBox.add(mappedItem);
    final skills = item.skills.map((e) => CalculatorCharacterSkill(itemKey, e.key, e.currentLevel, e.desiredLevel, e.position)).toList();
    await _calcItemSkillBox.addAll(skills);
  }

  @override
  Future<void> updateCalAscMatSessionItem(int sessionKey, int position, ItemAscensionMaterials item) async {
    await deleteCalAscMatSessionItem(sessionKey, position);
    await addCalAscMatSessionItem(sessionKey, item);
  }

  @override
  Future<void> deleteCalAscMatSessionItem(int sessionKey, int position) async {
    final toDelete = _calcItemBox.values.firstWhere((el) => el.sessionKey == sessionKey && el.position == position, orElse: () => null);
    if (toDelete != null) {
      final skills = _calcItemSkillBox.values.where((el) => el.calculatorItemKey == toDelete.key).toList();
      for (final skill in skills) {
        await _calcItemSkillBox.delete(skill.key);
      }

      await _calcItemBox.delete(toDelete.key);
    }
  }

  void _registerAdapters() {
    Hive.registerAdapter(CalculatorCharacterSkillAdapter());
    Hive.registerAdapter(CalculatorItemAdapter());
    Hive.registerAdapter(CalculatorSessionAdapter());
  }

  ItemAscensionMaterials _buildForCharacter(CalculatorItem item) {
    final character = _genshinService.getCharacter(item.itemKey);
    final translation = _genshinService.getCharacterTranslation(item.itemKey);
    final skills = _calcItemSkillBox.values
        .where((s) => s.calculatorItemKey == item.key)
        .map((skill) => _buildCharacterSkill(item, skill, translation.skills.firstWhere((t) => t.key == skill.skillKey)))
        .toList();
    final materials = _calculatorService.getCharacterMaterialsToUse(
      character,
      item.currentLevel,
      item.desiredLevel,
      item.currentAscensionLevel,
      item.desiredAscensionLevel,
      skills,
    );
    return ItemAscensionMaterials.forCharacters(
      key: item.itemKey,
      name: translation.name,
      image: Assets.getCharacterPath(character.image),
      rarity: character.rarity,
      materials: materials,
      currentLevel: item.currentLevel,
      desiredLevel: item.desiredLevel,
      currentAscensionLevel: item.currentAscensionLevel,
      desiredAscensionLevel: item.desiredAscensionLevel,
      skills: skills,
      isActive: item.isActive,
      position: item.position,
      isCharacter: item.isCharacter,
      isWeapon: item.isWeapon,
    );
  }

  CharacterSkill _buildCharacterSkill(CalculatorItem item, CalculatorCharacterSkill skillInDb, TranslationCharacterSkillFile skill) {
    final enableTuple = _calculatorService.isSkillEnabled(
      skillInDb.currentLevel,
      skillInDb.desiredLevel,
      item.currentAscensionLevel,
      item.desiredAscensionLevel,
      minSkillLevel,
      maxSkillLevel,
    );
    return CharacterSkill.skill(
      name: skill.title,
      currentLevel: skillInDb.currentLevel,
      desiredLevel: skillInDb.desiredLevel,
      isCurrentDecEnabled: enableTuple.item1,
      isCurrentIncEnabled: enableTuple.item2,
      isDesiredDecEnabled: enableTuple.item3,
      isDesiredIncEnabled: enableTuple.item4,
      position: skillInDb.position,
      key: skillInDb.skillKey,
    );
  }

  ItemAscensionMaterials _buildForWeapon(CalculatorItem item) {
    final weapon = _genshinService.getWeapon(item.itemKey);
    final translation = _genshinService.getWeaponTranslation(item.itemKey);
    final materials = _calculatorService.getWeaponMaterialsToUse(
      weapon,
      item.currentLevel,
      item.desiredLevel,
      item.currentAscensionLevel,
      item.desiredAscensionLevel,
    );
    return ItemAscensionMaterials.forWeapons(
      key: item.itemKey,
      name: translation.name,
      image: weapon.fullImagePath,
      rarity: weapon.rarity,
      materials: materials,
      currentLevel: item.currentLevel,
      desiredLevel: item.desiredLevel,
      currentAscensionLevel: item.currentAscensionLevel,
      desiredAscensionLevel: item.desiredAscensionLevel,
      skills: [],
      isActive: item.isActive,
      position: item.position,
      isWeapon: item.isWeapon,
      isCharacter: item.isCharacter,
    );
  }
}
