import '../../enums/ascension_material_summary_type.dart';
import '../../enums/material_type.dart';

class AscensionMaterialsSummary {
  final AscensionMaterialSummaryType type;
  final List<MaterialSummary> materials;

  const AscensionMaterialsSummary({
    required this.type,
    required this.materials,
  });
}

class MaterialSummary {
  final String key;
  final MaterialType materialType;
  final String fullImagePath;
  final int quantity;
  final List<int> days;

  const MaterialSummary({
    required this.key,
    required this.materialType,
    required this.fullImagePath,
    required this.quantity,
    required this.days,
  });
}
