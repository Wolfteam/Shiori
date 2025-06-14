import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'item_ascension_material_file_model.freezed.dart';
part 'item_ascension_material_file_model.g.dart';

@freezed
abstract class ItemAscensionMaterialFileModel with _$ItemAscensionMaterialFileModel {
  factory ItemAscensionMaterialFileModel({
    required String key,
    required MaterialType type,
    required int quantity,
  }) = _ItemAscensionMaterialFileModel;

  const ItemAscensionMaterialFileModel._();

  factory ItemAscensionMaterialFileModel.fromJson(Map<String, dynamic> json) => _$ItemAscensionMaterialFileModelFromJson(json);
}
