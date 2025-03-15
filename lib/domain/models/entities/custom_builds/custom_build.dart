import 'package:hive_ce/hive.dart';
import 'package:shiori/domain/models/entities/base_entity.dart';

part 'custom_build.g.dart';

@HiveType(typeId: 18)
class CustomBuild extends BaseEntity {
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
  List<int> skillPriorities;

  @HiveField(7)
  bool isRecommended;

  CustomBuild(this.characterKey, this.showOnCharacterDetail, this.title, this.roleType, this.roleSubType, this.skillPriorities, this.isRecommended);
}
