import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_asc_materials_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';

part 'calculator_asc_materials_item_bloc.freezed.dart';
part 'calculator_asc_materials_item_event.dart';
part 'calculator_asc_materials_item_state.dart';

class CalculatorAscMaterialsItemBloc extends Bloc<CalculatorAscMaterialsItemEvent, CalculatorAscMaterialsItemState> {
  final GenshinService _genshinService;
  final CalculatorAscMaterialsService _calculatorService;
  final ResourceService _resourceService;

  CalculatorAscMaterialsItemStateLoaded get currentState => state as CalculatorAscMaterialsItemStateLoaded;

  CalculatorAscMaterialsItemBloc(this._genshinService, this._calculatorService, this._resourceService)
    : super(const CalculatorAscMaterialsItemState.loading());

  @override
  Stream<CalculatorAscMaterialsItemState> mapEventToState(CalculatorAscMaterialsItemEvent event) async* {
    if (event is CalculatorAscMaterialsItemEventLoad) {
      yield const CalculatorAscMaterialsItemState.loading();
    }

    if (event is! CalculatorAscMaterialsItemEventLoad &&
        event is! CalculatorAscMaterialsItemEventLoadWith &&
        state is! CalculatorAscMaterialsItemStateLoaded) {
      throw Exception('Invalid state');
    }

    switch (event) {
      case CalculatorAscMaterialsItemEventLoad():
        yield _defaultLoad(event);
      case CalculatorAscMaterialsItemEventLoadWith():
        yield _load(event);
      case CalculatorAscMaterialsItemEventCurrentLevelChanged():
        yield _levelChanged(event.newValue, currentState.desiredLevel, true);
      case CalculatorAscMaterialsItemEventDesiredLevelChanged():
        yield _levelChanged(currentState.currentLevel, event.newValue, false);
      case CalculatorAscMaterialsItemEventCurrentAscensionLevelChanged():
        yield _ascensionChanged(event.newValue, currentState.desiredAscensionLevel, true);
      case CalculatorAscMaterialsItemEventDesiredAscensionLevelChanged():
        yield _ascensionChanged(currentState.currentAscensionLevel, event.newValue, false);
      case CalculatorAscMaterialsItemEventSkillCurrentLevelChanged():
        yield _skillChanged(event.index, event.newValue, true);
      case CalculatorAscMaterialsItemEventSkillDesiredLevelChanged():
        yield _skillChanged(event.index, event.newValue, false);
      case CalculatorAscMaterialsItemEventUseMaterialsFromInventoryChanged():
        yield currentState.copyWith.call(useMaterialsFromInventory: event.useThem);
    }
  }

  CalculatorAscMaterialsItemState _defaultLoad(CalculatorAscMaterialsItemEventLoad e) {
    if (e.isCharacter) {
      final char = _genshinService.characters.getCharacter(e.key);
      final translation = _genshinService.translations.getCharacterTranslation(e.key);
      return CalculatorAscMaterialsItemState.loaded(
        name: translation.name,
        imageFullPath: _resourceService.getCharacterImagePath(char.image),
        currentLevel: itemAscensionLevelMap.entries.first.value,
        desiredLevel: maxItemLevel,
        currentAscensionLevel: minAscensionLevel,
        desiredAscensionLevel: maxAscensionLevel,
        useMaterialsFromInventory: false,
        skills: _getCharacterSkillsToUse(char, translation),
      );
    }
    final weapon = _genshinService.weapons.getWeapon(e.key);
    final translation = _genshinService.translations.getWeaponTranslation(e.key);
    return CalculatorAscMaterialsItemState.loaded(
      name: translation.name,
      imageFullPath: _resourceService.getWeaponImagePath(weapon.image, weapon.type),
      currentLevel: itemAscensionLevelMap.entries.first.value,
      desiredLevel: maxItemLevel,
      currentAscensionLevel: minAscensionLevel,
      desiredAscensionLevel: maxAscensionLevel,
      useMaterialsFromInventory: false,
    );
  }

  CalculatorAscMaterialsItemState _load(CalculatorAscMaterialsItemEventLoadWith e) {
    if (e.isCharacter) {
      final char = _genshinService.characters.getCharacter(e.key);
      final translation = _genshinService.translations.getCharacterTranslation(e.key);
      return CalculatorAscMaterialsItemState.loaded(
        name: translation.name,
        imageFullPath: _resourceService.getCharacterImagePath(char.image),
        currentLevel: e.currentLevel,
        desiredLevel: e.desiredLevel,
        skills: e.skills,
        currentAscensionLevel: e.currentAscensionLevel,
        desiredAscensionLevel: e.desiredAscensionLevel,
        useMaterialsFromInventory: e.useMaterialsFromInventory,
      );
    }

    final weapon = _genshinService.weapons.getWeapon(e.key);
    final translation = _genshinService.translations.getWeaponTranslation(e.key);
    return CalculatorAscMaterialsItemState.loaded(
      name: translation.name,
      imageFullPath: _resourceService.getWeaponImagePath(weapon.image, weapon.type),
      currentLevel: e.currentLevel,
      desiredLevel: e.desiredLevel,
      currentAscensionLevel: e.currentAscensionLevel,
      desiredAscensionLevel: e.desiredAscensionLevel,
      useMaterialsFromInventory: e.useMaterialsFromInventory,
    );
  }

  CalculatorAscMaterialsItemState _levelChanged(int currentLevel, int desiredLevel, bool currentChanged) {
    if (currentLevel < minItemLevel || currentLevel > maxItemLevel) {
      throw Exception('Current level = $currentLevel is not valid');
    }

    if (desiredLevel < minItemLevel || desiredLevel > maxItemLevel) {
      throw Exception('Desired level = $desiredLevel is not valid');
    }

    final tuple = _checkProvidedLevels(currentLevel, desiredLevel, currentChanged);
    final cl = tuple.$1;
    final dl = tuple.$2;

    final cAsc = _calculatorService.getClosestAscensionLevelFor(cl, currentState.currentAscensionLevel);
    int dAsc = _calculatorService.getClosestAscensionLevelFor(dl, currentState.desiredAscensionLevel);
    if (cAsc > dAsc) {
      dAsc = cAsc;
    }
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
    if (currentLevel < 0 || currentLevel > itemAscensionLevelMap.entries.last.key) {
      throw Exception('Current asc level = $currentLevel is not valid');
    }

    if (desiredLevel < 0 || desiredLevel > itemAscensionLevelMap.entries.last.key) {
      throw Exception('Desired asc level = $desiredLevel is not valid');
    }
    final tuple = _checkProvidedLevels(currentLevel, desiredLevel, currentChanged);
    final bothAreZero = tuple.$1 == tuple.$2 && tuple.$1 == 0;
    final cAsc = tuple.$1;
    final dAsc = bothAreZero ? 1 : tuple.$2;

    //Here we consider the 0, because otherwise we will always start from a current level of 1, and sometimes, we want to know the whole thing
    //(from 1 to 10 with 1 inclusive)
    if (cAsc > maxAscensionLevel || (cAsc < minAscensionLevel && cAsc != 0)) {
      return currentState;
    }

    if (dAsc > maxAscensionLevel || dAsc < minAscensionLevel) {
      return currentState;
    }

    final levelTuple = _checkProvidedLevels(
      _calculatorService.getItemLevelToUse(cAsc, currentState.currentLevel),
      _calculatorService.getItemLevelToUse(dAsc, currentState.desiredLevel),
      currentChanged,
    );
    final cl = levelTuple.$1;
    final dl = levelTuple.$2;

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
    if (skillIndex < 0 || skillIndex > currentState.skills.length) {
      throw Exception('Skill index = $skillIndex is not valid');
    }

    if (newValue < minSkillLevel || newValue > maxSkillLevel) {
      throw Exception('Skill value = $newValue is not valid');
    }

    final skills = <CharacterSkill>[];

    for (int i = 0; i < currentState.skills.length; i++) {
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
      final cl = tuple.$1;
      final dl = tuple.$2;

      if (cl > maxSkillLevel || cl < minSkillLevel) {
        return currentState;
      }

      if (dl > maxSkillLevel || dl < minSkillLevel) {
        return currentState;
      }
      final enableTuple = _calculatorService.isSkillEnabled(
        cl,
        dl,
        currentState.currentAscensionLevel,
        currentState.desiredAscensionLevel,
        minSkillLevel,
        maxSkillLevel,
      );
      skills.add(
        item.copyWith.call(
          currentLevel: cl,
          desiredLevel: dl,
          isCurrentDecEnabled: enableTuple.$1,
          isCurrentIncEnabled: enableTuple.$2,
          isDesiredDecEnabled: enableTuple.$3,
          isDesiredIncEnabled: enableTuple.$4,
        ),
      );
    }

    return currentState.copyWith.call(skills: skills);
  }

  (int, int) _checkProvidedLevels(int currentLevel, int desiredLevel, bool currentChanged) {
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

    return (cl, dl);
  }

  List<CharacterSkill> _updateSkills(int currentAscensionLevel, int desiredAscensionLevel) {
    final skills = <CharacterSkill>[];

    for (final skill in currentState.skills) {
      final cSkill = _calculatorService.getSkillLevelToUse(currentAscensionLevel, skill.currentLevel);
      final dSkill = _calculatorService.getSkillLevelToUse(desiredAscensionLevel, skill.desiredLevel);
      final enableTuple = _calculatorService.isSkillEnabled(
        cSkill,
        dSkill,
        currentAscensionLevel,
        desiredAscensionLevel,
        minSkillLevel,
        maxSkillLevel,
      );
      skills.add(
        skill.copyWith.call(
          currentLevel: cSkill,
          desiredLevel: dSkill,
          isCurrentDecEnabled: enableTuple.$1,
          isCurrentIncEnabled: enableTuple.$2,
          isDesiredDecEnabled: enableTuple.$3,
          isDesiredIncEnabled: enableTuple.$4,
        ),
      );
    }

    return skills;
  }

  List<CharacterSkill> _getCharacterSkillsToUse(CharacterFileModel character, TranslationCharacterFile translation) {
    final skills = <CharacterSkill>[];
    for (var i = 0; i < translation.skills.length; i++) {
      final e = translation.skills[i];
      final related = character.skills.firstWhereOrNull((el) => el.key == e.key);
      if (related == null || related.type == CharacterSkillType.others) {
        continue;
      }

      final enableTuple = _calculatorService.isSkillEnabled(
        minSkillLevel,
        maxSkillLevel,
        minAscensionLevel,
        maxAscensionLevel,
        minSkillLevel,
        maxSkillLevel,
      );
      final skill = CharacterSkill.skill(
        key: e.key,
        name: e.title,
        position: i,
        currentLevel: minSkillLevel,
        desiredLevel: maxSkillLevel,
        isCurrentDecEnabled: enableTuple.$1,
        isCurrentIncEnabled: enableTuple.$2,
        isDesiredDecEnabled: enableTuple.$3,
        isDesiredIncEnabled: enableTuple.$4,
      );
      skills.add(skill);
    }

    return skills;
  }
}
