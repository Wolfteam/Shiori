import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/dtos.dart';
import 'package:shiori/domain/services/api_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/env.dart';

class _AppAgentClient extends http.BaseClient {
  late final IOClient _inner;

  _AppAgentClient() {
    final sc = SecurityContext.defaultContext;
    final publicKeyBytes = utf8.encode(utf8.decode(base64.decode(Env.publicKey)));
    final privateKeyBytes = utf8.encode(utf8.decode(base64.decode(Env.privateKey)));
    sc.useCertificateChainBytes(publicKeyBytes);
    sc.usePrivateKeyBytes(privateKeyBytes);
    try {
      //https://github.com/dart-lang/http/issues/627
      //The LetsEncrypt Intermediate CA R3 + ISRG Root CA X1
      final letsEncryptKeyBytes = utf8.encode(utf8.decode(base64.decode(Env.letsEncryptKey)));
      sc.setTrustedCertificatesBytes(letsEncryptKeyBytes);
    } catch (e) {
      //the cert may be already added
    }
    final httpClient = HttpClient(context: sc);
    _inner = IOClient(httpClient);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request);
  }
}

class ApiServiceImpl implements ApiService {
  final LoggingService _loggingService;
  final _AppAgentClient _httpClient;

  ApiServiceImpl(this._loggingService) : _httpClient = _AppAgentClient();

  @override
  Future<String> getChangelog(String defaultValue) async {
    try {
      const url = '${Env.assetsBaseUrl}/changelog.md';
      final response = await _httpClient.get(Uri.parse(url), headers: _getCommonApiHeaders());
      if (!_isSuccessStatusCode(response.statusCode)) {
        _loggingService.warning(
          runtimeType,
          'getChangelog: Got status code = ${response.statusCode}, falling back to the default one',
        );
        return defaultValue;
      }

      return response.body;
    } catch (e, s) {
      _handleError('getChangelog', e, s);
      return defaultValue;
    }
  }

  @override
  Future<ApiResponseDto<ResourceDiffResponseDto?>> checkForUpdates(String currentAppVersion, int currentResourcesVersion) async {
    try {
      final dto = GetResourceDiffRequestDto(
        appVersion: currentAppVersion,
        currentVersion: currentResourcesVersion > 0 ? currentResourcesVersion : null,
      );

      final url = Uri.parse(Env.apiBaseUrl).replace(path: 'api/resources/diff', queryParameters: _toQueryMap(dto.toJson()));

      final response = await _httpClient.get(url, headers: _getApiHeaders());
      if (!_isSuccessStatusCode(response.statusCode)) {
        _loggingService.warning(
          runtimeType,
          'checkForUpdates: Got status code = ${response.statusCode}. Body = ${response.body}',
        );
        return ApiResponseDto(succeed: false, message: 'Invalid status code = ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
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
  Future<int?> downloadAsset(String keyName, String destPath) async {
    try {
      // _loggingService.debug(runtimeType, '_downloadFile: Downloading file = $keyName...');
      final file = File(destPath);
      if (await file.exists()) {
        await file.delete();
      }

      final url = '${Env.assetsBaseUrl}/$keyName';
      final response = await _httpClient.get(Uri.parse(url), headers: _getCommonApiHeaders());

      if (!_isSuccessStatusCode(response.statusCode)) {
        _loggingService.warning(
          runtimeType,
          'downloadAsset: Got status code = ${response.statusCode}. RP = ${response.reasonPhrase ?? na}',
        );
        return null;
      }

      await file.writeAsBytes(response.bodyBytes);
      // _loggingService.debug(runtimeType, '_downloadFile: File = $keyName was successfully downloaded');
      return response.contentLength;
    } catch (e, s) {
      _handleError('downloadAsset', e, s);
      return null;
    }
  }

  @override
  Future<ApiListResponseDto<GameCodeResponseDto>> getGameCodes(String appVersion, int currentResourcesVersion) async {
    try {
      final dto = BaseRequestDto(appVersion: appVersion, currentVersion: currentResourcesVersion);
      final url = Uri.parse(Env.apiBaseUrl).replace(path: 'api/gamecodes', queryParameters: _toQueryMap(dto.toJson()));
      final response = await _httpClient.get(url, headers: _getApiHeaders());
      if (!_isSuccessStatusCode(response.statusCode)) {
        _loggingService.warning(
          runtimeType,
          'getGameCodes: Got status code = ${response.statusCode}. Body = ${response.body}',
        );
        return ApiListResponseDto(succeed: false, message: 'Invalid status code = ${response.statusCode}', result: []);
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiListResponseDto.fromJson(json, (data) => GameCodeResponseDto.fromJson(data! as Map<String, dynamic>));
      return apiResponse;
    } catch (e, s) {
      _handleError('getGameCodes', e, s);
      rethrow;
    }
  }

  @override
  Future<EmptyResponseDto> sendTelemetryData(SaveAppLogsRequestDto request) async {
    try {
      final url = Uri.parse(Env.apiBaseUrl).replace(path: 'app-logs');
      final headers = _getApiHeaders();
      _addJsonContentType(headers);
      final response = await _httpClient.post(url, headers: headers, body: jsonEncode(request));
      if (!_isSuccessStatusCode(response.statusCode)) {
        _loggingService.warning(
          runtimeType,
          'sendTelemetryData: Got status code = ${response.statusCode}. Body = ${response.body}',
        );
        return EmptyResponseDto(succeed: false, message: 'Invalid status code = ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final apiResponse = EmptyResponseDto.fromJson(json);
      return apiResponse;
    } catch (e, s) {
      _handleError('sendTelemetryData', e, s);
    }
    return const EmptyResponseDto(succeed: false, message: 'Unknown error');
  }

  Map<String, String> _getApiHeaders() {
    final headers = {Env.apiHeaderName: Env.apiHeaderValue};
    headers.addAll(_getCommonApiHeaders());
    return headers;
  }

  Map<String, String> _getCommonApiHeaders() => {
        Env.commonHeaderName: 'true',
        'x-shiori-os': Platform.operatingSystem,
      };

  void _addJsonContentType(Map<String, String> map) {
    map.putIfAbsent('Content-Type', () => 'application/json');
  }

  void _handleError(String caller, Object e, StackTrace s) {
    if (e is http.ClientException && e.message.isNotNullEmptyOrWhitespace) {
      _loggingService.error(runtimeType, '$caller: HTTP error = ${e.message}', e, s);
    } else {
      _loggingService.error(runtimeType, '$caller: Unknown api error', e, s);
    }
  }

  bool _isSuccessStatusCode(int code) {
    return code >= HttpStatus.ok && code <= 299;
  }

  Map<String, String?> _toQueryMap(Map<String, dynamic> map) {
    return {for (final kvp in map.entries) kvp.key: kvp.value?.toString()};
  }
}
