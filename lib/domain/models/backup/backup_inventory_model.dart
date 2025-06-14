import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_inventory_model.freezed.dart';
part 'backup_inventory_model.g.dart';

@freezed
abstract class BackupInventoryModel with _$BackupInventoryModel {
  const factory BackupInventoryModel({
    required String itemKey,
    required int quantity,
    required int type,
  }) = _BackupInventoryModel;

  factory BackupInventoryModel.fromJson(Map<String, dynamic> json) => _$BackupInventoryModelFromJson(json);
}
