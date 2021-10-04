import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';

part 'tierlist_row_model.freezed.dart';

@freezed
class TierListRowModel with _$TierListRowModel {
  factory TierListRowModel.row({
    required String tierText,
    required int tierColor,
    required List<ItemCommon> items,
  }) = _Row;
}
