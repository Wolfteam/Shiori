import 'package:hive_ce/hive.dart';
import 'package:shiori/domain/check.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/persistence/custom_builds_data_service.dart';
import 'package:shiori/domain/services/resources_service.dart';

class CustomBuildsDataServiceImpl implements CustomBuildsDataService {
  final GenshinService _genshinService;
  final ResourceService _resourceService;

  late Box<CustomBuild> _buildsBox;
  late Box<CustomBuildWeapon> _weaponsBox;
  late Box<CustomBuildArtifact> _artifactsBox;
  late Box<CustomBuildNote> _notesBox;
  late Box<CustomBuildTeamCharacter> _teamCharactersBox;

  CustomBuildsDataServiceImpl(this._genshinService, this._resourceService);

  @override
  Future<void> init() async {
    _buildsBox = await Hive.openBox<CustomBuild>('customBuilds');
    _weaponsBox = await Hive.openBox<CustomBuildWeapon>('customBuildWeapons');
    _artifactsBox = await Hive.openBox<CustomBuildArtifact>('customBuildArtifacts');
    _notesBox = await Hive.openBox<CustomBuildNote>('customBuildNotes');
    _teamCharactersBox = await Hive.openBox<CustomBuildTeamCharacter>('customBuildTeamCharacters');
  }

  @override
  Future<void> deleteThemAll() {
    return Future.wait([_buildsBox.clear(), _weaponsBox.clear(), _artifactsBox.clear(), _notesBox.clear(), _teamCharactersBox.clear()]);
  }

  @override
  List<CustomBuildModel> getAllCustomBuilds() {
    return _buildsBox.values.map((e) => getCustomBuild(e.id)).toList()..sort((x, y) => x.character.name.compareTo(y.character.name));
  }

  @override
  CustomBuildModel getCustomBuild(int key) {
    Check.greaterThanOrEqualToZero(key, 'key');
    _checkBuild(key);
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
    Check.notEmpty(charKey, 'charKey');
    Check.notEmpty(title, 'title');
    Check.notEmpty(weapons, 'weapons');
    Check.notEmpty(artifacts, 'artifacts');

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

    final buildKey = build.id;
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
    Check.greaterThanOrEqualToZero(key, 'key');
    Check.notEmpty(title, 'title');
    Check.notEmpty(weapons, 'weapons');
    Check.notEmpty(artifacts, 'artifacts');
    _checkBuild(key);

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
  Future<void> deleteCustomBuild(int key) async {
    Check.greaterThanOrEqualToZero(key, 'key');
    await Future.wait([_buildsBox.delete(key), _deleteCustomBuildRelatedParts(key)]);
  }

  @override
  List<CharacterBuildCardModel> getCustomBuildsForCharacter(String charKey) {
    Check.notEmpty(charKey, 'charKey');

    return _buildsBox.values.where((el) => el.showOnCharacterDetail && el.characterKey == charKey).map((e) {
      final build = getCustomBuild(e.id);
      final artifacts = build.artifacts.map((e) => _genshinService.artifacts.getArtifactForCard(e.key)).toList();
      return CharacterBuildCardModel(
        isRecommended: e.isRecommended,
        isCustomBuild: true,
        type: CharacterRoleType.values[e.roleType],
        subType: CharacterRoleSubType.values[e.roleSubType],
        skillPriorities: e.skillPriorities.map((e) => CharacterSkillType.values[e]).toList(),
        subStatsToFocus: _genshinService.artifacts.generateSubStatSummary(build.artifacts),
        weapons: build.weapons.map((e) => _genshinService.weapons.getWeaponForCard(e.key)).toList(),
        artifacts: [CharacterBuildArtifactModel(one: null, stats: build.artifacts.map((e) => e.statType).toList(), multiples: artifacts)],
      );
    }).toList();
  }

  @override
  List<BackupCustomBuildModel> getDataForBackup() {
    return _buildsBox.values.map((build) {
      final buildKey = build.id;
      final notes =
          _notesBox.values.where((e) => e.buildItemKey == buildKey).map((e) => BackupCustomBuildNoteModel(note: e.note, index: e.index)).toList();
      final weapons =
          _weaponsBox.values
              .where((e) => e.buildItemKey == buildKey)
              .map(
                (e) => BackupCustomBuildWeaponModel(
                  weaponKey: e.weaponKey,
                  index: e.index,
                  level: e.level,
                  isAnAscension: e.isAnAscension,
                  refinement: e.refinement,
                ),
              )
              .toList();
      final artifacts =
          _artifactsBox.values
              .where((e) => e.buildItemKey == buildKey)
              .map((e) => BackupCustomBuildArtifactModel(itemKey: e.itemKey, type: e.type, statType: e.statType, subStats: e.subStats))
              .toList();
      final team =
          _teamCharactersBox.values
              .where((e) => e.buildItemKey == buildKey)
              .map((e) => BackupCustomBuildTeamCharacterModel(characterKey: e.characterKey, index: e.index, roleType: e.roleType, subType: e.subType))
              .toList();
      return BackupCustomBuildModel(
        characterKey: build.characterKey,
        title: build.title,
        isRecommended: build.isRecommended,
        showOnCharacterDetail: build.showOnCharacterDetail,
        roleType: build.roleType,
        roleSubType: build.roleSubType,
        skillPriorities: build.skillPriorities,
        notes: notes,
        weapons: weapons,
        artifacts: artifacts,
        team: team,
      );
    }).toList();
  }

  @override
  Future<void> restoreFromBackup(List<BackupCustomBuildModel> data) async {
    await deleteThemAll();
    for (final build in data) {
      final artifacts =
          build.artifacts
              .map(
                (e) => CustomBuildArtifactModel(
                  key: e.itemKey,
                  rarity: 0,
                  name: '',
                  image: '',
                  type: ArtifactType.values[e.type],
                  subStats: e.subStats.map((statType) => StatType.values[statType]).toList(),
                  statType: StatType.values[e.statType],
                ),
              )
              .toList();
      final weapons =
          build.weapons
              .map(
                (e) => CustomBuildWeaponModel(
                  key: e.weaponKey,
                  image: '',
                  name: '',
                  index: e.index,
                  refinement: e.refinement,
                  rarity: 0,
                  stat: WeaponFileStatModel(level: e.level, isAnAscension: e.isAnAscension, baseAtk: 0, statValue: 0),
                  stats: [],
                  subStatType: StatType.none,
                ),
              )
              .toList();
      final notes = build.notes.map((e) => CustomBuildNoteModel(index: e.index, note: e.note)).toList();
      final skillPriorities = build.skillPriorities.map((e) => CharacterSkillType.values[e]).toList();
      final teamCharacters =
          build.team
              .map(
                (e) => CustomBuildTeamCharacterModel(
                  key: e.characterKey,
                  image: '',
                  name: '',
                  iconImage: '',
                  index: e.index,
                  roleType: CharacterRoleType.values[e.roleType],
                  subType: CharacterRoleSubType.values[e.subType],
                ),
              )
              .toList();
      await saveCustomBuild(
        build.characterKey,
        build.title,
        CharacterRoleType.values[build.roleType],
        CharacterRoleSubType.values[build.roleSubType],
        build.showOnCharacterDetail,
        build.isRecommended,
        notes,
        weapons,
        artifacts,
        teamCharacters,
        skillPriorities,
      );
    }
  }

  Future<void> _deleteCustomBuildRelatedParts(int key) {
    return Future.wait([_deleteWeapons(key), _deleteArtifacts(key), _deleteNotes(key), _deleteTeamCharacters(key)]);
  }

  Future<List<CustomBuildNote>> _saveNotes(int buildKey, List<CustomBuildNoteModel> notes) async {
    final buildNotes = notes.map((e) => CustomBuildNote(buildKey, e.index, e.note)).toList();
    await _notesBox.addAll(buildNotes);
    return buildNotes;
  }

  Future<List<CustomBuildWeapon>> _saveWeapons(int buildKey, List<CustomBuildWeaponModel> weapons) async {
    final buildWeapons = weapons.map((e) => CustomBuildWeapon(buildKey, e.key, e.index, e.refinement, e.stat.level, e.stat.isAnAscension)).toList();
    await _weaponsBox.addAll(buildWeapons);
    return buildWeapons;
  }

  Future<List<CustomBuildArtifact>> _saveArtifacts(int buildKey, List<CustomBuildArtifactModel> artifacts) async {
    final buildArtifacts =
        artifacts.map((e) => CustomBuildArtifact(buildKey, e.key, e.type.index, e.statType.index, e.subStats.map((e) => e.index).toList())).toList();
    await _artifactsBox.addAll(buildArtifacts);
    return buildArtifacts;
  }

  Future<List<CustomBuildTeamCharacter>> _saveTeamCharacters(int buildKey, List<CustomBuildTeamCharacterModel> teamCharacters) async {
    final buildTeamCharacters =
        teamCharacters.map((e) => CustomBuildTeamCharacter(buildKey, e.index, e.key, e.roleType.index, e.subType.index)).toList();
    await _teamCharactersBox.addAll(buildTeamCharacters);
    return buildTeamCharacters;
  }

  Future<void> _deleteNotes(int buildKey) async {
    final keys = _notesBox.values.where((el) => el.buildItemKey == buildKey).map((e) => e.id).toList();
    if (keys.isNotEmpty) {
      await _notesBox.deleteAll(keys);
    }
  }

  Future<void> _deleteWeapons(int buildKey) async {
    final keys = _weaponsBox.values.where((el) => el.buildItemKey == buildKey).map((e) => e.id).toList();
    if (keys.isNotEmpty) {
      await _weaponsBox.deleteAll(keys);
    }
  }

  Future<void> _deleteArtifacts(int buildKey) async {
    final keys = _artifactsBox.values.where((el) => el.buildItemKey == buildKey).map((e) => e.id).toList();
    if (keys.isNotEmpty) {
      await _artifactsBox.deleteAll(keys);
    }
  }

  Future<void> _deleteTeamCharacters(int buildKey) async {
    final keys = _teamCharactersBox.values.where((el) => el.buildItemKey == buildKey).map((e) => e.id).toList();
    if (keys.isNotEmpty) {
      await _teamCharactersBox.deleteAll(keys);
    }
  }

  CustomBuildModel _mapToCustomBuildModel(
    CustomBuild build,
    List<CustomBuildNote> buildNotes,
    List<CustomBuildWeapon> buildWeapons,
    List<CustomBuildArtifact> buildArtifacts,
    List<CustomBuildTeamCharacter> buildTeamCharacters,
  ) {
    final character = _genshinService.characters.getCharacterForCard(build.characterKey);
    final artifacts =
        buildArtifacts.map((e) {
            final fullArtifact = _genshinService.artifacts.getArtifact(e.itemKey);
            final translation = _genshinService.translations.getArtifactTranslation(e.itemKey);
            final image = _genshinService.artifacts.getArtifactRelatedPart(
              _resourceService.getArtifactImagePath(fullArtifact.image),
              fullArtifact.image,
              translation.bonus.length,
              ArtifactType.values[e.type],
            );
            return CustomBuildArtifactModel(
              key: e.itemKey,
              name: translation.name,
              type: ArtifactType.values[e.type],
              statType: StatType.values[e.statType],
              image: image,
              rarity: fullArtifact.maxRarity,
              subStats: e.subStats.map((e) => StatType.values[e]).toList(),
            );
          }).toList()
          ..sort((x, y) => x.type.index.compareTo(y.type.index));
    return CustomBuildModel(
      key: build.id,
      title: build.title,
      type: CharacterRoleType.values[build.roleType],
      subType: CharacterRoleSubType.values[build.roleSubType],
      showOnCharacterDetail: build.showOnCharacterDetail,
      isRecommended: build.isRecommended,
      character: character,
      weapons:
          buildWeapons.map((e) {
              final weapon = _genshinService.weapons.getWeapon(e.weaponKey);
              final translation = _genshinService.translations.getWeaponTranslation(e.weaponKey);
              final stat =
                  e.level <= 0 ? weapon.stats.last : weapon.stats.firstWhere((el) => el.level == e.level && el.isAnAscension == e.isAnAscension);
              return CustomBuildWeaponModel(
                key: e.weaponKey,
                index: e.index,
                refinement: e.refinement,
                name: translation.name,
                image: _resourceService.getWeaponImagePath(weapon.image, weapon.type),
                rarity: weapon.rarity,
                subStatType: weapon.secondaryStat,
                stat: stat,
                stats: weapon.stats,
              );
            }).toList()
            ..sort((x, y) => x.index.compareTo(y.index)),
      artifacts: artifacts,
      subStatsSummary: _genshinService.artifacts.generateSubStatSummary(artifacts),
      skillPriorities: build.skillPriorities.map((e) => CharacterSkillType.values[e]).toList(),
      notes: buildNotes.map((e) => CustomBuildNoteModel(index: e.index, note: e.note)).toList()..sort((x, y) => x.index.compareTo(y.index)),
      teamCharacters:
          buildTeamCharacters.map((e) {
              final char = _genshinService.characters.getCharacterForCard(e.characterKey);
              return CustomBuildTeamCharacterModel(
                key: e.characterKey,
                index: e.index,
                name: char.name,
                image: char.image,
                iconImage: char.iconImage,
                roleType: CharacterRoleType.values[e.roleType],
                subType: CharacterRoleSubType.values[e.subType],
              );
            }).toList()
            ..sort((x, y) => x.index.compareTo(y.index)),
    );
  }

  void _checkBuild(int key) {
    if (!_buildsBox.containsKey(key)) {
      throw NotFoundError(key, 'key', 'Custom build does not exist');
    }
  }
}
