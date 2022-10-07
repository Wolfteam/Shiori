import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/dtos.dart';
import 'package:shiori/domain/services/api_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/env.dart';

class ApiServiceImpl implements ApiService {
  final LoggingService _loggingService;

  final _dio = Dio();
  late final HttpClient _httpClient;

  ApiServiceImpl(this._loggingService) {
    final sc = SecurityContext.defaultContext;
    final publicKeyBytes = utf8.encode(utf8.decode(base64.decode(Env.publicKey)));
    final privateKeyBytes = utf8.encode(utf8.decode(base64.decode(Env.privateKey)));
    sc.useCertificateChainBytes(publicKeyBytes);
    sc.usePrivateKeyBytes(privateKeyBytes);
    _httpClient = HttpClient(context: sc);

    final adapter = _dio.httpClientAdapter as DefaultHttpClientAdapter;
    adapter.onHttpClientCreate = (client) => _httpClient;
  }

  @override
  Future<String> getChangelog(String defaultValue) async {
    try {
      const url = '${Env.assetsBaseUrl}/changelog.md';
      final response = await _dio.getUri<String>(Uri.parse(url), options: Options(headers: _getCommonApiHeaders()));
      if (response.statusCode != 200) {
        _loggingService.warning(
          runtimeType,
          'getChangelog: Could not retrieve changelog, got status code = ${response.statusCode}, falling back to the default one',
        );
        return defaultValue;
      }

      return response.data!;
    } catch (e, s) {
      _handleError('getChangelog', e, s);
      return defaultValue;
    }
  }

  @override
  Future<ApiResponseDto<ResourceDiffResponseDto?>> checkForUpdates(String currentAppVersion, int currentResourcesVersion) async {
    try {
      String url = '${Env.apiBaseUrl}/api/resources/diff?AppVersion=$currentAppVersion';
      if (currentResourcesVersion > 0) {
        url += '&CurrentVersion=$currentResourcesVersion';
      }

      final response = await _dio.getUri<String>(Uri.parse(url), options: Options(headers: _getApiHeaders()));
      final json = jsonDecode(response.data!) as Map<String, dynamic>;
      final apiResponse = ApiResponseDto.fromJson(
        json,
        (data) => data == null ? null : ResourceDiffResponseDto.fromJson(data as Map<String, dynamic>),
      );
      return apiResponse;
    } catch (e, s) {
      _handleError('checkForUpdates', e, s);
      rethrow;
    }
  }

  @override
  Future<bool> downloadAsset(String keyName, String destPath, ProgressChanged? onProgress) async {
    try {
      // _loggingService.debug(runtimeType, '_downloadFile: Downloading file = $keyName...');
      final url = '${Env.assetsBaseUrl}/$keyName';

      await _dio.downloadUri(
        Uri.parse(url),
        destPath,
        options: Options(headers: _getCommonApiHeaders()),
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
      _handleError('downloadAsset', e, s);
      return false;
    }
  }

  Map<String, String> _getApiHeaders() {
    final headers = {Env.apiHeaderName: Env.apiHeaderValue};
    headers.addAll(_getCommonApiHeaders());
    return headers;
  }

  Map<String, String> _getCommonApiHeaders() => {Env.commonHeaderName: 'true'};

  void _handleError(String caller, Object e, StackTrace s) {
    if (e is DioError) {
      final msg = 'Type = ${e.type} - SC = ${e.response?.statusCode ?? na} - Msg = ${e.response?.statusMessage ?? na}';
      _loggingService.error(runtimeType, '$caller: Dio error = $msg');
      if (e.message.isNotNullEmptyOrWhitespace) {
        _loggingService.error(runtimeType, '$caller: Dio error = ${e.message}');
      }
      if (e.error != null || e.stackTrace != null) {
        _loggingService.error(runtimeType, '$caller: Dio error = ${e.error ?? na} - ST = ${e.stackTrace ?? na}', e.error, e.stackTrace);
      }
    } else {
      _loggingService.error(runtimeType, '$caller: Unknown api error', e, s);
    }
  }
}
