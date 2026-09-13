import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/infrastructure/resource_archive_verifier.dart';

void main() {
  late Directory tempDir;

  setUp(() async => tempDir = await Directory.systemTemp.createTemp('shiori-verify'));

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<ArchiveManifest> writeFileAndManifest(String content, {String? corruptOnDisk}) async {
    final bytes = content.codeUnits;
    final file = File(p.join(tempDir.path, 'db', 'characters.json'));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(corruptOnDisk?.codeUnits ?? bytes);

    return ArchiveManifest(
      contractVersion: 2,
      version: 122,
      appVersion: '1.8.0',
      mode: 2,
      files: [
        ArchiveManifestFile(
          path: 'db/characters.json',
          size: bytes.length,
          sha256: sha256.convert(bytes).toString(),
        ),
      ],
    );
  }

  test('returns none when every file matches', () async {
    final manifest = await writeFileAndManifest('{"a":1}');

    final result = await ResourceArchiveVerifier.verifyExtracted(tempDir.path, manifest);

    expect(result, AppResourceUpdateFailureType.none);
  });

  test('returns manifestMismatch when a file hash differs', () async {
    //Same length, different bytes: exactly the case a size check could never catch
    final manifest = await writeFileAndManifest('{"a":1}', corruptOnDisk: '{"a":2}');

    final result = await ResourceArchiveVerifier.verifyExtracted(tempDir.path, manifest);

    expect(result, AppResourceUpdateFailureType.manifestMismatch);
  });

  test('returns manifestMismatch when a file is truncated', () async {
    final manifest = await writeFileAndManifest('{"a":1}', corruptOnDisk: '{"a"');

    final result = await ResourceArchiveVerifier.verifyExtracted(tempDir.path, manifest);

    expect(result, AppResourceUpdateFailureType.manifestMismatch);
  });

  test('returns manifestMismatch when a declared file is missing', () async {
    final manifest = await writeFileAndManifest('{"a":1}');
    await File(p.join(tempDir.path, 'db', 'characters.json')).delete();

    final result = await ResourceArchiveVerifier.verifyExtracted(tempDir.path, manifest);

    expect(result, AppResourceUpdateFailureType.manifestMismatch);
  });

  test('returns none for a manifest that declares no files', () async {
    final manifest = ArchiveManifest(
      contractVersion: 2,
      version: 122,
      appVersion: '1.8.0',
      mode: 2,
      files: [],
    );

    //An empty file list is not a verification failure; the backend never publishes an empty delta
    expect(await ResourceArchiveVerifier.verifyExtracted(tempDir.path, manifest), AppResourceUpdateFailureType.none);
  });
}
