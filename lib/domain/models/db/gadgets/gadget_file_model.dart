import 'package:freezed_annotation/freezed_annotation.dart';

part 'gadget_file_model.freezed.dart';
part 'gadget_file_model.g.dart';

@freezed
class GadgetFileModel with _$GadgetFileModel {
  Duration? get cooldownDuration => cooldown == null ? null : Duration(hours: cooldown!);

  factory GadgetFileModel({
    required String key,
    required int rarity,
    required String image,
    @Default(null) int? cooldown,
  }) = _GadgetFileModel;

  GadgetFileModel._();

  factory GadgetFileModel.fromJson(Map<String, dynamic> json) => _$GadgetFileModelFromJson(json);
}
