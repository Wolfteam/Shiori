import 'package:hive_ce/hive.dart';
import 'package:shiori/domain/models/entities/base_entity.dart';

part 'inventory_used_item.g.dart';

@HiveType(typeId: 5)
class InventoryUsedItem extends BaseEntity {
  @HiveField(0)
  final int calculatorItemKey;

  @HiveField(1)
  final String itemKey;

  @HiveField(2)
  int usedQuantity;

  @HiveField(3)
  final int type;

  InventoryUsedItem(this.calculatorItemKey, this.itemKey, this.usedQuantity, this.type);
}
