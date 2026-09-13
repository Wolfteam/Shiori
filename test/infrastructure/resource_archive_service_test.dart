import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/dtos.dart';
import 'package:shiori/infrastructure/resource_archive_service.dart';

import '../mocks.mocks.dart';

void main() {
  late Directory tempDir;
  late MockApiService apiService;
  late MockLoggingService loggingService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('shiori-apply');
    apiService = MockApiService();
    loggingService = MockLoggingService();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  /// Builds a real archive containing one json file plus a manifest, and returns its sha256.
  ({String path, String sha256}) buildArchive({
    List<String> deleted = const <String>[],
    int contractVersion = 2,
    String filename = 'source-delta.zip',
    String content = '{"updated":true}',
    String? corruptManifestHash,
  }) {
    final bytes = utf8.encode(content);
    final archive = Archive();
    final manifest = utf8.encode(
      jsonEncode({
        'contractVersion': contractVersion,
        'version': 122,
        'appVersion': '1.8.0',
        'mode': 2,
        'files': [
          {
            'path': 'db/characters.json',
            'size': bytes.length,
            'sha256': corruptManifestHash ?? sha256.convert(bytes).toString(),
          },
        ],
        'deleted': deleted,
      }),
    );
    archive.addFile(ArchiveFile('manifest.json', manifest.length, manifest));
    archive.addFile(ArchiveFile('db/characters.json', bytes.length, bytes));

    final path = p.join(tempDir.path, filename);
    final encoded = ZipEncoder().encode(archive);
    File(path).writeAsBytesSync(encoded);
    return (path: path, sha256: sha256.convert(encoded).toString());
  }

  /// Stubs downloadAssetStreamed to copy a prebuilt archive to the requested destination.
  void stubDownload(String sourcePath) {
    when(
      apiService.downloadAssetStreamed(any, any, overrideUrl: anyNamed('overrideUrl'), onBytes: anyNamed('onBytes')),
    ).thenAnswer((invocation) async {
      final destPath = invocation.positionalArguments[1] as String;
      final dest = File(destPath);
      await dest.parent.create(recursive: true);
      await File(sourcePath).copy(destPath);
      final length = dest.lengthSync();
      final onBytes = invocation.namedArguments[const Symbol('onBytes')] as void Function(int, int?)?;
      onBytes?.call(length, length);
      return length;
    });
  }

  /// [freeBytes] null means "unknown", which must not block the update.
  ResourceArchiveServiceImpl createService({int? freeBytes}) {
    final diskSpaceChecker = MockDiskSpaceChecker();
    when(diskSpaceChecker.freeBytesFor(any)).thenAnswer((_) async => freeBytes);
    return ResourceArchiveServiceImpl(loggingService, apiService, diskSpaceChecker);
  }

  ResourceArchiveResponseDto archiveDto(String sha256Value, {int sizeInBytes = 0}) => ResourceArchiveResponseDto(
    version: 122,
    keyName: 'versions/v122/delta.zip',
    sizeInBytes: sizeInBytes,
    sha256: sha256Value,
    contractVersion: 2,
  );

  Future<String> createAssetsFolder() async {
    final assetsPath = p.join(tempDir.path, 'assets');
    await Directory(assetsPath).create(recursive: true);
    return assetsPath;
  }

  test('applies a verified archive into the assets folder', () async {
    final built = buildArchive();
    stubDownload(built.path);
    final assetsPath = await createAssetsFolder();

    final result = await createService().downloadAndApply(
      [archiveDto(built.sha256)],
      p.join(tempDir.path, 'temp'),
      assetsPath,
      replaceAssetsFolder: false,
    );

    expect(result.failureType, AppResourceUpdateFailureType.none);
    expect(result.succeed, isTrue);
    expect(File(p.join(assetsPath, 'db', 'characters.json')).readAsStringSync(), '{"updated":true}');
    //The manifest must not leak into the assets folder
    expect(File(p.join(assetsPath, 'manifest.json')).existsSync(), isFalse);
  });

  test('rejects an archive whose sha256 does not match and writes nothing', () async {
    final built = buildArchive();
    stubDownload(built.path);
    final assetsPath = await createAssetsFolder();

    final result = await createService().downloadAndApply(
      [archiveDto('deadbeef')],
      p.join(tempDir.path, 'temp'),
      assetsPath,
      replaceAssetsFolder: false,
    );

    expect(result.failureType, AppResourceUpdateFailureType.checksumMismatch);
    expect(File(p.join(assetsPath, 'db', 'characters.json')).existsSync(), isFalse);
  });

  test('reports downloadFailed when the download returns null', () async {
    when(
      apiService.downloadAssetStreamed(any, any, overrideUrl: anyNamed('overrideUrl'), onBytes: anyNamed('onBytes')),
    ).thenAnswer((_) async => null);
    final assetsPath = await createAssetsFolder();

    final result = await createService().downloadAndApply(
      [archiveDto('whatever')],
      p.join(tempDir.path, 'temp'),
      assetsPath,
      replaceAssetsFolder: false,
    );

    expect(result.failureType, AppResourceUpdateFailureType.downloadFailed);
  });

  test('refuses to start when the precheck reports too little free space', () async {
    final built = buildArchive();
    stubDownload(built.path);
    final assetsPath = await createAssetsFolder();

    //Archives declare 4_000 bytes, so the requirement is well above 1_000 free
    final result = await createService(freeBytes: 1000).downloadAndApply(
      [archiveDto(built.sha256, sizeInBytes: 4000)],
      p.join(tempDir.path, 'temp'),
      assetsPath,
      replaceAssetsFolder: false,
    );

    expect(result.failureType, AppResourceUpdateFailureType.insufficientDiskSpace);
    //Nothing should have been downloaded at all
    verifyNever(
      apiService.downloadAssetStreamed(any, any, overrideUrl: anyNamed('overrideUrl'), onBytes: anyNamed('onBytes')),
    );
  });

  //Unknown is what the checker reports on an unsupported platform or an OS-level failure
  test('proceeds normally when free space is unknown', () async {
    final built = buildArchive();
    stubDownload(built.path);
    final assetsPath = await createAssetsFolder();

    final result = await createService().downloadAndApply(
      [archiveDto(built.sha256)],
      p.join(tempDir.path, 'temp'),
      assetsPath,
      replaceAssetsFolder: false,
    );

    expect(result.failureType, AppResourceUpdateFailureType.none);
    expect(File(p.join(assetsPath, 'db', 'characters.json')).existsSync(), isTrue);
  });

  test('applies deletions listed in the manifest', () async {
    final built = buildArchive(deleted: ['skills/gone.webp']);
    stubDownload(built.path);
    final assetsPath = p.join(tempDir.path, 'assets');
    final stale = File(p.join(assetsPath, 'skills', 'gone.webp'));
    await stale.parent.create(recursive: true);
    await stale.writeAsString('stale');

    final result = await createService().downloadAndApply(
      [archiveDto(built.sha256)],
      p.join(tempDir.path, 'temp'),
      assetsPath,
      replaceAssetsFolder: false,
    );

    expect(result.failureType, AppResourceUpdateFailureType.none);
    expect(stale.existsSync(), isFalse);
  });

  test('rejects an archive whose manifest declares a newer contract', () async {
    final built = buildArchive(contractVersion: 3);
    stubDownload(built.path);
    final assetsPath = await createAssetsFolder();

    final result = await createService().downloadAndApply(
      [archiveDto(built.sha256)],
      p.join(tempDir.path, 'temp'),
      assetsPath,
      replaceAssetsFolder: false,
    );

    expect(result.failureType, AppResourceUpdateFailureType.manifestMismatch);
    expect(File(p.join(assetsPath, 'db', 'characters.json')).existsSync(), isFalse);
  });

  test('rejects an archive whose contents do not match its own manifest', () async {
    final built = buildArchive(corruptManifestHash: 'not-the-real-hash');
    stubDownload(built.path);
    final assetsPath = await createAssetsFolder();

    final result = await createService().downloadAndApply(
      [archiveDto(built.sha256)],
      p.join(tempDir.path, 'temp'),
      assetsPath,
      replaceAssetsFolder: false,
    );

    expect(result.failureType, AppResourceUpdateFailureType.manifestMismatch);
    expect(File(p.join(assetsPath, 'db', 'characters.json')).existsSync(), isFalse);
  });

  test('replaceAssetsFolder wipes what was there before', () async {
    final built = buildArchive();
    stubDownload(built.path);
    final assetsPath = p.join(tempDir.path, 'assets');
    final stale = File(p.join(assetsPath, 'db', 'stale.json'));
    await stale.parent.create(recursive: true);
    await stale.writeAsString('old');

    final result = await createService().downloadAndApply(
      [archiveDto(built.sha256)],
      p.join(tempDir.path, 'temp'),
      assetsPath,
      replaceAssetsFolder: true,
    );

    expect(result.failureType, AppResourceUpdateFailureType.none);
    expect(stale.existsSync(), isFalse);
    expect(File(p.join(assetsPath, 'db', 'characters.json')).existsSync(), isTrue);
  });

  test('a delta mode apply keeps files it does not mention', () async {
    final built = buildArchive();
    stubDownload(built.path);
    final assetsPath = p.join(tempDir.path, 'assets');
    final kept = File(p.join(assetsPath, 'db', 'weapons.json'));
    await kept.parent.create(recursive: true);
    await kept.writeAsString('keep me');

    final result = await createService().downloadAndApply(
      [archiveDto(built.sha256)],
      p.join(tempDir.path, 'temp'),
      assetsPath,
      replaceAssetsFolder: false,
    );

    expect(result.failureType, AppResourceUpdateFailureType.none);
    expect(kept.readAsStringSync(), 'keep me');
  });

  test('reports unknown and writes nothing when no archives are provided', () async {
    final assetsPath = await createAssetsFolder();

    final result = await createService().downloadAndApply(
      [],
      p.join(tempDir.path, 'temp'),
      assetsPath,
      replaceAssetsFolder: false,
    );

    expect(result.succeed, isFalse);
    expect(result.failureType, AppResourceUpdateFailureType.unknown);
  });

  test('applies a chain of archives in order and reports total bytes', () async {
    final first = buildArchive(filename: 'a.zip', content: '{"v":1}');
    final second = buildArchive(filename: 'b.zip', content: '{"v":2}');
    final assetsPath = await createAssetsFolder();

    //Each call gets the archive matching the index it was asked for, so ordering is observable
    final sources = [first.path, second.path];
    var call = 0;
    when(
      apiService.downloadAssetStreamed(any, any, overrideUrl: anyNamed('overrideUrl'), onBytes: anyNamed('onBytes')),
    ).thenAnswer((invocation) async {
      final destPath = invocation.positionalArguments[1] as String;
      final dest = File(destPath);
      await dest.parent.create(recursive: true);
      await File(sources[call++]).copy(destPath);
      return dest.lengthSync();
    });

    final result = await createService().downloadAndApply(
      [archiveDto(first.sha256), archiveDto(second.sha256)],
      p.join(tempDir.path, 'temp'),
      assetsPath,
      replaceAssetsFolder: false,
    );

    expect(result.failureType, AppResourceUpdateFailureType.none);
    //The later archive wins, which is what applying deltas in ascending order means
    expect(File(p.join(assetsPath, 'db', 'characters.json')).readAsStringSync(), '{"v":2}');
    expect(result.bytesDownloaded, File(first.path).lengthSync() + File(second.path).lengthSync());
  });

  test('a later archive can re-add a file an earlier one deleted', () async {
    final assetsPath = await createAssetsFolder();

    //v121 removes the skill image, v122 brings it back: the chain must end with the file present
    final first = _buildArchiveWith(
      tempDir: tempDir,
      filename: 'a.zip',
      entries: {'db/characters.json': '{"v":1}'},
      deleted: ['skills/revived.webp'],
    );
    final second = _buildArchiveWith(
      tempDir: tempDir,
      filename: 'b.zip',
      entries: {'db/characters.json': '{"v":2}', 'skills/revived.webp': 'back'},
    );

    final sources = [first.path, second.path];
    var call = 0;
    when(
      apiService.downloadAssetStreamed(any, any, overrideUrl: anyNamed('overrideUrl'), onBytes: anyNamed('onBytes')),
    ).thenAnswer((invocation) async {
      final destPath = invocation.positionalArguments[1] as String;
      final dest = File(destPath);
      await dest.parent.create(recursive: true);
      await File(sources[call++]).copy(destPath);
      return dest.lengthSync();
    });

    final result = await createService().downloadAndApply(
      [archiveDto(first.sha256), archiveDto(second.sha256)],
      p.join(tempDir.path, 'temp'),
      assetsPath,
      replaceAssetsFolder: false,
    );

    expect(result.failureType, AppResourceUpdateFailureType.none);
    expect(File(p.join(assetsPath, 'skills', 'revived.webp')).readAsStringSync(), 'back');
  });

  test('a deletion removes a file an earlier archive in the same chain staged', () async {
    final assetsPath = await createAssetsFolder();

    final first = _buildArchiveWith(
      tempDir: tempDir,
      filename: 'a.zip',
      entries: {'db/characters.json': '{"v":1}', 'skills/doomed.webp': 'here'},
    );
    final second = _buildArchiveWith(
      tempDir: tempDir,
      filename: 'b.zip',
      entries: {'db/characters.json': '{"v":2}'},
      deleted: ['skills/doomed.webp'],
    );

    final sources = [first.path, second.path];
    var call = 0;
    when(
      apiService.downloadAssetStreamed(any, any, overrideUrl: anyNamed('overrideUrl'), onBytes: anyNamed('onBytes')),
    ).thenAnswer((invocation) async {
      final destPath = invocation.positionalArguments[1] as String;
      final dest = File(destPath);
      await dest.parent.create(recursive: true);
      await File(sources[call++]).copy(destPath);
      return dest.lengthSync();
    });

    final result = await createService().downloadAndApply(
      [archiveDto(first.sha256), archiveDto(second.sha256)],
      p.join(tempDir.path, 'temp'),
      assetsPath,
      replaceAssetsFolder: false,
    );

    expect(result.failureType, AppResourceUpdateFailureType.none);
    expect(File(p.join(assetsPath, 'skills', 'doomed.webp')).existsSync(), isFalse);
  });

  test('full mode still honours re-adds, where the whole staging folder is renamed', () async {
    final assetsPath = await createAssetsFolder();

    final first = _buildArchiveWith(
      tempDir: tempDir,
      filename: 'a.zip',
      entries: {'db/characters.json': '{"v":1}'},
      deleted: ['skills/revived.webp'],
    );
    final second = _buildArchiveWith(
      tempDir: tempDir,
      filename: 'b.zip',
      entries: {'db/characters.json': '{"v":2}', 'skills/revived.webp': 'back'},
    );

    final sources = [first.path, second.path];
    var call = 0;
    when(
      apiService.downloadAssetStreamed(any, any, overrideUrl: anyNamed('overrideUrl'), onBytes: anyNamed('onBytes')),
    ).thenAnswer((invocation) async {
      final destPath = invocation.positionalArguments[1] as String;
      final dest = File(destPath);
      await dest.parent.create(recursive: true);
      await File(sources[call++]).copy(destPath);
      return dest.lengthSync();
    });

    final result = await createService().downloadAndApply(
      [archiveDto(first.sha256), archiveDto(second.sha256)],
      p.join(tempDir.path, 'temp'),
      assetsPath,
      //Full mode deletes the assets folder first, so the move happens as a single rename
      replaceAssetsFolder: true,
    );

    expect(result.failureType, AppResourceUpdateFailureType.none);
    expect(File(p.join(assetsPath, 'skills', 'revived.webp')).readAsStringSync(), 'back');
    expect(File(p.join(assetsPath, 'db', 'characters.json')).readAsStringSync(), '{"v":2}');
  });

  test('leaves the temp folder clean after a successful apply', () async {
    final built = buildArchive();
    stubDownload(built.path);
    final assetsPath = await createAssetsFolder();
    final tempPath = p.join(tempDir.path, 'temp');

    await createService().downloadAndApply([archiveDto(built.sha256)], tempPath, assetsPath, replaceAssetsFolder: false);

    //A 150 MB archive plus its extracted copy must not be left behind
    expect(Directory(tempPath).existsSync(), isFalse);
  });

  test('leaves the temp folder clean after a failed apply', () async {
    final built = buildArchive();
    stubDownload(built.path);
    final assetsPath = await createAssetsFolder();
    final tempPath = p.join(tempDir.path, 'temp');

    await createService().downloadAndApply([archiveDto('deadbeef')], tempPath, assetsPath, replaceAssetsFolder: false);

    expect(Directory(tempPath).existsSync(), isFalse);
  });

  test('reports progress that never exceeds 100', () async {
    final built = buildArchive();
    stubDownload(built.path);
    final assetsPath = await createAssetsFolder();
    final progress = <double>[];

    await createService().downloadAndApply(
      [archiveDto(built.sha256, sizeInBytes: 10)],
      p.join(tempDir.path, 'temp'),
      assetsPath,
      replaceAssetsFolder: false,
      onProgress: (value, bytes) => progress.add(value),
    );

    //The declared size can understate the real one, and the UI must not be handed 900%
    expect(progress, isNotEmpty);
    expect(progress.every((value) => value >= 0 && value <= 100), isTrue);
  });
}

/// Builds an archive with arbitrary entries, used by the chain tests where each archive differs.
({String path, String sha256}) _buildArchiveWith({
  required Directory tempDir,
  required String filename,
  required Map<String, String> entries,
  List<String> deleted = const <String>[],
}) {
  final archive = Archive();
  final files = <Map<String, dynamic>>[];
  for (final entry in entries.entries) {
    final bytes = utf8.encode(entry.value);
    archive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
    files.add({'path': entry.key, 'size': bytes.length, 'sha256': sha256.convert(bytes).toString()});
  }

  final manifest = utf8.encode(
    jsonEncode({
      'contractVersion': 2,
      'version': 122,
      'appVersion': '1.8.0',
      'mode': 2,
      'files': files,
      'deleted': deleted,
    }),
  );
  archive.addFile(ArchiveFile('manifest.json', manifest.length, manifest));

  final path = p.join(tempDir.path, filename);
  final encoded = ZipEncoder().encode(archive);
  File(path).writeAsBytesSync(encoded);
  return (path: path, sha256: sha256.convert(encoded).toString());
}
