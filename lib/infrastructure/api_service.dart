import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shiori/domain/models/dtos.dart';
import 'package:shiori/domain/services/api_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/infrastructure/secrets.dart';

class ApiServiceImpl implements ApiService {
  final LoggingService _loggingService;

  final _dio = Dio();

  ApiServiceImpl(this._loggingService);

  @override
  Future<String> getChangelog(String defaultValue) async {
    try {
      final url = '${Secrets.assetsBaseUrl}/changelog.md';
      final response = await _dio.getUri<String>(Uri.parse(url));
      if (response.statusCode != 200) {
        return defaultValue;
      }

      return response.data!;
    } catch (e, s) {
      _loggingService.error(runtimeType, 'getChangelog: Unknown error occurred', e, s);
      return defaultValue;
    }
  }

  @override
  Future<ApiResponseDto<ResourceDiffResponseDto?>> checkForUpdates(String currentAppVersion, int currentResourcesVersion) async {
    try {
      String url = '${Secrets.apiBaseUrl}/api/resources/diff?AppVersion=$currentAppVersion';
      if (currentResourcesVersion > 0) {
        url += '&CurrentResourceVersion=$currentResourcesVersion';
      }

      final response = await _dio.getUri<String>(Uri.parse(url));
      final json = jsonDecode(response.data!) as Map<String, dynamic>;
      final apiResponse = ApiResponseDto.fromJson(
        json,
        (data) => data == null ? null : ResourceDiffResponseDto.fromJson(data as Map<String, dynamic>),
      );
      return apiResponse;
    } catch (e, s) {
      _loggingService.error(runtimeType, 'checkForUpdates: Unknown error', e, s);
      rethrow;
    }
  }

  @override
  Future<bool> downloadAsset(String keyName, String destPath, ProgressChanged? onProgress) async {
    try {
      // _loggingService.debug(runtimeType, '_downloadFile: Downloading file = $keyName...');
      final url = '${Secrets.assetsBaseUrl}/$keyName';

      await _dio.downloadUri(
        Uri.parse(url),
        destPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total * 100;
            onProgress?.call(progress);
          }
        },
      );
      // _loggingService.debug(runtimeType, '_downloadFile: File = $keyName was successfully downloaded');
      return true;
    } catch (e, s) {
      _loggingService.error(runtimeType, 'downloadAsset: Unknown error', e, s);
      return false;
    }
  }
}
