import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/assets.dart';

part 'furniture_file_model.freezed.dart';
part 'furniture_file_model.g.dart';

@freezed
class FurnitureFileModel with _$FurnitureFileModel {
  String get fullImagePath => Assets.getFurniturePath(image);

  factory FurnitureFileModel({
    required String key,
    required int rarity,
    required String image,
  }) = _FurnitureFileModel;

  FurnitureFileModel._();

  factory FurnitureFileModel.fromJson(Map<String, dynamic> json) => _$FurnitureFileModelFromJson(json);
}
