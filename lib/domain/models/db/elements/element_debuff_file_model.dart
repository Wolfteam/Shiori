import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'element_debuff_file_model.freezed.dart';
part 'element_debuff_file_model.g.dart';

@freezed
abstract class ElementDebuffFileModel with _$ElementDebuffFileModel {
  String get fullImagePath => Assets.getElementPathFromType(type);

  factory ElementDebuffFileModel({
    required String key,
    required ElementType type,
  }) = _ElementDebuffFileModel;

  ElementDebuffFileModel._();

  factory ElementDebuffFileModel.fromJson(Map<String, dynamic> json) => _$ElementDebuffFileModelFromJson(json);
}
