import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../common/assets.dart';
import '../../../common/enums/material_type.dart';

part 'talent_material_file_model.freezed.dart';
part 'talent_material_file_model.g.dart';

@freezed
abstract class TalentMaterialFileModel implements _$TalentMaterialFileModel {
  @late
  String get fullImagePath => Assets.getMaterialPath(image, type);

  factory TalentMaterialFileModel({
    @required String key,
    @required String image,
    @required bool isFromBoss,
    @required bool isForCharacters,
    @required MaterialType type,
    @required List<int> days,
  }) = _TalentMaterialFileModel;

  TalentMaterialFileModel._();

  factory TalentMaterialFileModel.fromJson(Map<String, dynamic> json) => _$TalentMaterialFileModelFromJson(json);
}
