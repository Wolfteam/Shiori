import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../common/assets.dart';
import '../../../common/enums/material_type.dart';

part 'material_file_model.freezed.dart';
part 'material_file_model.g.dart';

@freezed
abstract class MaterialFileModel implements _$MaterialFileModel {
  @late
  String get fullImagePath => Assets.getMaterialPath(image, type);

  factory MaterialFileModel({
    @required String key,
    @required String image,
    @required bool isFromBoss,
    @required bool isForCharacters,
    @required MaterialType type,
    @required List<int> days,
    @required int level,
  }) = _MaterialFileModel;

  MaterialFileModel._();

  factory MaterialFileModel.fromJson(Map<String, dynamic> json) => _$MaterialFileModelFromJson(json);
}
