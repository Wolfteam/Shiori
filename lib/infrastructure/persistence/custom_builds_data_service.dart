import 'package:hive/hive.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/persistence/custom_builds_data_service.dart';

class CustomBuildsDataServiceImpl implements CustomBuildsDataService {
  final GenshinService _genshinService;

  late Box<CustomBuild> _buildsBox;
  late Box<CustomBuildArtifact> _artifactsBox;
  late Box<CustomBuildNote> _notesBox;

  CustomBuildsDataServiceImpl(this._genshinService);

  @override
  Future<void> init() async {
    _buildsBox = await Hive.openBox<CustomBuild>('customBuilds');
    _artifactsBox = await Hive.openBox<CustomBuildArtifact>('customBuildArtifacts');
    _notesBox = await Hive.openBox<CustomBuildNote>('customBuildNotes');
  }

  @override
  Future<void> deleteThemAll() {
    return Future.wait([
      _buildsBox.clear(),
      _artifactsBox.clear(),
      _notesBox.clear(),
    ]);
  }

  @override
  List<CustomBuildModel> getAllCustomBuilds() {
    return _buildsBox.values.map((e) {
      final key = e.key as int;
      final notes = _notesBox.values.where((el) => el.buildItemKey == key).toList();
      final artifacts = _artifactsBox.values.where((el) => el.buildItemKey == key).toList();
      return _mapToCustomBuildModel(e, notes, artifacts);
    }).toList()
      ..sort((x, y) => x.character.name.compareTo(y.character.name));
  }

  @override
  CustomBuildModel getCustomBuild(int key) {
    final build = _buildsBox.values.firstWhere((e) => e.key == key);
    final notes = _notesBox.values.where((el) => el.buildItemKey == key).toList();
    final artifacts = _artifactsBox.values.where((el) => el.buildItemKey == key).toList();
    return _mapToCustomBuildModel(build, notes, artifacts);
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
    List<String> weaponKeys,
    List<CustomBuildArtifactModel> artifacts,
    List<CharacterSkillType> skillPriorities,
  ) async {
    final build = CustomBuild(
      charKey,
      showOnCharacterDetail,
      title,
      type.index,
      subType.index,
      weaponKeys,
      skillPriorities.map((e) => e.index).toList(),
      isRecommended,
    );
    await _buildsBox.add(build);

    final buildKey = build.key as int;
    final buildNotes = await _saveNotes(buildKey, notes);
    final buildArtifacts = await _saveArtifacts(buildKey, artifacts);
    return _mapToCustomBuildModel(build, buildNotes, buildArtifacts);
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
    List<String> weaponKeys,
    List<CustomBuildArtifactModel> artifacts,
    List<CharacterSkillType> skillPriorities,
  ) async {
    final build = _buildsBox.get(key)!;
    build.title = title;
    build.roleType = type.index;
    build.roleSubType = subType.index;
    build.showOnCharacterDetail = showOnCharacterDetail;
    build.weaponKeys = weaponKeys;
    build.skillPriorities = skillPriorities.map((e) => e.index).toList();
    build.isRecommended = isRecommended;

    await build.save();

    await Future.wait([
      _deleteArtifacts(key),
      _deleteNotes(key),
    ]);

    final buildNotes = await _saveNotes(key, notes);
    final buildArtifacts = await _saveArtifacts(key, artifacts);
    return _mapToCustomBuildModel(build, buildNotes, buildArtifacts);
  }

  @override
  Future<void> deleteCustomBuild(int key) {
    return Future.wait([
      _buildsBox.delete(key),
      _deleteNotes(key),
      _deleteArtifacts(key),
    ]);
  }

  Future<List<CustomBuildNote>> _saveNotes(int buildKey, List<CustomBuildNoteModel> notes) async {
    final buildNotes = notes.map((e) => CustomBuildNote(buildKey, e.index, e.note)).toList();
    await _notesBox.addAll(buildNotes);
    return buildNotes;
  }

  Future<List<CustomBuildArtifact>> _saveArtifacts(int buildKey, List<CustomBuildArtifactModel> artifacts) async {
    final buildArtifacts = artifacts.map((e) => CustomBuildArtifact(buildKey, e.key, e.type, e.statType, e.subStats)).toList();
    await _artifactsBox.addAll(buildArtifacts);
    return buildArtifacts;
  }

  Future<void> _deleteNotes(int buildKey) async {
    final noteKeys = _notesBox.values.where((el) => el.buildItemKey == buildKey).map((e) => e.key as int).toList();
    if (noteKeys.isNotEmpty) {
      await _notesBox.deleteAll(noteKeys);
    }
  }

  Future<void> _deleteArtifacts(int buildKey) async {
    final artifactsKeys = _artifactsBox.values.where((el) => el.buildItemKey == buildKey).map((e) => e.key as int).toList();
    if (artifactsKeys.isNotEmpty) {
      await _artifactsBox.deleteAll(artifactsKeys);
    }
  }

  CustomBuildModel _mapToCustomBuildModel(CustomBuild build, List<CustomBuildNote> notes, List<CustomBuildArtifact> artifacts) {
    final character = _genshinService.getCharacterForCard(build.characterKey);
    final weapons = build.weaponKeys.map((e) => _genshinService.getWeaponForCard(e)).toList();
    // final artifacts = build.artifactKeys.map((e) => _genshinService.getArtifactForCard(e)).toList();
    return CustomBuildModel(
      key: build.key as int,
      title: build.title,
      type: CharacterRoleType.values[build.roleType],
      subType: CharacterRoleSubType.values[build.roleSubType],
      showOnCharacterDetail: build.showOnCharacterDetail,
      isRecommended: build.isRecommended,
      character: character,
      weapons: weapons,
      //TODO: THIS
      artifacts: [],
      skillPriorities: build.skillPriorities.map((e) => CharacterSkillType.values[e]).toList(),
      notes: notes.map((e) => CustomBuildNoteModel(index: e.index, note: e.note)).toList()..sort((x, y) => x.index.compareTo(y.index)),
    );
  }
}
