import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'chart_ascension_stat_model.freezed.dart';

@freezed
class ChartAscensionStatModel with _$ChartAscensionStatModel {
  const factory ChartAscensionStatModel({
    required StatType type,
    required ItemType itemType,
    required int quantity,
  }) = _ChartAscensionStatModel;
}
