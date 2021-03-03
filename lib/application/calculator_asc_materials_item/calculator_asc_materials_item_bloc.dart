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

    final cAsc = _getClosestAscensionLevel(cl);
    final dAsc = _getClosestAscensionLevel(dl);
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
    final cAsc = tuple.item1;
    final dAsc = tuple.item2;

    //Here we consider the 0, because otherwise we will always start from a current level of 1, and sometimes, we want to know the whole thing
    //(from 1 to 10 with 1 inclusive)
    if (cAsc > maxAscensionLevel || (cAsc < minAscensionLevel && cAsc != 0)) {
      return currentState;
    }

    if (dAsc > maxAscensionLevel || dAsc < minAscensionLevel) {
      return currentState;
    }

    final cl = _getItemLevelToUse(cAsc, currentState.currentLevel);
    final dl = _getItemLevelToUse(dAsc, currentState.desiredLevel);
    final skills = _updateSkills(cAsc, dAsc);
    return currentState.copyWith.call(
      currentLevel: cl,
      desiredLevel: dl,
      currentAscensionLevel: cAsc,
      desiredAscensionLevel: dAsc,
      skills: skills,
    );
  }

  //TODO: THIS ?
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

  int _getClosestAscensionLevel(int toItemLevel) {
    if (toItemLevel <= 0) {
      throw Exception('The provided itemLevel = $toItemLevel is not valid');
    }

    int ascensionLevel = -1;
    for (final kvp in itemAscensionLevelMap.entries) {
      final temp = kvp.value;
      if (temp >= toItemLevel && ascensionLevel == -1) {
        ascensionLevel = kvp.key;
      }
      continue;
    }

    //if we end up here, that means the provided level is higher than the one in the
    //map, so we simple return the highest one available
    if (ascensionLevel == -1) {
      return itemAscensionLevelMap.entries.last.key;
    }

    if (toItemLevel == itemAscensionLevelMap.entries.firstWhere((kvp) => kvp.key == ascensionLevel).value) {
      return ascensionLevel;
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
    final suggestedAscLevel = _getClosestAscensionLevel(currentItemLevel);

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

  //TODO: FIX THIS METHOD
  bool _canSkillBeIncreased(int skillLevel, int maxAscensionLevel, bool inclusive) {
    final entry = skillAscensionMap.entries.firstWhere((kvp) => kvp.value.contains(skillLevel));
    final isNotTheLast = entry.value.last != skillLevel;
    if (inclusive) {
      return entry.key <= maxAscensionLevel && isNotTheLast;
    }
    return entry.key < maxAscensionLevel && isNotTheLast;
  }

  Tuple4<bool, bool, bool, bool> _isSkillEnabled(
    int currentLevel,
    int desiredLevel,
    int currentAscensionLevel,
    int desiredAscensionLevel,
  ) {
    final currentDecEnabled = currentLevel != minSkillLevel;
    final currentIncEnabled = currentLevel != maxSkillLevel &&
        _canSkillBeIncreased(currentLevel, currentAscensionLevel, skillAscensionMap.entries.first.key != currentAscensionLevel);

    final desiredDecEnabled = desiredLevel != minSkillLevel;
    final desiredIncEnabled = desiredLevel != maxSkillLevel &&
        _canSkillBeIncreased(desiredLevel, desiredAscensionLevel, skillAscensionMap.entries.first.key != desiredAscensionLevel);

    return Tuple4<bool, bool, bool, bool>(currentDecEnabled, currentIncEnabled, desiredDecEnabled, desiredIncEnabled);
    //Current
    // incrementIsDisabled: currentLevel == CalculatorAscMaterialsItemBloc.maxSkillLevel,
    // decrementIsDisabled: currentLevel == CalculatorAscMaterialsItemBloc.minSkillLevel,

    //Desired
    // incrementIsDisabled: desiredLevel == CalculatorAscMaterialsItemBloc.maxSkillLevel,
    // decrementIsDisabled: desiredLevel == CalculatorAscMaterialsItemBloc.minSkillLevel,
  }
}
