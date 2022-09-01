import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'chart_element_item_model.freezed.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class ChartElementItemModel with _$ChartElementItemModel {
  const factory ChartElementItemModel({
    required ElementType type,
    required List<Point<double>> points,
  }) = _ChartElementItemModel;
}
