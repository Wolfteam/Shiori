typedef ProgressChanged = void Function(double);

abstract class ApiService {
  Future<String> getChangelog(String defaultValue);
}
