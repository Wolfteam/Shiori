import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../common/assets.dart';

part 'artifact_file_model.freezed.dart';
part 'artifact_file_model.g.dart';

@freezed
abstract class ArtifactFileModel implements _$ArtifactFileModel {
  @late
  String get fullImagePath => Assets.getArtifactPath(image);

  factory ArtifactFileModel({
    @required String key,
    @required String image,
    @required int rarityMin,
    @required int rarityMax,
  }) = _ArtifactFileModel;

  ArtifactFileModel._();

  factory ArtifactFileModel.fromJson(Map<String, dynamic> json) => _$ArtifactFileModelFromJson(json);
}
