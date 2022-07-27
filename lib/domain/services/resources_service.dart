import 'package:shiori/domain/models/models.dart';

abstract class ResourceService {
  Future<bool> canCheckForUpdates();

  Future<CheckForUpdatesResult> checkForUpdates(String currentAppVersion, int currentResourcesVersion);

  Future<bool> downloadAndApplyUpdates(
    int targetResourceVersion,
    String? zipFileKeyName,
    String? jsonFileKeyName, {
    List<String> keyNames = const <String>[],
  });
}
