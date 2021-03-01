class ItemExperience {
  final int level;
  final int nextLevelExp;
  final int totalExp;
  final bool isForCharacter;

  bool get maxReached => level == -1;

  const ItemExperience.forCharacters(
    this.level,
    this.nextLevelExp,
    this.totalExp,
  ) : isForCharacter = true;

  const ItemExperience.forWeapons(
    this.level,
    this.nextLevelExp,
    this.totalExp,
  ) : isForCharacter = false;
}
