import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/assets.dart';
import '../../models/models.dart';
import '../../services/genshing_service.dart';

part 'calculator_asc_materials_item_bloc.freezed.dart';

part 'calculator_asc_materials_item_event.dart';

part 'calculator_asc_materials_item_state.dart';

class CalculatorAscMaterialsItemBloc extends Bloc<CalculatorAscMaterialsItemEvent, CalculatorAscMaterialsItemState> {
  final GenshinService _genshinService;

  static int minSkillLevel = 1;
  static int maxSkillLevel = 10;
  static int minAscensionLevel = 1;
  static int maxAscensionLevel = 6;

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
            currentLevel: minAscensionLevel,
            desiredLevel: maxAscensionLevel,
            skills:
                translation.skills.map((e) => CharacterSkill.skill(name: e.title, currentLevel: minSkillLevel, desiredLevel: maxSkillLevel)).toList(),
          );
        }
        final weapon = _genshinService.getWeapon(e.key);
        final translation = _genshinService.getWeaponTranslation(e.key);
        return CalculatorAscMaterialsItemState.loaded(
          name: translation.name,
          imageFullPath: weapon.fullImagePath,
          currentLevel: minAscensionLevel,
          desiredLevel: maxAscensionLevel,
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
          );
        }

        final weapon = _genshinService.getWeapon(e.key);
        final translation = _genshinService.getWeaponTranslation(e.key);
        return CalculatorAscMaterialsItemState.loaded(
          name: translation.name,
          imageFullPath: weapon.fullImagePath,
          currentLevel: e.currentLevel,
          desiredLevel: e.desiredLevel,
        );
      },
      currentLevelChanged: (e) {
        return _ascensionChanged(e.newValue, currentState.desiredLevel);
      },
      desiredLevelChanged: (e) {
        return _ascensionChanged(currentState.currentLevel, e.newValue);
      },
      skillCurrentLevelChanged: (e) {
        return _skillChanged(e.index, e.newValue, true);
      },
      skillDesiredLevelChanged: (e) {
        return _skillChanged(e.index, e.newValue, false);
      },
    );

    yield s;
  }

  CalculatorAscMaterialsItemState _ascensionChanged(int currentLevel, int desiredLevel) {
    var cl = currentLevel;
    var dl = desiredLevel;

    if (cl > dl) {
      dl = cl;
    } else if (dl < cl) {
      cl = dl;
    }

    //Here we consider the 0, because otherwise we will always start from a current level of 1, and sometimes, we want to know the whole thing
    //(from 1 to 10 with 1 inclusive)
    if (cl > maxAscensionLevel || (cl < minAscensionLevel && cl != 0)) {
      return currentState;
    }

    if (dl > maxAscensionLevel || dl < minAscensionLevel) {
      return currentState;
    }

    return currentState.copyWith.call(currentLevel: cl, desiredLevel: dl);
  }

  CalculatorAscMaterialsItemState _skillChanged(int skillIndex, int newValue, bool currentChanged) {
    final skills = <CharacterSkill>[];

    for (var i = 0; i < currentState.skills.length; i++) {
      final item = currentState.skills[i];
      if (i != skillIndex) {
        skills.add(item);
        continue;
      }

      var cl = currentChanged ? newValue : item.currentLevel;
      var dl = currentChanged ? item.desiredLevel : newValue;

      if (cl > dl) {
        dl = cl;
      } else if (dl < cl) {
        cl = dl;
      }

      if (cl > maxSkillLevel || cl < minSkillLevel) {
        return currentState;
      }

      if (dl > maxSkillLevel || dl < minSkillLevel) {
        return currentState;
      }

      skills.add(item.copyWith.call(currentLevel: cl, desiredLevel: dl));
    }

    return currentState.copyWith.call(skills: skills);
  }
}
