import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'custom_build_bloc.freezed.dart';
part 'custom_build_event.dart';
part 'custom_build_state.dart';

class CustomBuildBloc extends Bloc<CustomBuildEvent, CustomBuildState> {
  final GenshinService _genshinService;
  final DataService _dataService;

  static int maxTitleLength = 40;
  static int maxNoteLength = 100;
  static int maxNumberOfNotes = 5;
  static List<CharacterSkillType> validSkillTypes = [
    CharacterSkillType.normalAttack,
    CharacterSkillType.elementalSkill,
    CharacterSkillType.elementalBurst,
  ];
  static List<CharacterSkillType> excludedSkillTypes = [CharacterSkillType.others];

  CustomBuildBloc(this._genshinService, this._dataService) : super(const CustomBuildState.loading()) {
    on<CustomBuildEvent>(_handleEvent);
  }

  Future<void> _handleEvent(CustomBuildEvent event, Emitter<CustomBuildState> emit) async {
    //todo: SHOULD I TRHOW ON INVALID REQUEST ?
    final s = await event.map(
      load: (e) async => _init(e.key),
      characterChanged: (e) async => state.maybeMap(
        loaded: (state) => _characterChanged(e, state),
        orElse: () => state,
      ),
      titleChanged: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(title: e.newValue),
        orElse: () => state,
      ),
      roleChanged: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(type: e.newValue),
        orElse: () => state,
      ),
      subRoleChanged: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(subType: e.newValue),
        orElse: () => state,
      ),
      showOnCharacterDetailChanged: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(showOnCharacterDetail: e.newValue),
        orElse: () => state,
      ),
      addWeapon: (e) async => state.maybeMap(
        loaded: (state) => _addWeapon(e, state),
        orElse: () => state,
      ),
      deleteWeapon: (e) async => state.maybeMap(
        loaded: (state) => _deleteWeapon(e, state),
        orElse: () => state,
      ),
      weaponOrderChanged: (e) async => state,
      addArtifact: (e) async => state.maybeMap(
        loaded: (state) => _addArtifact(e, state),
        orElse: () => state,
      ),
      saveChanges: (e) async => state.maybeMap(
        loaded: (state) => _saveChanges(state),
        orElse: () async => state,
      ),
      reset: (e) async => state,
      addNote: (e) async => state.maybeMap(
        loaded: (state) => _addNote(e, state),
        orElse: () => state,
      ),
      deleteNote: (e) async => state.maybeMap(
        loaded: (state) => _deleteNote(e, state),
        orElse: () => state,
      ),
      deleteWeapons: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(weapons: []),
        orElse: () => state,
      ),
      deleteArtifacts: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(artifacts: [], subStatsSummary: []),
        orElse: () => state,
      ),
      deleteSkillPriority: (e) async => state.maybeMap(
        loaded: (state) => _deleteSkillPriority(e, state),
        orElse: () => state,
      ),
      addSkillPriority: (e) async => state.maybeMap(
        loaded: (state) => _addSkillPriority(e, state),
        orElse: () => state,
      ),
      isRecommendedChanged: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(isRecommended: e.newValue),
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
    );

    emit(s);
  }

  CustomBuildState _init(int? key) {
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
        subStatsSummary: _generateSubStatSummary(build.artifacts),
      );
    }

    final character = _genshinService.getCharactersForCard().first;
    return CustomBuildState.loaded(
      title: '',
      type: CharacterRoleType.dps,
      subType: CharacterRoleSubType.none,
      showOnCharacterDetail: true,
      isRecommended: false,
      character: character,
      notes: [],
      weapons: [],
      artifacts: []..sort((x, y) => x.type.index.compareTo(y.type.index)),
      skillPriorities: [],
      subStatsSummary: [],
    );
  }

  CustomBuildState _addNote(_AddNote e, _LoadedState state) {
    if (e.note.isNullEmptyOrWhitespace || state.notes.length >= maxNumberOfNotes) {
      return state;
    }
    final newNote = CustomBuildNoteModel(index: state.notes.length, note: e.note);
    return state.copyWith.call(notes: [...state.notes, newNote]);
  }

  CustomBuildState _deleteNote(_DeleteNote e, _LoadedState state) {
    if (e.index < 0 || e.index >= state.notes.length) {
      return state;
    }

    final notes = [...state.notes];
    notes.removeAt(e.index);
    return state.copyWith.call(notes: notes);
  }

  CustomBuildState _addSkillPriority(_AddSkillPriority e, _LoadedState state) {
    if (state.skillPriorities.contains(e.type) || !validSkillTypes.contains(e.type)) {
      return state;
    }
    return state.copyWith.call(skillPriorities: [...state.skillPriorities, e.type]);
  }

  CustomBuildState _deleteSkillPriority(_DeleteSkillPriority e, _LoadedState state) {
    if (e.index < 0 || e.index >= state.skillPriorities.length) {
      return state;
    }

    final skillPriorities = [...state.skillPriorities];
    skillPriorities.removeAt(e.index);
    return state.copyWith.call(skillPriorities: skillPriorities);
  }

  CustomBuildState _characterChanged(_CharacterChanged e, _LoadedState state) {
    if (state.character.key == e.newKey) {
      return state;
    }
    final newCharacter = _genshinService.getCharacterForCard(e.newKey);
    return state.copyWith.call(character: newCharacter);
  }

  CustomBuildState _addWeapon(_AddWeapon e, _LoadedState state) {
    if (state.weapons.any((el) => el.key == e.key)) {
      throw Exception('Weapons cannot be repeated');
    }
    final weapon = _genshinService.getWeaponForCard(e.key);
    final weapons = [...state.weapons, weapon];
    return state.copyWith.call(weapons: weapons);
  }

  CustomBuildState _deleteWeapon(_DeleteWeapon e, _LoadedState state) {
    if (!state.weapons.any((el) => el.key == e.key)) {
      return state;
    }

    final updated = [...state.weapons];
    updated.removeWhere((el) => el.key == e.key);
    return state.copyWith.call(weapons: updated);
  }

  CustomBuildState _addArtifact(_AddArtifact e, _LoadedState state) {
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
        image: img,
        key: e.key,
        rarity: fullArtifact.maxRarity,
        statType: e.statType,
        subStats: [],
      );
      updatedArtifacts.add(newOne);
    }
    return state.copyWith.call(artifacts: updatedArtifacts..sort((x, y) => x.type.index.compareTo(y.type.index)));
  }

  CustomBuildState _addArtifactSubStats(_AddArtifactSubStats e, _LoadedState state) {
    final artifact = state.artifacts.firstWhereOrNull((el) => el.type == e.type);
    if (artifact == null) {
      return state;
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
    return state.copyWith.call(artifacts: artifacts, subStatsSummary: _generateSubStatSummary(artifacts));
  }

  CustomBuildState _deleteArtifact(_DeleteArtifact e, _LoadedState state) {
    if (!state.artifacts.any((el) => el.type == e.type)) {
      return state;
    }

    final updated = [...state.artifacts];
    updated.removeWhere((el) => el.type == e.type);
    return state.copyWith.call(artifacts: updated, subStatsSummary: _generateSubStatSummary(updated));
  }

  Future<CustomBuildState> _saveChanges(_LoadedState state) async {
    if (state.key != null) {
      await _dataService.customBuilds.updateCustomBuild(
        state.key!,
        state.title,
        state.type,
        state.subType,
        state.showOnCharacterDetail,
        state.isRecommended,
        state.notes,
        state.weapons.map((e) => e.key).toList(),
        [],
        [],
      );

      return _init(state.key);
    }
    final build = await _dataService.customBuilds.saveCustomBuild(
      state.character.key,
      state.title,
      state.type,
      state.subType,
      state.showOnCharacterDetail,
      state.isRecommended,
      state.notes,
      state.weapons.map((e) => e.key).toList(),
      //TODO: THIS
      [],
      [],
    );

    return _init(build.key);
  }

  List<StatType> _generateSubStatSummary(List<CustomBuildArtifactModel> artifacts) {
    final weightMap = <StatType, int>{};

    for (final artifact in artifacts) {
      int weight = artifact.subStats.length;
      for (var i = 0; i < artifact.subStats.length; i++) {
        final subStat = artifact.subStats[i];
        final ifAbsent = weightMap.containsKey(subStat) ? i : weight;
        weightMap.update(subStat, (value) => value + weight, ifAbsent: () => ifAbsent);
        weight--;
      }
    }

    final sorted = weightMap.entries.sorted((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }
}
