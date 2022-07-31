import 'package:http/http.dart' as http;
import 'package:shiori/domain/services/changelog_provider.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/infrastructure/secrets.dart';

const _defaultChangelog = '''
### Changelog
#### NA
''';

final _url = '${Secrets.assetsBaseUrl}/changelog.md';

class ChangelogProviderImpl implements ChangelogProvider {
  final LoggingService _loggingService;
  final NetworkService _networkService;

  @override
  String get defaultChangelog => _defaultChangelog;

  ChangelogProviderImpl(this._loggingService, this._networkService);

  @override
  Future<String> load() async {
    try {
      if (!await _networkService.isInternetAvailable()) {
        return _defaultChangelog;
      }
      final response = await http.Client().get(Uri.parse(_url));
      if (response.statusCode != 200) {
        return _defaultChangelog;
      }

      return response.body;
    } catch (e, s) {
      _loggingService.error(runtimeType, 'Unknown error occurred while loading changelog', e, s);
      return _defaultChangelog;
    }
  }
}
