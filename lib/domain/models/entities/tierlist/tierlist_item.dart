import 'package:hive/hive.dart';

part 'tierlist_item.g.dart';

@HiveType(typeId: 7)
class TierListItem extends HiveObject {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final int color;

  @HiveField(2)
  final int position;

  @HiveField(3)
  final List<String> charsImgs;

  TierListItem(this.text, this.color, this.position, this.charsImgs);
}
