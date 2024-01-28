import 'package:hive/hive.dart';
import 'package:shiori/domain/models/entities/base_entity.dart';

part 'tierlist_item.g.dart';

@HiveType(typeId: 7)
class TierListItem extends BaseEntity {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final int color;

  @HiveField(2)
  final int position;

  @HiveField(3)
  final List<String> charKeys;

  TierListItem(this.text, this.color, this.position, this.charKeys);
}
