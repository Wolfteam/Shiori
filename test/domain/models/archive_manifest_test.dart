import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/models/models.dart';

void main() {
  Map<String, dynamic> manifestJson({int contractVersion = 2}) => {
    'contractVersion': contractVersion,
    'version': 122,
    'appVersion': '1.8.0',
    'mode': 2,
    'files': [
      {'path': 'db/characters.json', 'size': 284113, 'sha256': '9f2a'},
    ],
    'deleted': ['skills/old_char_c1.webp'],
  };

  test('parses a contract 2 manifest', () {
    final manifest = ArchiveManifest.fromJson(manifestJson());

    expect(manifest.version, 122);
    expect(manifest.mode, 2);
    expect(manifest.files.single.path, 'db/characters.json');
    expect(manifest.files.single.sha256, '9f2a');
    expect(manifest.deleted, ['skills/old_char_c1.webp']);
    expect(manifest.isSupported, isTrue);
  });

  test('a manifest from a newer contract is not supported', () {
    final manifest = ArchiveManifest.fromJson(manifestJson(contractVersion: 3));

    expect(manifest.isSupported, isFalse);
  });

  test('a manifest without a deleted list parses as empty', () {
    final json = manifestJson()..remove('deleted');

    expect(ArchiveManifest.fromJson(json).deleted, isEmpty);
  });
}
