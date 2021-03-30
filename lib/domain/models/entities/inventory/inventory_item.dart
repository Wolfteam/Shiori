import 'package:hive/hive.dart';

part 'inventory_item.g.dart';

@HiveType(typeId: 4)
class InventoryItem extends HiveObject {
  @HiveField(0)
  final String itemKey;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  final int type;

  InventoryItem(this.itemKey, this.quantity, this.type);
}
