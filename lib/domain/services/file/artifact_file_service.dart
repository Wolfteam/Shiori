import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/base_file_service.dart';

abstract class ArtifactFileService implements BaseFileService {
  List<ArtifactCardModel> getArtifactsForCard({ArtifactType? type});

  ArtifactCardModel getArtifactForCard(String key);

  ArtifactFileModel getArtifact(String key);

  List<ArtifactCardBonusModel> getArtifactBonus(TranslationArtifactFile translation);

  List<String> getArtifactRelatedParts(String fullImagePath, String image, int bonus);

  String getArtifactRelatedPart(String fullImagePath, String image, int bonus, ArtifactType type);

  List<StatType> generateSubStatSummary(List<CustomBuildArtifactModel> artifacts);
}
