import 'package:hive/hive.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/persistence/custom_builds_data_service.dart';

class CustomBuildsDataServiceImpl implements CustomBuildsDataService {
  final GenshinService _genshinService;

  late Box<CustomBuild> _buildsBox;
  late Box<CustomBuildWeapon> _weaponsBox;
  late Box<CustomBuildArtifact> _artifactsBox;
  late Box<CustomBuildNote> _notesBox;
  late Box<CustomBuildTeamCharacter> _teamCharactersBox;

  CustomBuildsDataServiceImpl(this._genshinService);

  @override
  Future<void> init() async {
    _registerAdapters();
    _buildsBox = await Hive.openBox<CustomBuild>('customBuilds');
    _weaponsBox = await Hive.openBox<CustomBuildWeapon>('customBuildWeapons');
    _artifactsBox = await Hive.openBox<CustomBuildArtifact>('customBuildArtifacts');
    _notesBox = await Hive.openBox<CustomBuildNote>('customBuildNotes');
    _teamCharactersBox = await Hive.openBox<CustomBuildTeamCharacter>('customBuildTeamCharacters');
  }

  void _registerAdapters() {
    Hive.registerAdapter(CustomBuildAdapter());
    Hive.registerAdapter(CustomBuildWeaponAdapter());
    Hive.registerAdapter(CustomBuildArtifactAdapter());
    Hive.registerAdapter(CustomBuildNoteAdapter());
    Hive.registerAdapter(CustomBuildTeamCharacterAdapter());
  }

  @override
  Future<void> deleteThemAll() {
    return Future.wait([
      _buildsBox.clear(),
      _weaponsBox.clear(),
      _artifactsBox.clear(),
      _notesBox.clear(),
      _teamCharactersBox.clear(),
    ]);
  }

  @override
  List<CustomBuildModel> getAllCustomBuilds() {
    return _buildsBox.values.map((e) => getCustomBuild(e.key as int)).toList()..sort((x, y) => x.character.name.compareTo(y.character.name));
  }

  @override
  CustomBuildModel getCustomBuild(int key) {
    final build = _buildsBox.values.firstWhere((e) => e.key == key);
    final notes = _notesBox.values.where((el) => el.buildItemKey == key).toList();
    final weapons = _weaponsBox.values.where((el) => el.buildItemKey == key).toList();
    final artifacts = _artifactsBox.values.where((el) => el.buildItemKey == key).toList();
    final teamCharacters = _teamCharactersBox.values.where((el) => el.buildItemKey == key).toList();
    return _mapToCustomBuildModel(build, notes, weapons, artifacts, teamCharacters);
  }

  @override
  Future<CustomBuildModel> saveCustomBuild(
    String charKey,
    String title,
    CharacterRoleType type,
    CharacterRoleSubType subType,
    bool showOnCharacterDetail,
    bool isRecommended,
    List<CustomBuildNoteModel> notes,
    List<CustomBuildWeaponModel> weapons,
    List<CustomBuildArtifactModel> artifacts,
    List<CustomBuildTeamCharacterModel> teamCharacters,
    List<CharacterSkillType> skillPriorities,
  ) async {
    final build = CustomBuild(
      charKey,
      showOnCharacterDetail,
      title,
      type.index,
      subType.index,
      skillPriorities.map((e) => e.index).toList(),
      isRecommended,
    );
    await _buildsBox.add(build);

    final buildKey = build.key as int;
    final buildNotes = await _saveNotes(buildKey, notes);
    final buildWeapons = await _saveWeapons(buildKey, weapons);
    final buildArtifacts = await _saveArtifacts(buildKey, artifacts);
    final buildTeamCharacters = await _saveTeamCharacters(buildKey, teamCharacters);
    return _mapToCustomBuildModel(build, buildNotes, buildWeapons, buildArtifacts, buildTeamCharacters);
  }

  @override
  Future<CustomBuildModel> updateCustomBuild(
    int key,
    String title,
    CharacterRoleType type,
    CharacterRoleSubType subType,
    bool showOnCharacterDetail,
    bool isRecommended,
    List<CustomBuildNoteModel> notes,
    List<CustomBuildWeaponModel> weapons,
    List<CustomBuildArtifactModel> artifacts,
    List<CustomBuildTeamCharacterModel> teamCharacters,
    List<CharacterSkillType> skillPriorities,
  ) async {
    final build = _buildsBox.get(key)!;
    build.title = title;
    build.roleType = type.index;
    build.roleSubType = subType.index;
    build.showOnCharacterDetail = showOnCharacterDetail;
    build.skillPriorities = skillPriorities.map((e) => e.index).toList();
    build.isRecommended = isRecommended;

    await build.save();

    await _deleteCustomBuildRelatedParts(key);

    final buildNotes = await _saveNotes(key, notes);
    final buildWeapons = await _saveWeapons(key, weapons);
    final buildArtifacts = await _saveArtifacts(key, artifacts);
    final buildTeamCharacters = await _saveTeamCharacters(key, teamCharacters);
    return _mapToCustomBuildModel(build, buildNotes, buildWeapons, buildArtifacts, buildTeamCharacters);
  }

  @override
  Future<void> deleteCustomBuild(int key) {
    return Future.wait([
      _buildsBox.delete(key),
      _deleteCustomBuildRelatedParts(key),
    ]);
  }

  Future<void> _deleteCustomBuildRelatedParts(int key) {
    return Future.wait([
      _deleteWeapons(key),
      _deleteArtifacts(key),
      _deleteNotes(key),
      _deleteTeamCharacters(key),
    ]);
  }

  Future<List<CustomBuildNote>> _saveNotes(int buildKey, List<CustomBuildNoteModel> notes) async {
    final buildNotes = notes.map((e) => CustomBuildNote(buildKey, e.index, e.note)).toList();
    await _notesBox.addAll(buildNotes);
    return buildNotes;
  }

  Future<List<CustomBuildWeapon>> _saveWeapons(int buildKey, List<CustomBuildWeaponModel> weapons) async {
    final buildWeapons = weapons.map((e) => CustomBuildWeapon(buildKey, e.key, e.index, e.refinement)).toList();
    await _weaponsBox.addAll(buildWeapons);
    return buildWeapons;
  }

  Future<List<CustomBuildArtifact>> _saveArtifacts(int buildKey, List<CustomBuildArtifactModel> artifacts) async {
    final buildArtifacts = artifacts
        .map(
          (e) => CustomBuildArtifact(buildKey, e.key, e.type.index, e.statType.index, e.subStats.map((e) => e.index).toList()),
        )
        .toList();
    await _artifactsBox.addAll(buildArtifacts);
    return buildArtifacts;
  }

  Future<List<CustomBuildTeamCharacter>> _saveTeamCharacters(int buildKey, List<CustomBuildTeamCharacterModel> teamCharacters) async {
    final buildTeamCharacters = teamCharacters
        .map(
          (e) => CustomBuildTeamCharacter(buildKey, e.index, e.key, e.roleType.index, e.subType.index),
        )
        .toList();
    await _teamCharactersBox.addAll(buildTeamCharacters);
    return buildTeamCharacters;
  }

  Future<void> _deleteNotes(int buildKey) async {
    final keys = _notesBox.values.where((el) => el.buildItemKey == buildKey).map((e) => e.key as int).toList();
    if (keys.isNotEmpty) {
      await _notesBox.deleteAll(keys);
    }
  }

  Future<void> _deleteWeapons(int buildKey) async {
    final keys = _weaponsBox.values.where((el) => el.buildItemKey == buildKey).map((e) => e.key as int).toList();
    if (keys.isNotEmpty) {
      await _weaponsBox.deleteAll(keys);
    }
  }

  Future<void> _deleteArtifacts(int buildKey) async {
    final keys = _artifactsBox.values.where((el) => el.buildItemKey == buildKey).map((e) => e.key as int).toList();
    if (keys.isNotEmpty) {
      await _artifactsBox.deleteAll(keys);
    }
  }

  Future<void> _deleteTeamCharacters(int buildKey) async {
    final keys = _teamCharactersBox.values.where((el) => el.buildItemKey == buildKey).map((e) => e.key as int).toList();
    if (keys.isNotEmpty) {
      await _teamCharactersBox.deleteAll(keys);
    }
  }

  CustomBuildModel _mapToCustomBuildModel(
    CustomBuild build,
    List<CustomBuildNote> notes,
    List<CustomBuildWeapon> weapons,
    List<CustomBuildArtifact> artifacts,
    List<CustomBuildTeamCharacter> teamCharacters,
  ) {
    final character = _genshinService.getCharacterForCard(build.characterKey);
    return CustomBuildModel(
      key: build.key as int,
      title: build.title,
      type: CharacterRoleType.values[build.roleType],
      subType: CharacterRoleSubType.values[build.roleSubType],
      showOnCharacterDetail: build.showOnCharacterDetail,
      isRecommended: build.isRecommended,
      character: character,
      weapons: weapons.map((e) {
        final weapon = _genshinService.getWeaponForCard(e.weaponKey);
        return CustomBuildWeaponModel(
          key: e.weaponKey,
          index: e.index,
          refinement: e.refinement,
          name: weapon.name,
          image: weapon.image,
          rarity: weapon.rarity,
          baseAtk: weapon.baseAtk,
          subStatType: weapon.subStatType,
          subStatValue: weapon.subStatValue,
        );
      }).toList(),
      artifacts: artifacts.map((e) {
        final fullArtifact = _genshinService.getArtifact(e.itemKey);
        final translation = _genshinService.getArtifactTranslation(e.itemKey);
        final image = _genshinService.getArtifactRelatedPart(
          fullArtifact.fullImagePath,
          fullArtifact.image,
          translation.bonus.length,
          ArtifactType.values[e.type],
        );
        return CustomBuildArtifactModel(
          key: e.itemKey,
          type: ArtifactType.values[e.type],
          statType: StatType.values[e.statType],
          image: image,
          rarity: fullArtifact.maxRarity,
          subStats: e.subStats.map((e) => StatType.values[e]).toList(),
        );
      }).toList(),
      skillPriorities: build.skillPriorities.map((e) => CharacterSkillType.values[e]).toList(),
      notes: notes.map((e) => CustomBuildNoteModel(index: e.index, note: e.note)).toList()..sort((x, y) => x.index.compareTo(y.index)),
      teamCharacters: teamCharacters.map((e) {
        final char = _genshinService.getCharacterForCard(e.characterKey);
        return CustomBuildTeamCharacterModel(
          key: e.characterKey,
          index: e.index,
          name: char.name,
          image: char.image,
          roleType: CharacterRoleType.values[e.roleType],
          subType: CharacterRoleSubType.values[e.subType],
        );
      }).toList()
        ..sort((x, y) => x.index.compareTo(y.index)),
    );
  }
}
