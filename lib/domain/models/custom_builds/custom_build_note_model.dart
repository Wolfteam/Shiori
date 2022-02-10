import 'package:freezed_annotation/freezed_annotation.dart';

part 'custom_build_note_model.freezed.dart';

@freezed
class CustomBuildNoteModel with _$CustomBuildNoteModel {
  const factory CustomBuildNoteModel({
    required int index,
    required String note,
  }) = _CustomBuildNoteModel;
}
