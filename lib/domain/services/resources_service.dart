import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/api_service.dart';

abstract class ResourceService {
  Future<void> init();

  String getJsonFilePath(AppJsonFileType type, {AppLanguageType? language});

  String getArtifactImagePath(String filename);

  String getCharacterImagePath(String filename);

  String getCharacterFullImagePath(String filename);

  String getFurnitureImagePath(String filename);

  String getGadgetImagePath(String filename);

  String getMonsterImagePath(String filename);

  String getSkillImagePath(String? filename);

  String getWeaponImagePath(String filename, WeaponType type);

  String getMaterialImagePath(String filename, MaterialType type);

  String getWishBannerHistoryImagePath(String filename);

  String getCharacterIconImagePath(String filename);

  Future<CheckForUpdatesResult> checkForUpdates(
    String currentAppVersion,
    int currentResourcesVersion, {
    bool updateResourceCheckedDate = true,
  });

  Future<bool> downloadAndApplyUpdates(
    int targetResourceVersion,
    String? jsonFileKeyName, {
    List<String> keyNames = const <String>[],
    ProgressChanged? onProgress,
  });
}
