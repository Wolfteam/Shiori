import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/db/gadgets/gadget_file_model.dart';

part 'gadgets_file.freezed.dart';
part 'gadgets_file.g.dart';

@freezed
class GadgetsFile with _$GadgetsFile {
  factory GadgetsFile({
    required List<GadgetFileModel> gadgets,
  }) = _GadgetsFile;

  GadgetsFile._();

  factory GadgetsFile.fromJson(Map<String, dynamic> json) => _$GadgetsFileFromJson(json);
}
