import 'package:hive/hive.dart';

part 'custom_build_team_character.g.dart';

@HiveType(typeId: 21)
class CustomBuildTeamCharacter extends HiveObject {
  @HiveField(0)
  final int buildItemKey;

  @HiveField(1)
  int index;

  @HiveField(2)
  String characterKey;

  @HiveField(3)
  int roleType;

  @HiveField(4)
  int subType;

  CustomBuildTeamCharacter(this.buildItemKey, this.index, this.characterKey, this.roleType, this.subType);
}
