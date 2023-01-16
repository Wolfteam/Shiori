import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_inventory_model.freezed.dart';
part 'backup_inventory_model.g.dart';

@freezed
class BackupInventoryModel with _$BackupInventoryModel {
  const factory BackupInventoryModel({
    required String itemKey,
    required int quantity,
    required int type,
  }) = _BackupInventoryModel;

  factory BackupInventoryModel.fromJson(Map<String, dynamic> json) => _$BackupInventoryModelFromJson(json);
}

@freezed
class BackupInventoryUsedItemModel with _$BackupInventoryUsedItemModel {
  const factory BackupInventoryUsedItemModel({
    required String itemKey,
    required int usedQuantity,
    required int type,
  }) = _BackupInventoryUsedItemModel;

  factory BackupInventoryUsedItemModel.fromJson(Map<String, dynamic> json) => _$BackupInventoryUsedItemModelFromJson(json);
}
