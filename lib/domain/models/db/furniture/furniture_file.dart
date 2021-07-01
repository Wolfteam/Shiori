import 'package:freezed_annotation/freezed_annotation.dart';

import 'furniture_file_model.dart';

part 'furniture_file.freezed.dart';
part 'furniture_file.g.dart';

@freezed
class FurnitureFile with _$FurnitureFile {
  factory FurnitureFile({
    required List<FurnitureFileModel> furniture,
  }) = _FurnitureFile;

  FurnitureFile._();

  factory FurnitureFile.fromJson(Map<String, dynamic> json) => _$FurnitureFileFromJson(json);
}
