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
      if (response.statusCode != 200) {
        _loggingService.warning(
          runtimeType,
          'getChangelog: Could not retrieve changelog, got status code = ${response.statusCode}, falling back to the default one',
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
      String url = '${Env.apiBaseUrl}/api/resources/diff?AppVersion=$currentAppVersion';
      if (currentResourcesVersion > 0) {
        url += '&CurrentVersion=$currentResourcesVersion';
      }

      final response = await _httpClient.get(Uri.parse(url), headers: _getApiHeaders());
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        _loggingService.warning(
          runtimeType,
          'checkForUpdates: Could not retrieve changelog, got status code = ${response.statusCode}',
        );
      }

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
  Future<bool> downloadAsset(String keyName, String destPath) async {
    try {
      // _loggingService.debug(runtimeType, '_downloadFile: Downloading file = $keyName...');
      final file = File(destPath);
      if (await file.exists()) {
        await file.delete();
      }

      final url = '${Env.assetsBaseUrl}/$keyName';
      final response = await _httpClient.get(Uri.parse(url), headers: _getCommonApiHeaders());
      if (response.statusCode != 200) {
        _loggingService.warning(
          runtimeType,
          'downloadAsset: Got status code = ${response.statusCode}. RP = ${response.reasonPhrase ?? na}',
        );
        return false;
      }

      await file.writeAsBytes(response.bodyBytes);
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

  Map<String, String> _getCommonApiHeaders() => {
        Env.commonHeaderName: 'true',
        'x-shiori-os': Platform.operatingSystem,
      };

  void _handleError(String caller, Object e, StackTrace s) {
    if (e is http.ClientException) {
      if (e.message.isNotNullEmptyOrWhitespace) {
        _loggingService.error(runtimeType, '$caller: HTTP error = ${e.message}');
      }
    } else {
      _loggingService.error(runtimeType, '$caller: Unknown api error', e, s);
    }
  }
}
