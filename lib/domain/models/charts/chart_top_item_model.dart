import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'chart_top_item_model.freezed.dart';

@freezed
class ChartTopItemModel with _$ChartTopItemModel {
  const factory ChartTopItemModel({
    required String key,
    required ChartType type,
    required String name,
    required int value,
    required double percentage,
  }) = _ChartTopItemModel;
}
