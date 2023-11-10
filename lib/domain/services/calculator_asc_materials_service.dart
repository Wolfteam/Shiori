import 'package:shiori/domain/models/models.dart';

abstract class CalculatorAscMaterialsService {
  List<AscensionMaterialsSummary> generateSummary(List<ItemAscensionMaterialModel> current);

  List<ItemAscensionMaterialModel> getAllCharacterPossibleMaterialsToUse(CharacterFileModel char);

  List<ItemAscensionMaterialModel> getAllWeaponPossibleMaterialsToUse(WeaponFileModel weapon);

  List<String> getAllPossibleMaterialKeysToUse(String itemKey, bool isCharacter);

  List<ItemAscensionMaterialModel> getCharacterMaterialsToUse(
    CharacterFileModel char,
    int currentLevel,
    int desiredLevel,
    int currentAscensionLevel,
    int desiredAscensionLevel,
    List<CharacterSkill> skills, {
    bool sort = true,
    bool ignoreSkillLevel = false,
  });

  List<ItemAscensionMaterialModel> getWeaponMaterialsToUse(
    WeaponFileModel weapon,
    int currentLevel,
    int desiredLevel,
    int currentAscensionLevel,
    int desiredAscensionLevel, {
    bool sort = true,
  });

  /// Gets the closest ascension level [toItemLevel]
  ///
  /// Keep in mind that you can be of level 80 but that doesn't mean you have ascended to level 6,
  /// that's why this method checks if the provided [toItemLevel] is valid for [ascensionLevel]
  int getClosestAscensionLevelFor(int toItemLevel, int ascensionLevel);

  /// Gets the closest ascension level [toItemLevel]
  ///
  /// Keep in mind that you can be of level 80 but that doesn't mean you have ascended to level 6,
  /// that's why you must provide [isAscended]
  int getClosestAscensionLevel(int toItemLevel, bool isAscended);

  /// Gets the right item level to use by checking the provided [currentAscensionLevel]
  /// and the [currentItemLevel]
  int getItemLevelToUse(int currentAscensionLevel, int currentItemLevel);

  /// Gets the right skill level to use by checking the provided [forAscensionLevel]
  /// and the [currentSkillLevel]
  int getSkillLevelToUse(int forAscensionLevel, int currentSkillLevel);

  /// Checks if the [currentLevel] is valid according to the provided [ascensionLevel]
  bool isLevelValidForAscensionLevel(int currentLevel, int ascensionLevel);

  /// This method checks if the provided skills are enabled or not.
  ///
  /// Keep in mind that the values provided  must be already validated
  ///
  /// Returns a tuple with 4 boolean items, the first two represent the [currentLevel] (decrement and increment respectively)
  /// and the last two represent the [desiredLevel] (increment and decrement respectively)
  (bool, bool, bool, bool) isSkillEnabled(
    int currentLevel,
    int desiredLevel,
    int currentAscensionLevel,
    int desiredAscensionLevel,
    int minSkillLevel,
    int maxSkillLevel,
  );
}
