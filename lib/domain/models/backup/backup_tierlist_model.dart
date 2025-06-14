import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_tierlist_model.freezed.dart';
part 'backup_tierlist_model.g.dart';

@freezed
abstract class BackupTierListModel with _$BackupTierListModel {
  const factory BackupTierListModel({
    required String text,
    required int color,
    required int position,
    required List<String> charKeys,
  }) = _BackupTierListModel;

  factory BackupTierListModel.fromJson(Map<String, dynamic> json) => _$BackupTierListModelFromJson(json);
}
