import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

abstract class CustomBuildsDataService {
  //TODO: THESE 2 METHODS ARE COMMON IN ALL THE SERVICES
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
    bool isRecommended,
    List<CustomBuildNoteModel> notes,
    List<CustomBuildWeaponModel> weapons,
    List<CustomBuildArtifactModel> artifacts,
    List<CustomBuildTeamCharacterModel> teamCharacters,
    List<CharacterSkillType> talentPriority,
  );

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
    List<CharacterSkillType> talentPriority,
  );

  Future<void> deleteCustomBuild(int key);

  List<CharacterBuildCardModel> getCustomBuildsForCharacter(String charKey);
}
