import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

abstract class CustomBuildsDataService {
  Future<void> init();

  Future<void> deleteThemAll();

  List<CustomBuildModel> getAllCustomBuilds();

  CustomBuildModel getCustomBuild(int key);

  Future<CustomBuildModel> saveCustomBuild(
    String charKey,
    String title,
    CharacterRoleType type,
    CharacterRoleSubType subType,
    bool showOnCharacterDetail,
    List<String> weaponKeys,
    List<CustomBuildArtifactModel> artifacts,
    List<CharacterSkillType> talentPriority,
  );

  Future<CustomBuildModel> updateCustomBuild(
    int key,
    String title,
    CharacterRoleType type,
    CharacterRoleSubType subType,
    bool showOnCharacterDetail,
    List<String> weaponKeys,
    List<CustomBuildArtifactModel> artifacts,
    List<CharacterSkillType> talentPriority,
  );

  Future<void> deleteCustomBuild(int key);
}
