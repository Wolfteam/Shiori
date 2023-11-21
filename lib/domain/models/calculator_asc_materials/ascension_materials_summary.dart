import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

part 'ascension_materials_summary.freezed.dart';

@freezed
class AscensionMaterialsSummary with _$AscensionMaterialsSummary {
  const factory AscensionMaterialsSummary({
    required AscensionMaterialSummaryType type,
    required List<MaterialSummary> materials,
  }) = _AscensionMaterialsSummary;
}

@freezed
class MaterialSummary with _$MaterialSummary implements SortableGroupedMaterial {
  @Implements<SortableGroupedMaterial>()
  const factory MaterialSummary({
    required String key,
    required MaterialType type,
    required int rarity,
    required int position,
    required double level,
    required bool hasSiblings,
    required String fullImagePath,
    required int requiredQuantity,
    required int usedQuantity,
    required int remainingQuantity,
    required List<int> days,
  }) = _MaterialSummary;
}
