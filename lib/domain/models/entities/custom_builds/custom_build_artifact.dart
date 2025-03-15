import 'package:hive_ce/hive.dart';
import 'package:shiori/domain/models/entities/base_entity.dart';

part 'custom_build_artifact.g.dart';

@HiveType(typeId: 19)
class CustomBuildArtifact extends BaseEntity {
  @HiveField(0)
  final int buildItemKey;

  @HiveField(1)
  String itemKey;

  @HiveField(2)
  int type;

  @HiveField(3)
  int statType;

  @HiveField(4)
  List<int> subStats;

  CustomBuildArtifact(this.buildItemKey, this.itemKey, this.type, this.statType, this.subStats);
}
