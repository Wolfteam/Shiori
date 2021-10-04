import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

part 'item_ascension_material_model.freezed.dart';

@freezed
class ItemAscensionMaterialModel with _$ItemAscensionMaterialModel {
  factory ItemAscensionMaterialModel({
    required String key,
    required MaterialType type,
    required int quantity,
    required String image,
  }) = _ItemAscensionMaterialModel;

  static ItemAscensionMaterialModel fromFile(ItemAscensionMaterialFileModel file, String image) {
    return ItemAscensionMaterialModel(
      key: file.key,
      quantity: file.quantity,
      type: file.type,
      image: image,
    );
  }
}
