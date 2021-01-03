import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../common/assets.dart';

part 'element_debuff_file_model.freezed.dart';
part 'element_debuff_file_model.g.dart';

@freezed
abstract class ElementDebuffFileModel implements _$ElementDebuffFileModel {
  @late
  String get fullImagePath => Assets.getElementPath(image);

  factory ElementDebuffFileModel({
    @required String key,
    @required String image,
  }) = _ElementDebuffFileModel;

  ElementDebuffFileModel._();

  factory ElementDebuffFileModel.fromJson(Map<String, dynamic> json) => _$ElementDebuffFileModelFromJson(json);
}
