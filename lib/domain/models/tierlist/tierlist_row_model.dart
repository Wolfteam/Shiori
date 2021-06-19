import 'package:freezed_annotation/freezed_annotation.dart';

part 'tierlist_row_model.freezed.dart';

@freezed
class TierListRowModel with _$TierListRowModel {
  factory TierListRowModel.row({
    required String tierText,
    required int tierColor,
    required List<String> charImgs,
  }) = _Row;
}
