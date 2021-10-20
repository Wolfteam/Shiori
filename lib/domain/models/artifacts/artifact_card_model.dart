import 'package:freezed_annotation/freezed_annotation.dart';

part 'artifact_card_model.freezed.dart';

@freezed
class ArtifactCardModel with _$ArtifactCardModel {
  const factory ArtifactCardModel({
    required String key,
    required String name,
    required String image,
    required int rarity,
    required List<ArtifactCardBonusModel> bonus,
  }) = _ArtifactCardModel;
}

@freezed
class ArtifactCardBonusModel with _$ArtifactCardBonusModel {
  const factory ArtifactCardBonusModel({
    required int pieces,
    required String bonus,
  }) = _ArtifactCardBonusModel;
}
