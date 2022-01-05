import 'package:hive/hive.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'custom_build_artifact.g.dart';

@HiveType(typeId: 19)
class CustomBuildArtifact extends HiveObject {
  @HiveField(0)
  final int buildItemKey;

  @HiveField(1)
  String itemKey;

  @HiveField(2)
  ArtifactType type;

  @HiveField(3)
  StatType statType;

  CustomBuildArtifact(this.buildItemKey, this.itemKey, this.type, this.statType);
}
