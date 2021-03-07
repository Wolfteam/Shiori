class ItemExperienceModel {
  final int level;
  final double nextLevelExp;
  final double totalExp;
  final bool isForCharacter;

  bool get maxReached => level == -1;

  const ItemExperienceModel.forCharacters(
    this.level,
    this.nextLevelExp,
    this.totalExp,
  ) : isForCharacter = true;

  const ItemExperienceModel.forWeapons(
    this.level,
    this.nextLevelExp,
    this.totalExp,
  ) : isForCharacter = false;
}
