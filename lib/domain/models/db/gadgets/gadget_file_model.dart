import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/models/models.dart';

part 'gadget_file_model.freezed.dart';
part 'gadget_file_model.g.dart';

@freezed
class GadgetFileModel with _$GadgetFileModel {
  String get fullImagePath => Assets.getGadgetPath(image);

  Duration? get cooldownDuration => cooldown == null ? null : Duration(hours: cooldown!);

  factory GadgetFileModel({
    required String key,
    required int rarity,
    required String image,
    required List<ObtainedFromFileModel> obtainedFrom,
    @Default(null) int? cooldown,
  }) = _GadgetFileModel;

  GadgetFileModel._();

  factory GadgetFileModel.fromJson(Map<String, dynamic> json) => _$GadgetFileModelFromJson(json);
}
