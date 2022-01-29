import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
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
    this._customBuildsBloc,
  ) : super(const CustomBuildState.loading());

  @override
  Stream<CustomBuildState> mapEventToState(CustomBuildEvent event) async* {
    final s = await event.map(
      load: (e) async => _init(e.key, e.initialTitle),
      characterChanged: (e) async => state.maybeMap(
        loaded: (state) => _characterChanged(e, state),
        orElse: () => state,
      ),
      titleChanged: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(title: e.newValue, readyForScreenshot: false),
        orElse: () => state,
      ),
      roleChanged: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(type: e.newValue, readyForScreenshot: false),
        orElse: () => state,
      ),
      subRoleChanged: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(subType: e.newValue, readyForScreenshot: false),
        orElse: () => state,
      ),
      showOnCharacterDetailChanged: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(showOnCharacterDetail: e.newValue, readyForScreenshot: false),
        orElse: () => state,
      ),
      isRecommendedChanged: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(isRecommended: e.newValue, readyForScreenshot: false),
        orElse: () => state,
      ),
      addNote: (e) async => state.maybeMap(
        loaded: (state) => _addNote(e, state),
        orElse: () => state,
      ),
      deleteNote: (e) async => state.maybeMap(
        loaded: (state) => _deleteNote(e, state),
        orElse: () => state,
      ),
      addSkillPriority: (e) async => state.maybeMap(
        loaded: (state) => _addSkillPriority(e, state),
        orElse: () => state,
      ),
      deleteSkillPriority: (e) async => state.maybeMap(
        loaded: (state) => _deleteSkillPriority(e, state),
        orElse: () => state,
      ),
      addWeapon: (e) async => state.maybeMap(
        loaded: (state) => _addWeapon(e, state),
        orElse: () => state,
      ),
      weaponRefinementChanged: (e) async => state.maybeMap(
        loaded: (state) => _weaponRefinementChanged(e, state),
        orElse: () => state,
      ),
      weaponsOrderChanged: (e) async => state.maybeMap(
        loaded: (state) => _weaponsOrderChanged(e, state),
        orElse: () => state,
      ),
      deleteWeapon: (e) async => state.maybeMap(
        loaded: (state) => _deleteWeapon(e, state),
        orElse: () => state,
      ),
      deleteWeapons: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(weapons: [], readyForScreenshot: false),
        orElse: () => state,
      ),
      addArtifact: (e) async => state.maybeMap(
        loaded: (state) => _addArtifact(e, state),
        orElse: () => state,
      ),
      addArtifactSubStats: (e) async => state.maybeMap(
        loaded: (state) => _addArtifactSubStats(e, state),
        orElse: () => state,
      ),
      deleteArtifact: (e) async => state.maybeMap(
        loaded: (state) => _deleteArtifact(e, state),
        orElse: () => state,
      ),
      deleteArtifacts: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(artifacts: [], subStatsSummary: [], readyForScreenshot: false),
        orElse: () => state,
      ),
      addTeamCharacter: (e) async => state.maybeMap(
        loaded: (state) => _addTeamCharacter(e, state),
        orElse: () => state,
      ),
      teamCharactersOrderChanged: (e) async => state.maybeMap(
        loaded: (state) => _teamCharactersOrderChanged(e, state),
        orElse: () => state,
      ),
      deleteTeamCharacter: (e) async => state.maybeMap(
        loaded: (state) => _deleteTeamCharacter(e, state),
        orElse: () => state,
      ),
      deleteTeamCharacters: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(teamCharacters: [], readyForScreenshot: false),
        orElse: () => state,
      ),
      readyForScreenshot: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(readyForScreenshot: e.ready),
        orElse: () => state,
      ),
      saveChanges: (e) async => state.maybeMap(
        loaded: (state) => _saveChanges(state),
        orElse: () async => state,
      ),
      screenshotWasTaken: (e) async => state.maybeMap(
        loaded: (state) => _onScreenShootTaken(e, state),
        orElse: () async => state,
      ),
    );

    yield s;
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
        artifacts: build.artifacts..sort((x, y) => x.type.index.compareTo(y.type.index)),
        teamCharacters: build.teamCharacters,
        subStatsSummary: _genshinService.generateSubStatSummary(build.artifacts),
        readyForScreenshot: false,
      );
    }

    final character = _genshinService.getCharactersForCard().first;
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

  CustomBuildState _addNote(_AddNote e, _LoadedState state) {
    if (e.note.isNullEmptyOrWhitespace || state.notes.length >= maxNumberOfNotes) {
      throw Exception('Note is not valid');
    }
    final newNote = CustomBuildNoteModel(index: state.notes.length, note: e.note);
    return state.copyWith.call(notes: [...state.notes, newNote], readyForScreenshot: false);
  }

  CustomBuildState _deleteNote(_DeleteNote e, _LoadedState state) {
    if (e.index < 0 || e.index >= state.notes.length) {
      throw Exception('The provided note index = ${e.index} is not valid');
    }

    final notes = [...state.notes];
    notes.removeAt(e.index);
    return state.copyWith.call(notes: notes, readyForScreenshot: false);
  }

  CustomBuildState _addSkillPriority(_AddSkillPriority e, _LoadedState state) {
    if (state.skillPriorities.contains(e.type)) {
      return state;
    }
    if (!validSkillTypes.contains(e.type)) {
      throw Exception('Skill type = ${e.type} is not valid');
    }
    return state.copyWith.call(skillPriorities: [...state.skillPriorities, e.type], readyForScreenshot: false);
  }

  CustomBuildState _deleteSkillPriority(_DeleteSkillPriority e, _LoadedState state) {
    if (e.index < 0 || e.index >= state.skillPriorities.length) {
      throw Exception('The provided skill index = ${e.index} is not valid');
    }

    final skillPriorities = [...state.skillPriorities];
    skillPriorities.removeAt(e.index);
    return state.copyWith.call(skillPriorities: skillPriorities, readyForScreenshot: false);
  }

  CustomBuildState _characterChanged(_CharacterChanged e, _LoadedState state) {
    if (state.character.key == e.newKey) {
      return state;
    }
    final newCharacter = _genshinService.getCharacterForCard(e.newKey);
    _LoadedState updatedState = state.copyWith.call(character: newCharacter, readyForScreenshot: false);
    if (newCharacter.weaponType != state.character.weaponType) {
      updatedState = updatedState.copyWith.call(weapons: []);
    }

    if (updatedState.teamCharacters.any((el) => el.key == e.newKey)) {
      updatedState.teamCharacters.removeWhere((el) => el.key == e.newKey);
    }

    return updatedState;
  }

  CustomBuildState _addWeapon(_AddWeapon e, _LoadedState state) {
    if (state.weapons.any((el) => el.key == e.key)) {
      throw Exception('Weapons cannot be repeated in the state');
    }

    if (state.weapons.length + 1 > maxNumberOfWeapons) {
      throw Exception('Cannot add more than = $maxNumberOfWeapons weapons to the state');
    }

    final weapon = _genshinService.getWeaponForCard(e.key);
    if (state.character.weaponType != weapon.type) {
      throw Exception('Type = ${weapon.type} is not valid for character = ${state.character.key}');
    }

    final newOne = CustomBuildWeaponModel(
      key: e.key,
      index: state.weapons.length,
      refinement: getWeaponMaxRefinementLevel(weapon.rarity) <= 0 ? 0 : 1,
      name: weapon.name,
      image: weapon.image,
      rarity: weapon.rarity,
      baseAtk: weapon.baseAtk,
      subStatType: weapon.subStatType,
      subStatValue: weapon.subStatValue,
    );
    final weapons = [...state.weapons, newOne];
    return state.copyWith.call(weapons: weapons, readyForScreenshot: false);
  }

  CustomBuildState _weaponsOrderChanged(_WeaponsOrderChanged e, _LoadedState state) {
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

  CustomBuildState _weaponRefinementChanged(_WeaponRefinementChanged e, _LoadedState state) {
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

  CustomBuildState _deleteWeapon(_DeleteWeapon e, _LoadedState state) {
    if (!state.weapons.any((el) => el.key == e.key)) {
      throw Exception('Weapon = ${e.key} does not exist');
    }

    final updated = [...state.weapons];
    updated.removeWhere((el) => el.key == e.key);
    return state.copyWith.call(weapons: updated, readyForScreenshot: false);
  }

  CustomBuildState _addArtifact(_AddArtifact e, _LoadedState state) {
    if (state.artifacts.length + 1 > ArtifactType.values.length) {
      throw Exception('Cannot add more than = ${ArtifactType.values.length} artifacts to the state');
    }

    final fullArtifact = _genshinService.getArtifact(e.key);
    final translation = _genshinService.getArtifactTranslation(e.key);
    final img = _genshinService.getArtifactRelatedPart(fullArtifact.fullImagePath, fullArtifact.image, translation.bonus.length, e.type);

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
    return state.copyWith.call(artifacts: updatedArtifacts..sort((x, y) => x.type.index.compareTo(y.type.index)), readyForScreenshot: false);
  }

  CustomBuildState _addArtifactSubStats(_AddArtifactSubStats e, _LoadedState state) {
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
    return state.copyWith.call(artifacts: artifacts, subStatsSummary: _genshinService.generateSubStatSummary(artifacts), readyForScreenshot: false);
  }

  CustomBuildState _deleteArtifact(_DeleteArtifact e, _LoadedState state) {
    if (!state.artifacts.any((el) => el.type == e.type)) {
      throw Exception('Artifact type = ${e.type} is not in the state');
    }

    final updated = [...state.artifacts];
    updated.removeWhere((el) => el.type == e.type);
    return state.copyWith.call(artifacts: updated, subStatsSummary: _genshinService.generateSubStatSummary(updated), readyForScreenshot: false);
  }

  CustomBuildState _addTeamCharacter(_AddTeamCharacter e, _LoadedState state) {
    if (state.teamCharacters.length + 1 == maxNumberOfTeamCharacters) {
      throw Exception('Cannot add more than = $maxNumberOfTeamCharacters team characters to the state');
    }

    if (e.key == state.character.key) {
      throw Exception('The selected character cannot be in the team characters');
    }

    final char = _genshinService.getCharacterForCard(e.key);
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
        index: state.teamCharacters.length,
        roleType: e.roleType,
        subType: e.subType,
      );
      updatedTeamCharacters.add(newOne);
    }
    return state.copyWith.call(teamCharacters: updatedTeamCharacters, readyForScreenshot: false);
  }

  CustomBuildState _teamCharactersOrderChanged(_TeamCharactersOrderChanged e, _LoadedState state) {
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

  CustomBuildState _deleteTeamCharacter(_DeleteTeamCharacter e, _LoadedState state) {
    if (!state.teamCharacters.any((el) => el.key == e.key)) {
      throw Exception('Team character = ${e.key} is not in the state');
    }

    final updated = [...state.teamCharacters];
    updated.removeWhere((el) => el.key == e.key);
    return state.copyWith.call(teamCharacters: updated, readyForScreenshot: false);
  }

  Future<CustomBuildState> _saveChanges(_LoadedState state) async {
    _LoadedState updatedState;
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
      updatedState = _init(state.key, state.title) as _LoadedState;
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
      updatedState = _init(build.key, state.title) as _LoadedState;
    }

    await _telemetryService.trackCustomBuildSaved(state.character.key, state.type, state.subType);
    _customBuildsBloc.add(const CustomBuildsEvent.load());
    return updatedState.copyWith.call(readyForScreenshot: true);
  }

  Future<CustomBuildState> _onScreenShootTaken(_ScreenshotWasTaken e, _LoadedState state) async {
    if (e.succeed) {
      await _telemetryService.trackCustomBuildScreenShootTaken(state.character.key, state.type, state.subType);
      return state.copyWith.call(readyForScreenshot: false);
    } else {
      _loggingService.error(runtimeType, 'Something went wrong while taking the tier list builder screenshot', e.ex, e.trace);
    }

    return state;
  }
}
