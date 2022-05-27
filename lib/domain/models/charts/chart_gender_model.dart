import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'chart_gender_model.freezed.dart';

@freezed
class ChartGenderModel with _$ChartGenderModel {
  const factory ChartGenderModel({
    required int maleCount,
    required int femaleCount,
    required int maxCount,
    required RegionType regionType,
  }) = _ChartGenderModel;
}
