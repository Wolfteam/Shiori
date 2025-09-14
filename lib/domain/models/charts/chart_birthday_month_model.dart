import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/items/item_common.dart';

part 'chart_birthday_month_model.freezed.dart';

@freezed
abstract class ChartBirthdayMonthModel with _$ChartBirthdayMonthModel {
  const factory ChartBirthdayMonthModel({
    required int month,
    required List<ItemCommonWithName> items,
  }) = _ChartBirthdayMonthModel;
}
