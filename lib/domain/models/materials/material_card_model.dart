import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/material_type.dart';
import 'package:shiori/domain/models/models.dart';

part 'material_card_model.freezed.dart';

@freezed
abstract class MaterialCardModel with _$MaterialCardModel implements SortableGroupedMaterial {
  @Implements<SortableGroupedMaterial>()
  const factory MaterialCardModel.item({
    required String key,
    required String name,
    required int rarity,
    required int position,
    required String image,
    required MaterialType type,
    required double level,
    required bool hasSiblings,
    @Default(0) int quantity,
    @Default(0) int usedQuantity,
  }) = _Item;
}
