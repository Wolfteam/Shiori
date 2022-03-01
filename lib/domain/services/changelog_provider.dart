abstract class ChangelogProvider {
  String get defaultChangelog;

  Future<String> load();
}
