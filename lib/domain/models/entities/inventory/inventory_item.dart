import 'package:hive/hive.dart';
import 'package:shiori/domain/models/entities/base_entity.dart';

part 'inventory_item.g.dart';

@HiveType(typeId: 4)
class InventoryItem extends BaseEntity {
  @HiveField(0)
  final String itemKey;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  final int type;

  InventoryItem(this.itemKey, this.quantity, this.type);
}
