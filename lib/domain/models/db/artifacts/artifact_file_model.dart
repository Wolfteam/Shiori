import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../assets.dart';

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
    @required List<ArtifactFileBonusModel> bonus,
  }) = _ArtifactFileModel;

  ArtifactFileModel._();

  factory ArtifactFileModel.fromJson(Map<String, dynamic> json) => _$ArtifactFileModelFromJson(json);
}

@freezed
abstract class ArtifactFileBonusModel implements _$ArtifactFileBonusModel {
  factory ArtifactFileBonusModel({
    @required String key,
    @required int pieces,
  }) = _ArtifactFileBonusModel;

  ArtifactFileBonusModel._();

  factory ArtifactFileBonusModel.fromJson(Map<String, dynamic> json) => _$ArtifactFileBonusModelFromJson(json);
}
