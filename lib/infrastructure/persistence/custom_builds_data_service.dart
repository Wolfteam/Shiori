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

  CustomBuildsDataServiceImpl(this._genshinService);

  @override
  Future<void> init() async {
    _buildsBox = await Hive.openBox<CustomBuild>('customBuilds');
  }

  @override
  Future<void> deleteThemAll() {
    return _buildsBox.clear();
  }

  @override
  List<CustomBuildModel> getAllCustomBuilds() {
    return _buildsBox.values.map((e) {
      final artifacts = _artifactsBox.values.where((el) => el.buildItemKey == e.key as int).toList();
      return _mapToCustomBuildModel(e, artifacts);
    }).toList()
      ..sort((x, y) => x.character.name.compareTo(y.character.name));
  }

  @override
  CustomBuildModel getCustomBuild(int key) {
    final build = _buildsBox.values.firstWhere((e) => e.key == key);
    final artifacts = _artifactsBox.values.where((el) => el.buildItemKey == key).toList();
    return _mapToCustomBuildModel(build, artifacts);
  }

  @override
  Future<CustomBuildModel> saveCustomBuild(
    String charKey,
    String title,
    CharacterRoleType type,
    CharacterRoleSubType subType,
    bool showOnCharacterDetail,
    List<String> weaponKeys,
    List<CustomBuildArtifactModel> artifacts,
    List<CharacterSkillType> talentPriority,
  ) async {
    final build = CustomBuild(
      charKey,
      showOnCharacterDetail,
      title,
      type.index,
      subType.index,
      weaponKeys,
      talentPriority.map((e) => e.index).toList(),
    );
    await _buildsBox.add(build);

    final buildArtifacts = artifacts.map((e) => CustomBuildArtifact(build.key as int, e.key, e.type, e.statType)).toList();
    await _artifactsBox.addAll(buildArtifacts);
    return _mapToCustomBuildModel(build, buildArtifacts);
  }

  @override
  Future<CustomBuildModel> updateCustomBuild(
    int key,
    String title,
    CharacterRoleType type,
    CharacterRoleSubType subType,
    bool showOnCharacterDetail,
    List<String> weaponKeys,
    List<CustomBuildArtifactModel> artifacts,
    List<CharacterSkillType> talentPriority,
  ) async {
    final build = _buildsBox.get(key)!;
    build.title = title;
    build.roleType = type.index;
    build.roleSubType = subType.index;
    build.showOnCharacterDetail = showOnCharacterDetail;
    build.weaponKeys = weaponKeys;
    build.talentPriority = talentPriority.map((e) => e.index).toList();

    await build.save();

    //TODO: UPDATE ARTIFACTS ?

    return _mapToCustomBuildModel(build, []);
  }

  @override
  Future<void> deleteCustomBuild(int key) async {
    await _buildsBox.delete(key);
    final artifactsKeys = _artifactsBox.values.where((el) => el.buildItemKey == key).map((e) => e.key as int).toList();
    if (artifactsKeys.isNotEmpty) {
      await _artifactsBox.deleteAll(artifactsKeys);
    }
  }

  CustomBuildModel _mapToCustomBuildModel(CustomBuild build, List<CustomBuildArtifact> artifacts) {
    final character = _genshinService.getCharacterForCard(build.characterKey);
    final weapons = build.weaponKeys.map((e) => _genshinService.getWeaponForCard(e)).toList();
    // final artifacts = build.artifactKeys.map((e) => _genshinService.getArtifactForCard(e)).toList();
    return CustomBuildModel(
      key: build.key as int,
      title: build.title,
      type: CharacterRoleType.values[build.roleType],
      subType: CharacterRoleSubType.values[build.roleSubType],
      showOnCharacterDetail: build.showOnCharacterDetail,
      character: character,
      weapons: weapons,
      //TODO: THIS
      artifacts: [],
    );
  }
}
