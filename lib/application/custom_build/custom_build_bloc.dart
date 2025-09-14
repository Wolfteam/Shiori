import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'custom_build_bloc.freezed.dart';
part 'custom_build_event.dart';
part 'custom_build_state.dart';

class CustomBuildBloc extends Bloc<CustomBuildEvent, CustomBuildState> {
  final GenshinService _genshinService;
  final DataService _dataService;
  final TelemetryService _telemetryService;
  final CustomBuildsBloc _customBuildsBloc;
  final LoggingService _loggingService;
  final ResourceService _resourceService;

  static int maxTitleLength = 40;
  static int maxNoteLength = 300;
  static int maxNumberOfNotes = 5;
  static List<CharacterSkillType> validSkillTypes = [
    CharacterSkillType.normalAttack,
    CharacterSkillType.elementalSkill,
    CharacterSkillType.elementalBurst,
  ];
  static List<CharacterSkillType> excludedSkillTypes = [CharacterSkillType.others];
  static int maxNumberOfWeapons = 10;
  static int maxNumberOfTeamCharacters = 10;

  CustomBuildBloc(
    this._genshinService,
    this._dataService,
    this._telemetryService,
    this._loggingService,
    this._resourceService,
    this._customBuildsBloc,
  ) : super(const CustomBuildState.loading()) {
    on<CustomBuildEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(CustomBuildEvent event, Emitter<CustomBuildState> emit) async {
    switch (event) {
      case CustomBuildEventInit():
        emit(_init(event.key, event.initialTitle));
      case CustomBuildEventCharacterChanged():
        emit(_characterChanged(event, state as CustomBuildStateLoaded));
      case CustomBuildEventTitleChanged():
        switch (state) {
          case final CustomBuildStateLoaded state:
            emit(state.copyWith.call(title: event.newValue, readyForScreenshot: false));
          default:
            break;
        }
      case CustomBuildEventRoleChanged():
        switch (state) {
          case final CustomBuildStateLoaded state:
            emit(state.copyWith.call(type: event.newValue, readyForScreenshot: false));
          default:
            break;
        }
      case CustomBuildEventSubRoleChanged():
        switch (state) {
          case final CustomBuildStateLoaded state:
            emit(state.copyWith.call(subType: event.newValue, readyForScreenshot: false));
          default:
            break;
        }
      case CustomBuildEventShowOnCharacterDetailChanged():
        switch (state) {
          case final CustomBuildStateLoaded state:
            emit(state.copyWith.call(showOnCharacterDetail: event.newValue, readyForScreenshot: false));
          default:
            break;
        }
      case CustomBuildEventIsRecommendedChanged():
        switch (state) {
          case final CustomBuildStateLoaded state:
            emit(state.copyWith.call(isRecommended: event.newValue, readyForScreenshot: false));
          default:
            break;
        }
      case CustomBuildEventAddSkillPriority():
        emit(_addSkillPriority(event, state as CustomBuildStateLoaded));
      case CustomBuildEventDeleteSkillPriority():
        emit(_deleteSkillPriority(event, state as CustomBuildStateLoaded));
      case CustomBuildEventAddNote():
        emit(_addNote(event, state as CustomBuildStateLoaded));
      case CustomBuildEventDeleteNote():
        emit(_deleteNote(event, state as CustomBuildStateLoaded));
      case CustomBuildEventAddWeapon():
        emit(_addWeapon(event, state as CustomBuildStateLoaded));
      case CustomBuildEventWeaponRefinementChanged():
        emit(_weaponRefinementChanged(event, state as CustomBuildStateLoaded));
      case CustomBuildEventWeaponStatChanged():
        emit(_weaponStatChanged(event, state as CustomBuildStateLoaded));
      case CustomBuildEventWeaponsOrderChanged():
        emit(_weaponsOrderChanged(event, state as CustomBuildStateLoaded));
      case CustomBuildEventDeleteWeapon():
        emit(_deleteWeapon(event, state as CustomBuildStateLoaded));
      case CustomBuildEventDeleteWeapons():
        switch (state) {
          case final CustomBuildStateLoaded state:
            emit(state.copyWith.call(weapons: [], readyForScreenshot: false));
          default:
            break;
        }
      case CustomBuildEventAddArtifact():
        emit(_addArtifact(event, state as CustomBuildStateLoaded));
      case CustomBuildEventAddArtifactSubStats():
        emit(_addArtifactSubStats(event, state as CustomBuildStateLoaded));
      case CustomBuildEventDeleteArtifact():
        emit(_deleteArtifact(event, state as CustomBuildStateLoaded));
      case CustomBuildEventDeleteArtifacts():
        switch (state) {
          case final CustomBuildStateLoaded state:
            emit(state.copyWith.call(artifacts: [], subStatsSummary: [], readyForScreenshot: false));
          default:
            break;
        }
      case CustomBuildEventAddTeamCharacter():
        emit(_addTeamCharacter(event, state as CustomBuildStateLoaded));
      case CustomBuildEventTeamCharactersOrderChanged():
        emit(_teamCharactersOrderChanged(event, state as CustomBuildStateLoaded));
      case CustomBuildEventDeleteTeamCharacter():
        emit(_deleteTeamCharacter(event, state as CustomBuildStateLoaded));
      case CustomBuildEventDeleteTeamCharacters():
        switch (state) {
          case final CustomBuildStateLoaded state:
            emit(state.copyWith.call(teamCharacters: [], readyForScreenshot: false));
          default:
            break;
        }
      case CustomBuildEventReadyForScreenshot():
        switch (state) {
          case final CustomBuildStateLoaded state:
            emit(state.copyWith.call(readyForScreenshot: event.ready));
          default:
            break;
        }
      case CustomBuildEventScreenshotWasTaken():
        emit(await _onScreenShootTaken(event, state as CustomBuildStateLoaded));
      case CustomBuildEventSaveChanges():
        emit(await _saveChanges(state as CustomBuildStateLoaded));
    }
  }

  CustomBuildState _init(int? key, String initialTitle) {
    if (key != null) {
      final build = _dataService.customBuilds.getCustomBuild(key);
      return CustomBuildState.loaded(
        key: key,
        title: build.title,
        type: build.type,
        subType: build.subType,
        showOnCharacterDetail: build.showOnCharacterDetail,
        isRecommended: build.isRecommended,
        character: build.character,
        weapons: build.weapons,
        notes: build.notes,
        skillPriorities: build.skillPriorities,
        artifacts: build.artifacts,
        teamCharacters: build.teamCharacters,
        subStatsSummary: _genshinService.artifacts.generateSubStatSummary(build.artifacts),
        readyForScreenshot: false,
      );
    }

    final character = _genshinService.characters.getCharactersForCard().first;
    return CustomBuildState.loaded(
      title: initialTitle,
      type: CharacterRoleType.dps,
      subType: CharacterRoleSubType.none,
      showOnCharacterDetail: true,
      isRecommended: false,
      character: character,
      notes: [],
      weapons: [],
      artifacts: [],
      teamCharacters: [],
      skillPriorities: [],
      subStatsSummary: [],
      readyForScreenshot: false,
    );
  }

  CustomBuildState _addNote(CustomBuildEventAddNote e, CustomBuildStateLoaded state) {
    if (e.note.isNullEmptyOrWhitespace || state.notes.length >= maxNumberOfNotes) {
      throw Exception('Note is not valid');
    }
    final newNote = CustomBuildNoteModel(index: state.notes.length, note: e.note);
    return state.copyWith.call(notes: [...state.notes, newNote], readyForScreenshot: false);
  }

  CustomBuildState _deleteNote(CustomBuildEventDeleteNote e, CustomBuildStateLoaded state) {
    if (e.index < 0 || e.index >= state.notes.length) {
      throw Exception('The provided note index = ${e.index} is not valid');
    }

    final notes = [...state.notes];
    notes.removeAt(e.index);
    return state.copyWith.call(notes: notes, readyForScreenshot: false);
  }

  CustomBuildState _addSkillPriority(CustomBuildEventAddSkillPriority e, CustomBuildStateLoaded state) {
    if (state.skillPriorities.contains(e.type)) {
      return state;
    }
    if (!validSkillTypes.contains(e.type)) {
      throw Exception('Skill type = ${e.type} is not valid');
    }
    return state.copyWith.call(skillPriorities: [...state.skillPriorities, e.type], readyForScreenshot: false);
  }

  CustomBuildState _deleteSkillPriority(CustomBuildEventDeleteSkillPriority e, CustomBuildStateLoaded state) {
    if (e.index < 0 || e.index >= state.skillPriorities.length) {
      throw Exception('The provided skill index = ${e.index} is not valid');
    }

    final skillPriorities = [...state.skillPriorities];
    skillPriorities.removeAt(e.index);
    return state.copyWith.call(skillPriorities: skillPriorities, readyForScreenshot: false);
  }

  CustomBuildState _characterChanged(CustomBuildEventCharacterChanged e, CustomBuildStateLoaded state) {
    if (state.character.key == e.newKey) {
      return state;
    }
    final newCharacter = _genshinService.characters.getCharacterForCard(e.newKey);
    final weapons = newCharacter.weaponType != state.character.weaponType ? <CustomBuildWeaponModel>[] : state.weapons;
    final teamCharacters = [...state.teamCharacters];
    if (state.teamCharacters.any((el) => el.key == e.newKey)) {
      teamCharacters.removeWhere((el) => el.key == e.newKey);
    }

    return state.copyWith.call(
      character: newCharacter,
      readyForScreenshot: false,
      weapons: weapons,
      teamCharacters: teamCharacters,
    );
  }

  CustomBuildState _addWeapon(CustomBuildEventAddWeapon e, CustomBuildStateLoaded state) {
    if (state.weapons.any((el) => el.key == e.key)) {
      throw Exception('Weapons cannot be repeated in the state');
    }

    if (state.weapons.length + 1 > maxNumberOfWeapons) {
      throw Exception('Cannot add more than = $maxNumberOfWeapons weapons to the state');
    }

    final weapon = _genshinService.weapons.getWeapon(e.key);
    final translation = _genshinService.translations.getWeaponTranslation(e.key);
    if (state.character.weaponType != weapon.type) {
      throw Exception('Type = ${weapon.type} is not valid for character = ${state.character.key}');
    }

    if (weapon.stats.isEmpty) {
      throw Exception('Weapon = ${e.key} does not have any stat');
    }

    final stat = weapon.stats.last;
    final newOne = CustomBuildWeaponModel(
      key: e.key,
      index: state.weapons.length,
      refinement: getWeaponMaxRefinementLevel(weapon.rarity) <= 0 ? 0 : 1,
      name: translation.name,
      image: _resourceService.getWeaponImagePath(weapon.image, weapon.type),
      rarity: weapon.rarity,
      subStatType: weapon.secondaryStat,
      stat: stat,
      stats: weapon.stats,
    );
    final weapons = [...state.weapons, newOne];
    return state.copyWith.call(weapons: weapons, readyForScreenshot: false);
  }

  CustomBuildState _weaponsOrderChanged(CustomBuildEventWeaponsOrderChanged e, CustomBuildStateLoaded state) {
    final weapons = <CustomBuildWeaponModel>[];
    for (var i = 0; i < e.weapons.length; i++) {
      final sortableItem = e.weapons[i];
      final current = state.weapons.firstWhereOrNull((el) => el.key == sortableItem.key);
      if (current == null) {
        throw Exception('Team Character with key = ${sortableItem.key} does not exist');
      }
      weapons.add(current.copyWith.call(index: i));
    }

    return state.copyWith.call(weapons: weapons, readyForScreenshot: false);
  }

  CustomBuildState _weaponRefinementChanged(CustomBuildEventWeaponRefinementChanged e, CustomBuildStateLoaded state) {
    final current = state.weapons.firstWhereOrNull((el) => el.key == e.key);
    if (current == null) {
      throw Exception('Weapon = ${e.key} does not exist in the state');
    }

    if (current.refinement == e.newValue) {
      return state;
    }

    final maxValue = getWeaponMaxRefinementLevel(current.rarity);
    if (e.newValue > maxValue || e.newValue <= 0) {
      throw Exception('The provided refinement = ${e.newValue} cannot exceed = $maxValue');
    }

    final index = state.weapons.indexOf(current);
    final weapons = [...state.weapons];
    weapons.removeAt(index);
    final updated = current.copyWith.call(refinement: e.newValue);
    weapons.insert(index, updated);

    return state.copyWith.call(weapons: weapons, readyForScreenshot: false);
  }

  CustomBuildState _weaponStatChanged(CustomBuildEventWeaponStatChanged e, CustomBuildStateLoaded state) {
    final current = state.weapons.firstWhereOrNull((el) => el.key == e.key);
    if (current == null) {
      throw Exception('Weapon = ${e.key} does not exist in the state');
    }

    if (current.stat == e.newValue) {
      return state;
    }

    final index = state.weapons.indexOf(current);
    final weapons = [...state.weapons];
    weapons.removeAt(index);

    final updated = current.copyWith.call(stat: e.newValue);
    weapons.insert(index, updated);
    return state.copyWith.call(weapons: weapons, readyForScreenshot: false);
  }

  CustomBuildState _deleteWeapon(CustomBuildEventDeleteWeapon e, CustomBuildStateLoaded state) {
    if (!state.weapons.any((el) => el.key == e.key)) {
      throw Exception('Weapon = ${e.key} does not exist');
    }

    final updated = [...state.weapons];
    updated.removeWhere((el) => el.key == e.key);
    return state.copyWith.call(weapons: updated, readyForScreenshot: false);
  }

  CustomBuildState _addArtifact(CustomBuildEventAddArtifact e, CustomBuildStateLoaded state) {
    final fullArtifact = _genshinService.artifacts.getArtifact(e.key);
    final translation = _genshinService.translations.getArtifactTranslation(e.key);
    final img = _genshinService.artifacts.getArtifactRelatedPart(
      _resourceService.getArtifactImagePath(fullArtifact.image),
      fullArtifact.image,
      translation.bonus.length,
      e.type,
    );

    final updatedArtifacts = [...state.artifacts];
    final old = state.artifacts.firstWhereOrNull((el) => el.type == e.type);
    if (old != null) {
      updatedArtifacts.removeWhere((el) => el.type == e.type);
      final updatedSubStats = [...old.subStats]..removeWhere((el) => el == e.statType);
      final updated = old.copyWith.call(
        type: e.type,
        name: translation.name,
        image: img,
        key: e.key,
        rarity: fullArtifact.maxRarity,
        statType: e.statType,
        subStats: updatedSubStats,
      );
      updatedArtifacts.add(updated);
    } else {
      final newOne = CustomBuildArtifactModel(
        type: e.type,
        name: translation.name,
        image: img,
        key: e.key,
        rarity: fullArtifact.maxRarity,
        statType: e.statType,
        subStats: [],
      );
      updatedArtifacts.add(newOne);
    }
    return state.copyWith.call(
      artifacts: updatedArtifacts..sort((x, y) => x.type.index.compareTo(y.type.index)),
      readyForScreenshot: false,
    );
  }

  CustomBuildState _addArtifactSubStats(CustomBuildEventAddArtifactSubStats e, CustomBuildStateLoaded state) {
    final artifact = state.artifacts.firstWhereOrNull((el) => el.type == e.type);
    if (artifact == null) {
      throw Exception('Artifact type = ${e.type} is not in the state');
    }

    final possibleSubStats = getArtifactPossibleSubStats(artifact.statType);
    if (e.subStats.any((s) => !possibleSubStats.contains(s))) {
      throw Exception('One of the provided sub-stats is not valid');
    }

    final index = state.artifacts.indexOf(artifact);
    final updated = artifact.copyWith.call(subStats: e.subStats);
    final artifacts = [...state.artifacts];
    artifacts.removeAt(index);
    artifacts.insert(index, updated);
    return state.copyWith.call(
      artifacts: artifacts,
      subStatsSummary: _genshinService.artifacts.generateSubStatSummary(artifacts),
      readyForScreenshot: false,
    );
  }

  CustomBuildState _deleteArtifact(CustomBuildEventDeleteArtifact e, CustomBuildStateLoaded state) {
    if (!state.artifacts.any((el) => el.type == e.type)) {
      throw Exception('Artifact type = ${e.type} is not in the state');
    }

    final updated = [...state.artifacts];
    updated.removeWhere((el) => el.type == e.type);
    return state.copyWith.call(
      artifacts: updated,
      subStatsSummary: _genshinService.artifacts.generateSubStatSummary(updated),
      readyForScreenshot: false,
    );
  }

  CustomBuildState _addTeamCharacter(CustomBuildEventAddTeamCharacter e, CustomBuildStateLoaded state) {
    if (state.teamCharacters.length + 1 == maxNumberOfTeamCharacters) {
      throw Exception('Cannot add more than = $maxNumberOfTeamCharacters team characters to the state');
    }

    if (e.key == state.character.key) {
      throw Exception('The selected character cannot be in the team characters');
    }

    final char = _genshinService.characters.getCharacterForCard(e.key);
    final updatedTeamCharacters = [...state.teamCharacters];
    final old = updatedTeamCharacters.firstWhereOrNull((el) => el.key == e.key);
    if (old != null) {
      final index = updatedTeamCharacters.indexOf(old);
      updatedTeamCharacters.removeAt(index);
      final updated = old.copyWith.call(
        key: e.key,
        image: char.image,
        name: char.name,
        roleType: e.roleType,
        subType: e.subType,
      );
      updatedTeamCharacters.insert(index, updated);
    } else {
      final newOne = CustomBuildTeamCharacterModel(
        key: e.key,
        name: char.name,
        image: char.image,
        iconImage: char.iconImage,
        index: state.teamCharacters.length,
        roleType: e.roleType,
        subType: e.subType,
      );
      updatedTeamCharacters.add(newOne);
    }
    return state.copyWith.call(teamCharacters: updatedTeamCharacters, readyForScreenshot: false);
  }

  CustomBuildState _teamCharactersOrderChanged(CustomBuildEventTeamCharactersOrderChanged e, CustomBuildStateLoaded state) {
    final teamCharacters = <CustomBuildTeamCharacterModel>[];
    for (var i = 0; i < e.characters.length; i++) {
      final sortableItem = e.characters[i];
      final current = state.teamCharacters.firstWhereOrNull((el) => el.key == sortableItem.key);
      if (current == null) {
        throw Exception('Team Character with key = ${sortableItem.key} does not exist');
      }
      teamCharacters.add(current.copyWith.call(index: i));
    }

    return state.copyWith.call(teamCharacters: teamCharacters, readyForScreenshot: false);
  }

  CustomBuildState _deleteTeamCharacter(CustomBuildEventDeleteTeamCharacter e, CustomBuildStateLoaded state) {
    if (!state.teamCharacters.any((el) => el.key == e.key)) {
      throw Exception('Team character = ${e.key} is not in the state');
    }

    final updated = [...state.teamCharacters];
    updated.removeWhere((el) => el.key == e.key);
    return state.copyWith.call(teamCharacters: updated, readyForScreenshot: false);
  }

  Future<CustomBuildState> _saveChanges(CustomBuildStateLoaded state) async {
    CustomBuildStateLoaded updatedState;
    if (state.key != null) {
      await _dataService.customBuilds.updateCustomBuild(
        state.key!,
        state.title,
        state.type,
        state.subType,
        state.showOnCharacterDetail,
        state.isRecommended,
        state.notes,
        state.weapons,
        state.artifacts,
        state.teamCharacters,
        state.skillPriorities,
      );
      updatedState = _init(state.key, state.title) as CustomBuildStateLoaded;
    } else {
      final build = await _dataService.customBuilds.saveCustomBuild(
        state.character.key,
        state.title,
        state.type,
        state.subType,
        state.showOnCharacterDetail,
        state.isRecommended,
        state.notes,
        state.weapons,
        state.artifacts,
        state.teamCharacters,
        state.skillPriorities,
      );
      updatedState = _init(build.key, state.title) as CustomBuildStateLoaded;
    }

    await _telemetryService.trackCustomBuildSaved(state.character.key, state.type, state.subType);
    _customBuildsBloc.add(const CustomBuildsEvent.load());
    return updatedState.copyWith.call(readyForScreenshot: true);
  }

  Future<CustomBuildState> _onScreenShootTaken(CustomBuildEventScreenshotWasTaken e, CustomBuildStateLoaded state) async {
    if (e.succeed) {
      await _telemetryService.trackCustomBuildScreenShootTaken(state.character.key, state.type, state.subType);
      return state.copyWith.call(readyForScreenshot: false);
    } else {
      _loggingService.error(runtimeType, 'Something went wrong while taking the tier list builder screenshot', e.ex, e.trace);
    }

    return state;
  }
}
