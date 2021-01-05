import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../common/assets.dart';

part 'element_reaction_file_model.freezed.dart';
part 'element_reaction_file_model.g.dart';

@freezed
abstract class ElementReactionFileModel implements _$ElementReactionFileModel {
  @late
  List<String> get principalImages => principal.map((e) => Assets.getElementPath(e)).toList();

  @late
  List<String> get secondaryImages => secondary.map((e) => Assets.getElementPath(e)).toList();

  @late
  bool get hasImages => principal.isNotEmpty && secondary.isNotEmpty;

  factory ElementReactionFileModel({
    @required String key,
    @required List<String> principal,
    @required List<String> secondary,
  }) = _ElementReactionFileModel;

  ElementReactionFileModel._();

  factory ElementReactionFileModel.fromJson(Map<String, dynamic> json) => _$ElementReactionFileModelFromJson(json);
}
