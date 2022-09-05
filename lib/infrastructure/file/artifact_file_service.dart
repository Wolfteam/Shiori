import 'package:collection/collection.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/artifact_file_service.dart';
import 'package:shiori/domain/services/file/translation_file_service.dart';
import 'package:shiori/domain/services/resources_service.dart';

class ArtifactFileServiceImpl extends ArtifactFileService {
  final ResourceService _resourceService;
  final TranslationFileService _translations;

  late ArtifactsFile _artifactsFile;

  @override
  ResourceService get resources => _resourceService;

  @override
  TranslationFileService get translations => _translations;

  ArtifactFileServiceImpl(this._resourceService, this._translations);

  @override
  Future<void> init(String assetPath) async {
    final json = await readJson(assetPath);
    _artifactsFile = ArtifactsFile.fromJson(json);
  }

  @override
  List<ArtifactCardModel> getArtifactsForCard({ArtifactType? type}) {
    return _artifactsFile.artifacts.map((e) => _toArtifactForCard(e, type: type)).where((e) {
      //if a type was provided and it is different that crown, then return only the ones with more than 1 bonus
      if (type != null && type != ArtifactType.crown) {
        return e.bonus.length > 1;
      }
      return true;
    }).toList();
  }

  @override
  ArtifactCardModel getArtifactForCard(String key) {
    final artifact = _artifactsFile.artifacts.firstWhere((a) => a.key == key);
    return _toArtifactForCard(artifact);
  }

  @override
  ArtifactFileModel getArtifact(String key) {
    return _artifactsFile.artifacts.firstWhere((a) => a.key == key);
  }

  @override
  List<ArtifactCardBonusModel> getArtifactBonus(TranslationArtifactFile translation) {
    final bonus = <ArtifactCardBonusModel>[];
    var pieces = translation.bonus.length == 2 ? 2 : 1;
    for (var i = 1; i <= translation.bonus.length; i++) {
      final item = ArtifactCardBonusModel(pieces: pieces, bonus: translation.bonus[i - 1]);
      bonus.add(item);
      pieces += 2;
    }
    return bonus;
  }

  @override
  List<String> getArtifactRelatedParts(String fullImagePath, String image, int bonus) {
    if (bonus == 1) {
      return [fullImagePath];
    }

    var imageWithoutExt = image.split(imageFileExtension).first;
    imageWithoutExt = imageWithoutExt.substring(0, imageWithoutExt.length - 1);
    return artifactOrder.map((e) => _resourceService.getArtifactImagePath('$imageWithoutExt$e$imageFileExtension')).toList();
  }

  @override
  String getArtifactRelatedPart(String fullImagePath, String image, int bonus, ArtifactType type) {
    if (bonus == 1 && type != ArtifactType.crown) {
      throw Exception('Invalid artifact type');
    }

    if (bonus == 1) {
      return fullImagePath;
    }

    final imgs = getArtifactRelatedParts(fullImagePath, image, bonus);
    final order = getArtifactOrder(type);
    return imgs.firstWhere((el) => el.endsWith('$order$imageFileExtension'));
  }

  @override
  List<StatType> generateSubStatSummary(List<CustomBuildArtifactModel> artifacts) {
    final weightMap = <StatType, int>{};

    for (final artifact in artifacts) {
      int weight = artifact.subStats.length;
      for (var i = 0; i < artifact.subStats.length; i++) {
        final subStat = artifact.subStats[i];
        final ifAbsent = weightMap.containsKey(subStat) ? i : weight;
        weightMap.update(subStat, (value) => value + weight, ifAbsent: () => ifAbsent);
        weight--;
      }
    }

    final sorted = weightMap.entries.sorted((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }

  ArtifactCardModel _toArtifactForCard(ArtifactFileModel artifact, {ArtifactType? type}) {
    final translation = _translations.getArtifactTranslation(artifact.key);
    final bonus = getArtifactBonus(translation);
    final imagePath = _resourceService.getArtifactImagePath(artifact.image);
    final mapped = ArtifactCardModel(
      key: artifact.key,
      name: translation.name,
      image: imagePath,
      rarity: artifact.maxRarity,
      bonus: bonus,
    );

    //only search for other images if the artifact has more than 1 bonus effect
    if (type != null && bonus.length > 1) {
      final img = getArtifactRelatedPart(imagePath, artifact.image, bonus.length, type);
      return mapped.copyWith.call(image: img);
    }

    return mapped;
  }
}
