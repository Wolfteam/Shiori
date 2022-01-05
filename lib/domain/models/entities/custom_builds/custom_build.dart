import 'package:hive/hive.dart';

part 'custom_build.g.dart';

@HiveType(typeId: 18)
class CustomBuild extends HiveObject {
  @HiveField(1)
  final String characterKey;

  @HiveField(2)
  String title;

  @HiveField(3)
  int roleType;

  @HiveField(4)
  int roleSubType;

  @HiveField(5)
  bool showOnCharacterDetail;

  @HiveField(6)
  List<String> weaponKeys;

  @HiveField(7)
  List<int> talentPriority;

  CustomBuild(
    this.characterKey,
    this.showOnCharacterDetail,
    this.title,
    this.roleType,
    this.roleSubType,
    this.weaponKeys,
    this.talentPriority,
  );
}
