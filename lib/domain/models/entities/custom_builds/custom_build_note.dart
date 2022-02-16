import 'package:hive/hive.dart';

part 'custom_build_note.g.dart';

@HiveType(typeId: 20)
class CustomBuildNote extends HiveObject {
  @HiveField(0)
  final int buildItemKey;

  @HiveField(1)
  int index;

  @HiveField(2)
  String note;

  CustomBuildNote(this.buildItemKey, this.index, this.note);
}
