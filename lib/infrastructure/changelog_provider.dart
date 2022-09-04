import 'package:shiori/domain/services/api_service.dart';
import 'package:shiori/domain/services/changelog_provider.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/network_service.dart';

const _defaultChangelog = '''
### Changelog
#### NA
''';

class ChangelogProviderImpl implements ChangelogProvider {
  final LoggingService _loggingService;
  final NetworkService _networkService;
  final ApiService _apiService;

  static const String defaultChangelog = _defaultChangelog;

  ChangelogProviderImpl(this._loggingService, this._networkService, this._apiService);

  @override
  Future<String> load() async {
    try {
      if (!await _networkService.isInternetAvailable()) {
        return _defaultChangelog;
      }

      return await _apiService.getChangelog(_defaultChangelog);
    } catch (e, s) {
      _loggingService.error(runtimeType, 'Unknown error occurred while loading changelog', e, s);
      return _defaultChangelog;
    }
  }
}
