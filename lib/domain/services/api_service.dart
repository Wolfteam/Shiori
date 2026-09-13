import 'package:shiori/domain/models/dtos.dart';

typedef ProgressChanged = void Function(double, int);

abstract class ApiService {
  Future<String> getChangelog(String defaultValue);

  Future<ApiResponseDto<ResourceDiffResponseDto?>> checkForUpdates(String currentAppVersion, int currentResourcesVersion);

  Future<int?> downloadAsset(String keyName, String destPath);

  /// Downloads an asset writing it to disk as the bytes arrive, returning how many were written or
  /// null on failure. Resource archives reach 150+ MB, which cannot be buffered in memory.
  Future<int?> downloadAssetStreamed(
    String keyName,
    String destPath, {
    String? overrideUrl,
    void Function(int receivedBytes, int? totalBytes)? onBytes,
  });

  Future<ApiListResponseDto<GameCodeResponseDto>> getGameCodes(String appVersion, int currentResourcesVersion);

  Future<EmptyResponseDto> sendTelemetryData(SaveAppLogsRequestDto request);

  Future<EmptyResponseDto> registerDeviceToken(RegisterDeviceTokenRequestDto dto);
}
