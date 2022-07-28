import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

abstract class ResourceService {
  String getJsonFilePath(AppJsonFileType type, {AppLanguageType? language});

  Future<bool> canCheckForUpdates();

  Future<CheckForUpdatesResult> checkForUpdates(String currentAppVersion, int currentResourcesVersion);

  Future<bool> downloadAndApplyUpdates(
    int targetResourceVersion,
    String? zipFileKeyName,
    String? jsonFileKeyName, {
    List<String> keyNames = const <String>[],
  });
}
