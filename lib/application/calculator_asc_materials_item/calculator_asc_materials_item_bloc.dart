import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/app_constants.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:tuple/tuple.dart';

part 'calculator_asc_materials_item_bloc.freezed.dart';
part 'calculator_asc_materials_item_event.dart';
part 'calculator_asc_materials_item_state.dart';

class CalculatorAscMaterialsItemBloc extends Bloc<CalculatorAscMaterialsItemEvent, CalculatorAscMaterialsItemState> {
  final GenshinService _genshinService;

  static int minSkillLevel = 1;
  static int maxSkillLevel = 10;
  static int minAscensionLevel = 1;
  static int maxAscensionLevel = 6;
  static int minItemLevel = 1;
  static int maxItemLevel = 90;

  _LoadedState get currentState => state as _LoadedState;

  CalculatorAscMaterialsItemBloc(this._genshinService) : super(const CalculatorAscMaterialsItemState.loading());

  @override
  Stream<CalculatorAscMaterialsItemState> mapEventToState(
    CalculatorAscMaterialsItemEvent event,
  ) async* {
    if (event is _Init) {
      yield const CalculatorAscMaterialsItemState.loading();
    }

    final s = event.map(
      load: (e) {
        if (e.isCharacter) {
          final char = _genshinService.getCharacter(e.key);
          final translation = _genshinService.getCharacterTranslation(e.key);
          return CalculatorAscMaterialsItemState.loaded(
            name: translation.name,
            imageFullPath: Assets.getCharacterPath(char.image),
            currentLevel: itemAscensionLevelMap.entries.first.value,
            desiredLevel: maxItemLevel,
            currentAscensionLevel: minAscensionLevel,
            desiredAscensionLevel: maxAscensionLevel,
            skills: translation.skills.map(
              (e) {
                final enableTuple = _isSkillEnabled(minSkillLevel, maxSkillLevel, minAscensionLevel, maxAscensionLevel);
                return CharacterSkill.skill(
                  name: e.title,
                  currentLevel: minSkillLevel,
                  desiredLevel: maxSkillLevel,
                  isCurrentDecEnabled: enableTuple.item1,
                  isCurrentIncEnabled: enableTuple.item2,
                  isDesiredDecEnabled: enableTuple.item3,
                  isDesiredIncEnabled: enableTuple.item4,
                );
              },
            ).toList(),
          );
        }
        final weapon = _genshinService.getWeapon(e.key);
        final translation = _genshinService.getWeaponTranslation(e.key);
        return CalculatorAscMaterialsItemState.loaded(
          name: translation.name,
          imageFullPath: weapon.fullImagePath,
          currentLevel: itemAscensionLevelMap.entries.first.value,
          desiredLevel: maxItemLevel,
          currentAscensionLevel: minAscensionLevel,
          desiredAscensionLevel: maxAscensionLevel,
        );
      },
      loadWith: (e) {
        if (e.isCharacter) {
          final char = _genshinService.getCharacter(e.key);
          final translation = _genshinService.getCharacterTranslation(e.key);
          return CalculatorAscMaterialsItemState.loaded(
            name: translation.name,
            imageFullPath: Assets.getCharacterPath(char.image),
            currentLevel: e.currentLevel,
            desiredLevel: e.desiredLevel,
            skills: e.skills,
            currentAscensionLevel: e.currentAscensionLevel,
            desiredAscensionLevel: e.desiredAscensionLevel,
          );
        }

        final weapon = _genshinService.getWeapon(e.key);
        final translation = _genshinService.getWeaponTranslation(e.key);
        return CalculatorAscMaterialsItemState.loaded(
          name: translation.name,
          imageFullPath: weapon.fullImagePath,
          currentLevel: e.currentLevel,
          desiredLevel: e.desiredLevel,
          currentAscensionLevel: e.currentAscensionLevel,
          desiredAscensionLevel: e.desiredAscensionLevel,
        );
      },
      currentLevelChanged: (e) => _levelChanged(e.newValue, currentState.desiredLevel, true),
      desiredLevelChanged: (e) => _levelChanged(currentState.currentLevel, e.newValue, false),
      currentAscensionLevelChanged: (e) => _ascensionChanged(e.newValue, currentState.desiredAscensionLevel, true),
      desiredAscensionLevelChanged: (e) => _ascensionChanged(currentState.currentAscensionLevel, e.newValue, false),
      skillCurrentLevelChanged: (e) => _skillChanged(e.index, e.newValue, true),
      skillDesiredLevelChanged: (e) => _skillChanged(e.index, e.newValue, false),
    );

    yield s;
  }

  CalculatorAscMaterialsItemState _levelChanged(int currentLevel, int desiredLevel, bool currentChanged) {
    final tuple = _checkProvidedLevels(currentLevel, desiredLevel, currentChanged);
    final cl = tuple.item1;
    final dl = tuple.item2;

    final cAsc = _getClosestAscensionLevel(cl, _isLevelValidForAscensionLevel(cl, currentState.currentAscensionLevel));
    final dAsc = _getClosestAscensionLevel(dl, _isLevelValidForAscensionLevel(dl, currentState.desiredAscensionLevel));
    final skills = _updateSkills(cAsc, dAsc);

    return currentState.copyWith.call(
      currentLevel: cl,
      desiredLevel: dl,
      currentAscensionLevel: cAsc,
      desiredAscensionLevel: dAsc,
      skills: skills,
    );
  }

  CalculatorAscMaterialsItemState _ascensionChanged(int currentLevel, int desiredLevel, bool currentChanged) {
    final tuple = _checkProvidedLevels(currentLevel, desiredLevel, currentChanged);
    final bothAreZero = tuple.item1 == tuple.item2 && tuple.item1 == 0;
    final cAsc = tuple.item1;
    final dAsc = bothAreZero ? 1 : tuple.item2;

    //Here we consider the 0, because otherwise we will always start from a current level of 1, and sometimes, we want to know the whole thing
    //(from 1 to 10 with 1 inclusive)
    if (cAsc > maxAscensionLevel || (cAsc < minAscensionLevel && cAsc != 0)) {
      return currentState;
    }

    if (dAsc > maxAscensionLevel || dAsc < minAscensionLevel) {
      return currentState;
    }

    final levelTuple = _checkProvidedLevels(
      _getItemLevelToUse(cAsc, currentState.currentLevel),
      _getItemLevelToUse(dAsc, currentState.desiredLevel),
      currentChanged,
    );
    final cl = levelTuple.item1;
    final dl = levelTuple.item2;

    final skills = _updateSkills(cAsc, dAsc);
    return currentState.copyWith.call(
      currentLevel: cl,
      desiredLevel: dl,
      currentAscensionLevel: cAsc,
      desiredAscensionLevel: dAsc,
      skills: skills,
    );
  }

  CalculatorAscMaterialsItemState _skillChanged(int skillIndex, int newValue, bool currentChanged) {
    final skills = <CharacterSkill>[];

    for (var i = 0; i < currentState.skills.length; i++) {
      final item = currentState.skills[i];
      if (i != skillIndex) {
        skills.add(item);
        continue;
      }

      final tuple = _checkProvidedLevels(
        currentChanged ? newValue : item.currentLevel,
        currentChanged ? item.desiredLevel : newValue,
        currentChanged,
      );
      final cl = tuple.item1;
      final dl = tuple.item2;

      if (cl > maxSkillLevel || cl < minSkillLevel) {
        return currentState;
      }

      if (dl > maxSkillLevel || dl < minSkillLevel) {
        return currentState;
      }
      final enableTuple = _isSkillEnabled(cl, dl, currentState.currentAscensionLevel, currentState.desiredAscensionLevel);
      skills.add(item.copyWith.call(
        currentLevel: cl,
        desiredLevel: dl,
        isCurrentDecEnabled: enableTuple.item1,
        isCurrentIncEnabled: enableTuple.item2,
        isDesiredDecEnabled: enableTuple.item3,
        isDesiredIncEnabled: enableTuple.item4,
      ));
    }

    return currentState.copyWith.call(skills: skills);
  }

  Tuple2<int, int> _checkProvidedLevels(int currentLevel, int desiredLevel, bool currentChanged) {
    var cl = currentLevel;
    var dl = desiredLevel;

    if (currentChanged) {
      if (cl > dl) {
        dl = cl;
      }
    } else {
      if (cl > dl) {
        cl = dl;
      }
    }

    return Tuple2<int, int>(cl, dl);
  }

  /// Gets the closest ascension level [toItemLevel]
  ///
  /// Keep in mind that you can be of level 80 but that doesn't mean you have ascended to level 6,
  /// that's why you must provide [isAscended]
  int _getClosestAscensionLevel(int toItemLevel, bool isAscended) {
    if (toItemLevel <= 0) {
      throw Exception('The provided itemLevel = $toItemLevel is not valid');
    }

    int ascensionLevel = -1;
    for (final kvp in itemAscensionLevelMap.entries) {
      final temp = kvp.value;
      if (temp >= toItemLevel && ascensionLevel == -1) {
        ascensionLevel = kvp.key;
        break;
      }
      continue;
    }

    //if we end up here, that means the provided level is higher than the one in the
    //map, so we simple return the highest one available
    if (ascensionLevel == -1) {
      return itemAscensionLevelMap.entries.last.key;
    }

    if (toItemLevel == itemAscensionLevelMap.entries.firstWhere((kvp) => kvp.key == ascensionLevel).value) {
      return isAscended ? ascensionLevel : ascensionLevel - 1;
    }

    return ascensionLevel - 1;
  }

  int _getItemLevelToUse(int currentAscensionLevel, int currentItemLevel) {
    if (currentItemLevel <= 0) {
      throw Exception('The provided itemLevel = $currentItemLevel is not valid');
    }
    if (currentAscensionLevel < 0) {
      throw Exception('The provided ascension level = $currentAscensionLevel is not valid');
    }

    if (currentAscensionLevel == 0) {
      return itemAscensionLevelMap.entries.first.value;
    }

    final currentKvp = itemAscensionLevelMap.entries.firstWhere((kvp) => kvp.key == currentAscensionLevel);
    final suggestedAscLevel = _getClosestAscensionLevel(currentItemLevel, false);

    if (currentKvp.key != suggestedAscLevel) {
      return currentKvp.value;
    }

    return currentItemLevel;
  }

  int _getSkillLevelToUse(int forAscensionLevel, int currentSkillLevel) {
    if (forAscensionLevel < 0) {
      throw Exception('The provided ascension level = $forAscensionLevel is not valid');
    }

    if (forAscensionLevel == 0) {
      return skillAscensionMap.entries.first.value.first;
    }

    if (!skillAscensionMap.entries.any((kvp) => kvp.value.contains(currentSkillLevel))) {
      throw Exception('The provided skill level = $currentSkillLevel is not valid');
    }

    final currentKvp = skillAscensionMap.entries.firstWhere((kvp) => kvp.value.contains(currentSkillLevel));
    final newKvp = skillAscensionMap.entries.firstWhere((kvp) => kvp.key == forAscensionLevel);

    if (newKvp.key >= currentKvp.key) {
      return currentSkillLevel;
    }

    return newKvp.value.first;
  }

  List<CharacterSkill> _updateSkills(int currentAscensionLevel, int desiredAscensionLevel) {
    final skills = <CharacterSkill>[];

    for (final skill in currentState.skills) {
      final cSkill = _getSkillLevelToUse(currentAscensionLevel, skill.currentLevel);
      final dSkill = _getSkillLevelToUse(desiredAscensionLevel, skill.desiredLevel);
      final enableTuple = _isSkillEnabled(cSkill, dSkill, currentAscensionLevel, desiredAscensionLevel);
      skills.add(skill.copyWith.call(
        currentLevel: cSkill,
        desiredLevel: dSkill,
        isCurrentDecEnabled: enableTuple.item1,
        isCurrentIncEnabled: enableTuple.item2,
        isDesiredDecEnabled: enableTuple.item3,
        isDesiredIncEnabled: enableTuple.item4,
      ));
    }

    return skills;
  }

  /// Checks if a skill can be increased.
  ///
  /// Keep in mind that the values provided  must be already validated
  bool _canSkillBeIncreased(int skillLevel, int maxAscensionLevel) {
    if (maxAscensionLevel < 0) {
      throw Exception('The provided ascension level = $maxAscensionLevel is not valid');
    }

    if (maxAscensionLevel == 0 && skillLevel > minSkillLevel) {
      return true;
    } else if (maxAscensionLevel == 0 && skillLevel == minSkillLevel) {
      return false;
    }

    final currentSkillEntry = skillAscensionMap.entries.firstWhere((kvp) => kvp.value.contains(skillLevel));
    final ascensionEntry = skillAscensionMap.entries.firstWhere((kvp) => kvp.key == maxAscensionLevel);

    //If the ascension level are different, just return true, since we don't need to make any validation in this method
    if (ascensionEntry.key != currentSkillEntry.key) {
      return true;
    }

    //otherwise, return true only if this skill is not the last in the map
    final isNotTheLast = currentSkillEntry.value.last != skillLevel;
    return isNotTheLast;
  }

  /// This method checks if the provided skills are enabled or not.
  ///
  /// Keep in mind that the values provided  must be already validated
  Tuple4<bool, bool, bool, bool> _isSkillEnabled(
    int currentLevel,
    int desiredLevel,
    int currentAscensionLevel,
    int desiredAscensionLevel,
  ) {
    final currentDecEnabled = currentLevel != minSkillLevel;
    final currentIncEnabled = currentLevel != maxSkillLevel && _canSkillBeIncreased(currentLevel, currentAscensionLevel);

    final desiredDecEnabled = desiredLevel != minSkillLevel;
    final desiredIncEnabled = desiredLevel != maxSkillLevel && _canSkillBeIncreased(desiredLevel, desiredAscensionLevel);

    return Tuple4<bool, bool, bool, bool>(currentDecEnabled, currentIncEnabled, desiredDecEnabled, desiredIncEnabled);
  }

  bool _isLevelValidForAscensionLevel(int currentLevel, int ascensionLevel) {
    if (ascensionLevel == 0) {
      return itemAscensionLevelMap.entries.first.value >= currentLevel;
    }

    if (ascensionLevel == itemAscensionLevelMap.entries.last.key) {
      return currentLevel >= itemAscensionLevelMap.entries.last.value;
    }

    final entry = itemAscensionLevelMap.entries.firstWhere((kvp) => kvp.key == ascensionLevel);
    final nextEntry = itemAscensionLevelMap.entries.firstWhere((kvp) => kvp.key == ascensionLevel + 1);
    return entry.value >= currentLevel && currentLevel <= nextEntry.value;
  }
}
