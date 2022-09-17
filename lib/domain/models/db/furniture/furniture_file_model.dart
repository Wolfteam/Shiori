import 'package:freezed_annotation/freezed_annotation.dart';

part 'furniture_file_model.freezed.dart';
part 'furniture_file_model.g.dart';

@freezed
class FurnitureFileModel with _$FurnitureFileModel {
  factory FurnitureFileModel({
    required String key,
    required int rarity,
    required String image,
  }) = _FurnitureFileModel;

  FurnitureFileModel._();

  factory FurnitureFileModel.fromJson(Map<String, dynamic> json) => _$FurnitureFileModelFromJson(json);
}
