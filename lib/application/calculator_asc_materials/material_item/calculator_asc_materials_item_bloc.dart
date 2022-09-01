import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:tuple/tuple.dart';

part 'calculator_asc_materials_item_bloc.freezed.dart';
part 'calculator_asc_materials_item_event.dart';
part 'calculator_asc_materials_item_state.dart';

class CalculatorAscMaterialsItemBloc extends Bloc<CalculatorAscMaterialsItemEvent, CalculatorAscMaterialsItemState> {
  final GenshinService _genshinService;
  final CalculatorService _calculatorService;

  _LoadedState get currentState => state as _LoadedState;

  CalculatorAscMaterialsItemBloc(this._genshinService, this._calculatorService) : super(const CalculatorAscMaterialsItemState.loading());

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
          final char = _genshinService.characters.getCharacter(e.key);
          final translation = _genshinService.translations.getCharacterTranslation(e.key);
          return CalculatorAscMaterialsItemState.loaded(
            name: translation.name,
            imageFullPath: Assets.getCharacterPath(char.image),
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
          imageFullPath: weapon.fullImagePath,
          currentLevel: itemAscensionLevelMap.entries.first.value,
          desiredLevel: maxItemLevel,
          currentAscensionLevel: minAscensionLevel,
          desiredAscensionLevel: maxAscensionLevel,
          useMaterialsFromInventory: false,
        );
      },
      loadWith: (e) {
        if (e.isCharacter) {
          final char = _genshinService.characters.getCharacter(e.key);
          final translation = _genshinService.translations.getCharacterTranslation(e.key);
          return CalculatorAscMaterialsItemState.loaded(
            name: translation.name,
            imageFullPath: Assets.getCharacterPath(char.image),
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
          imageFullPath: weapon.fullImagePath,
          currentLevel: e.currentLevel,
          desiredLevel: e.desiredLevel,
          currentAscensionLevel: e.currentAscensionLevel,
          desiredAscensionLevel: e.desiredAscensionLevel,
          useMaterialsFromInventory: e.useMaterialsFromInventory,
        );
      },
      currentLevelChanged: (e) => _levelChanged(e.newValue, currentState.desiredLevel, true),
      desiredLevelChanged: (e) => _levelChanged(currentState.currentLevel, e.newValue, false),
      currentAscensionLevelChanged: (e) => _ascensionChanged(e.newValue, currentState.desiredAscensionLevel, true),
      desiredAscensionLevelChanged: (e) => _ascensionChanged(currentState.currentAscensionLevel, e.newValue, false),
      skillCurrentLevelChanged: (e) => _skillChanged(e.index, e.newValue, true),
      skillDesiredLevelChanged: (e) => _skillChanged(e.index, e.newValue, false),
      useMaterialsFromInventoryChanged: (e) => currentState.copyWith.call(useMaterialsFromInventory: e.useThem),
    );

    yield s;
  }

  CalculatorAscMaterialsItemState _levelChanged(int currentLevel, int desiredLevel, bool currentChanged) {
    final tuple = _checkProvidedLevels(currentLevel, desiredLevel, currentChanged);
    final cl = tuple.item1;
    final dl = tuple.item2;

    final cAsc = _calculatorService.getClosestAscensionLevelFor(cl, currentState.currentAscensionLevel);
    final dAsc = _calculatorService.getClosestAscensionLevelFor(dl, currentState.desiredAscensionLevel);
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
      _calculatorService.getItemLevelToUse(cAsc, currentState.currentLevel),
      _calculatorService.getItemLevelToUse(dAsc, currentState.desiredLevel),
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
          isCurrentDecEnabled: enableTuple.item1,
          isCurrentIncEnabled: enableTuple.item2,
          isDesiredDecEnabled: enableTuple.item3,
          isDesiredIncEnabled: enableTuple.item4,
        ),
      );
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
          isCurrentDecEnabled: enableTuple.item1,
          isCurrentIncEnabled: enableTuple.item2,
          isDesiredDecEnabled: enableTuple.item3,
          isDesiredIncEnabled: enableTuple.item4,
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
        isCurrentDecEnabled: enableTuple.item1,
        isCurrentIncEnabled: enableTuple.item2,
        isDesiredDecEnabled: enableTuple.item3,
        isDesiredIncEnabled: enableTuple.item4,
      );
      skills.add(skill);
    }

    return skills;
  }
}
