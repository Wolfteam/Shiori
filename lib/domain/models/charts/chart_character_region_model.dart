import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'chart_character_region_model.freezed.dart';

@freezed
class ChartCharacterRegionModel with _$ChartCharacterRegionModel {
  const factory ChartCharacterRegionModel({
    required RegionType regionType,
    required int quantity,
  }) = _ChartCharacterRegionModel;
}
