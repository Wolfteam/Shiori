import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:shiori/domain/utils/file_hash_utils.dart';

import '../secrets.dart';

/// Validates the archives the CLI generated. Skips itself when the tree has no archives yet.
void main() {
  final resourcesPath = Secrets.testAssetsPath;

  Map<String, dynamic> readVersionsJson() {
    final file = File(path.join(resourcesPath, 'versions.json'));
    expect(file.existsSync(), isTrue, reason: 'versions.json must exist at $resourcesPath');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  Map<String, dynamic> latestVersion() {
    final json = readVersionsJson();
    final versions = (json['Versions'] as List).cast<Map<String, dynamic>>();
    return versions.firstWhere((v) => v['IsTheLatest'] == true);
  }

  Map<String, dynamic>? archivesOfLatest() => latestVersion()['Archives'] as Map<String, dynamic>?;

  //Excludes the manifest, which describes the archive rather than being an asset
  Set<String> assetEntriesOf(String archivePath) {
    final decoder = ZipDecoder().decodeStream(InputFileStream(archivePath));
    return decoder.files.where((f) => f.isFile && f.name != 'manifest.json').map((f) => f.name).toSet();
  }

  Map<String, dynamic> manifestOf(String archivePath) {
    final decoder = ZipDecoder().decodeStream(InputFileStream(archivePath));
    final manifestFile = decoder.files.firstWhere((f) => f.name == 'manifest.json');
    return jsonDecode(utf8.decode(manifestFile.content as List<int>)) as Map<String, dynamic>;
  }

  group('Resource archives', () {
    test('the latest version declares a delta and a full archive', () {
      final archives = archivesOfLatest();
      if (archives == null) {
        markTestSkipped('No archives generated yet; run: versions generate --only-archives');
        return;
      }

      expect(latestVersion()['ContractVersion'], 2);
      expect(archives['Delta'], isNotNull, reason: 'every version must publish a delta archive');
      expect(archives['Full'], isNotNull, reason: 'the newest version must publish a full archive');
    });

    test('every declared archive resolves and matches its recorded size and hash', () async {
      final archives = archivesOfLatest();
      if (archives == null) {
        markTestSkipped('No archives generated yet');
        return;
      }

      for (final key in ['Delta', 'Full']) {
        final record = archives[key] as Map<String, dynamic>?;
        if (record == null) {
          continue;
        }

        final file = File(path.join(resourcesPath, record['KeyName'] as String));
        expect(file.existsSync(), isTrue, reason: '${record['KeyName']} must exist on disk');
        //The backend picks delta versus full by comparing these sizes
        expect(file.lengthSync(), record['SizeInBytes'], reason: '${record['KeyName']} size mismatch');
        //Uses the production hasher, so this also proves it agrees with the CLI on a real 150 MB archive
        expect(await FileHashUtils.sha256OfFile(file), record['Sha256'], reason: '${record['KeyName']} sha256 mismatch');
      }
    });

    test('each manifest matches its archive entries and per-file hashes', () {
      final archives = archivesOfLatest();
      if (archives == null) {
        markTestSkipped('No archives generated yet');
        return;
      }

      for (final key in ['Delta', 'Full']) {
        final record = archives[key] as Map<String, dynamic>?;
        if (record == null) {
          continue;
        }

        final archivePath = path.join(resourcesPath, record['KeyName'] as String);
        final manifest = manifestOf(archivePath);
        expect(manifest['contractVersion'], 2);

        final manifestFiles = (manifest['files'] as List).cast<Map<String, dynamic>>();
        final manifestPaths = manifestFiles.map((f) => f['path'] as String).toSet();

        expect(
          assetEntriesOf(archivePath),
          manifestPaths,
          reason: '${record['KeyName']} entries must match its manifest exactly',
        );

        final decoder = ZipDecoder().decodeStream(InputFileStream(archivePath));
        for (final entry in manifestFiles) {
          final file = decoder.files.firstWhere((f) => f.name == entry['path']);
          final bytes = file.content as List<int>;
          expect(bytes.length, entry['size'], reason: '${entry['path']} size mismatch');
          expect(sha256.convert(bytes).toString(), entry['sha256'], reason: '${entry['path']} hash mismatch');
        }
      }
    });

    test('archive entry paths carry no version prefix or timestamp', () {
      final archives = archivesOfLatest();
      if (archives == null) {
        markTestSkipped('No archives generated yet');
        return;
      }

      final delta = archives['Delta'] as Map<String, dynamic>;
      final entries = assetEntriesOf(path.join(resourcesPath, delta['KeyName'] as String));

      for (final entry in entries) {
        expect(entry.startsWith('versions/'), isFalse, reason: '$entry must not keep the versions prefix');
        //A leftover timestamp shows up as a middle dot segment
        expect(
          '.'.allMatches(path.basename(entry)).length,
          1,
          reason: '$entry must not keep the generated timestamp',
        );
      }
    });

    test('the full archive contains exactly what all.json lists', () {
      final archives = archivesOfLatest();
      if (archives == null) {
        markTestSkipped('No archives generated yet');
        return;
      }

      final latest = latestVersion();
      final full = archives['Full'] as Map<String, dynamic>;

      final allJsonFile = File(path.join(resourcesPath, latest['AllDataJsonKeyName'] as String));
      expect(allJsonFile.existsSync(), isTrue, reason: 'all.json must exist for the latest version');
      final allJson = jsonDecode(allJsonFile.readAsStringSync()) as Map<String, dynamic>;

      final expected = (allJson['KeyNames'] as List).cast<String>().map(_toAssetPath).toSet();
      final actual = assetEntriesOf(path.join(resourcesPath, full['KeyName'] as String));

      expect(actual, expected, reason: 'full.zip and all.json must describe the same file set');
    });
  });
}

//Dart port of VersionService.ToAssetPath
String _toAssetPath(String keyName) {
  final result = keyName.replaceAll('\\', '/').replaceFirst(RegExp('^versions/v[0-9]+/'), '');
  final dir = path.dirname(result);
  var filename = path.basename(result);
  if ('.'.allMatches(filename).length > 1) {
    final parts = filename.split('.');
    filename = '${parts.first}.${parts.last}';
  }
  return dir == '.' ? filename : path.join(dir, filename);
}
