import 'package:freezed_annotation/freezed_annotation.dart';

part 'tierlist_row_model.freezed.dart';

@freezed
abstract class TierListRowModel with _$TierListRowModel {
  factory TierListRowModel.row({
    String tierText,
    int tierColor,
    List<String> charImgs,
  }) = _Row;
}
