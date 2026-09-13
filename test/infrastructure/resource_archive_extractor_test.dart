import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shiori/infrastructure/resource_archive_extractor.dart';

void main() {
  late Directory tempDir;

  setUp(() async => tempDir = await Directory.systemTemp.createTemp('shiori-extract'));

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  String buildArchive() {
    final archive = Archive();
    final manifest = utf8.encode(
      jsonEncode({
        'contractVersion': 2,
        'version': 122,
        'appVersion': '1.8.0',
        'mode': 2,
        'files': [
          {'path': 'db/characters.json', 'size': 2, 'sha256': 'ignored'},
        ],
        'deleted': <String>[],
      }),
    );
    archive.addFile(ArchiveFile('manifest.json', manifest.length, manifest));
    final content = utf8.encode('{}');
    archive.addFile(ArchiveFile('db/characters.json', content.length, content));

    final archivePath = p.join(tempDir.path, 'delta.zip');
    File(archivePath).writeAsBytesSync(ZipEncoder().encode(archive));
    return archivePath;
  }

  test('extract writes every entry to the destination directory', () async {
    final archivePath = buildArchive();
    final destPath = p.join(tempDir.path, 'out');

    await ResourceArchiveExtractor.extract(archivePath, destPath);

    expect(File(p.join(destPath, 'manifest.json')).existsSync(), isTrue);
    expect(File(p.join(destPath, 'db', 'characters.json')).readAsStringSync(), '{}');
  });

  test('readManifest parses the extracted manifest', () async {
    final archivePath = buildArchive();
    final destPath = p.join(tempDir.path, 'out');
    await ResourceArchiveExtractor.extract(archivePath, destPath);

    final manifest = await ResourceArchiveExtractor.readManifest(destPath);

    expect(manifest.version, 122);
    expect(manifest.files.single.path, 'db/characters.json');
  });

  test('readManifest throws when the manifest is missing', () async {
    final destPath = p.join(tempDir.path, 'empty');
    await Directory(destPath).create(recursive: true);

    expect(() => ResourceArchiveExtractor.readManifest(destPath), throwsA(isA<Exception>()));
  });

  test('extract overlays a later archive on top of an earlier one', () async {
    final destPath = p.join(tempDir.path, 'out');
    await ResourceArchiveExtractor.extract(buildArchive(), destPath);

    //Applying deltas in ascending order means a newer entry must win, and untouched files survive
    final second = Archive();
    final updated = utf8.encode('{"v":2}');
    second.addFile(ArchiveFile('db/characters.json', updated.length, updated));
    final kept = utf8.encode('{"kept":true}');
    second.addFile(ArchiveFile('db/weapons.json', kept.length, kept));
    final secondPath = p.join(tempDir.path, 'delta2.zip');
    File(secondPath).writeAsBytesSync(ZipEncoder().encode(second));

    await ResourceArchiveExtractor.extract(secondPath, destPath);

    expect(File(p.join(destPath, 'db', 'characters.json')).readAsStringSync(), '{"v":2}');
    expect(File(p.join(destPath, 'db', 'weapons.json')).readAsStringSync(), '{"kept":true}');
    expect(File(p.join(destPath, 'manifest.json')).existsSync(), isTrue);
  });

  test('extract rejects an entry that escapes the destination directory', () async {
    final archive = Archive();
    final payload = utf8.encode('pwned');
    archive.addFile(ArchiveFile('../escaped.txt', payload.length, payload));
    final archivePath = p.join(tempDir.path, 'evil.zip');
    File(archivePath).writeAsBytesSync(ZipEncoder().encode(archive));
    final destPath = p.join(tempDir.path, 'out');

    //The entry is skipped rather than rejected, so the file it declared simply never appears;
    //the manifest verification is what turns that into a failed update
    await ResourceArchiveExtractor.extract(archivePath, destPath);

    expect(File(p.join(tempDir.path, 'escaped.txt')).existsSync(), isFalse);
    expect(File(p.join(destPath, 'escaped.txt')).existsSync(), isFalse);
  });
}
