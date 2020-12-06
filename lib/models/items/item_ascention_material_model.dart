import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/assets.dart';
import '../../common/enums/material_type.dart';

part 'item_ascention_material_model.freezed.dart';
part 'item_ascention_material_model.g.dart';

@freezed
abstract class ItemAscentionMaterialModel implements _$ItemAscentionMaterialModel {
  String get fullImagePath => Assets.getMaterialPath(image, materialType);

  factory ItemAscentionMaterialModel({
    @required MaterialType materialType,
    @required String image,
    @required int quantity,
  }) = _ItemAscentionMaterialModel;

  const ItemAscentionMaterialModel._();

  factory ItemAscentionMaterialModel.fromJson(Map<String, dynamic> json) => _$ItemAscentionMaterialModelFromJson(json);
}
