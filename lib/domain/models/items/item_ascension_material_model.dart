import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../assets.dart';
import '../../enums/material_type.dart';

part 'item_ascension_material_model.freezed.dart';
part 'item_ascension_material_model.g.dart';

@freezed
abstract class ItemAscensionMaterialModel implements _$ItemAscensionMaterialModel {
  String get fullImagePath => Assets.getMaterialPath(image, materialType);

  factory ItemAscensionMaterialModel({
    @required MaterialType materialType,
    @required String image,
    @required int quantity,
  }) = _ItemAscensionMaterialModel;

  const ItemAscensionMaterialModel._();

  factory ItemAscensionMaterialModel.fromJson(Map<String, dynamic> json) => _$ItemAscensionMaterialModelFromJson(json);
}
