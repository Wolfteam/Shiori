import 'package:dio/dio.dart';
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
        _loggingService.warning(
          runtimeType,
          'getChangelog: Could not retrieve changelog, got status code = ${response.statusCode}, falling back to the default one',
        );
        return defaultValue;
      }

      return response.data!;
    } catch (e, s) {
      _loggingService.error(runtimeType, 'getChangelog: Unknown error occurred', e, s);
      return defaultValue;
    }
  }
}
