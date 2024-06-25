import 'package:shiori/domain/models/dtos.dart';

typedef ProgressChanged = void Function(double, int);

abstract class ApiService {
  Future<String> getChangelog(String defaultValue);

  Future<ApiResponseDto<ResourceDiffResponseDto?>> checkForUpdates(String currentAppVersion, int currentResourcesVersion);

  Future<int?> downloadAsset(String keyName, String destPath);

  Future<ApiListResponseDto<GameCodeResponseDto>> getGameCodes(String appVersion, int currentResourcesVersion);
}
