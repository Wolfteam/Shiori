import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

part 'item_ascension_material_model.freezed.dart';

@freezed
class ItemAscensionMaterialModel with _$ItemAscensionMaterialModel implements SortableGroupedMaterial {
  @Implements<SortableGroupedMaterial>()
  const factory ItemAscensionMaterialModel({
    required String key,
    required MaterialType type,
    required int requiredQuantity,
    required int availableQuantity,
    required int remainingQuantity,
    required String image,
    required int rarity,
    required int position,
    required double level,
    required bool hasSiblings,
  }) = _ItemAscensionMaterialModel;

  factory ItemAscensionMaterialModel.fromMaterial(
    int requiredQuantity,
    MaterialFileModel material,
    String imagePath, {
    int availableQuantity = 0,
    int remainingQuantity = 0,
  }) {
    return ItemAscensionMaterialModel(
      key: material.key,
      requiredQuantity: requiredQuantity,
      availableQuantity: availableQuantity,
      remainingQuantity: remainingQuantity,
      type: material.type,
      level: material.level,
      position: material.position,
      rarity: material.rarity,
      hasSiblings: material.hasSiblings,
      image: imagePath,
    );
  }
}
