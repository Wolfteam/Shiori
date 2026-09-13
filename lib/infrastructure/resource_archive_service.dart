import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/dtos.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/api_service.dart';
import 'package:shiori/domain/services/disk_space_checker.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/resource_archive_service.dart';
import 'package:shiori/domain/utils/file_hash_utils.dart';
import 'package:shiori/infrastructure/resource_archive_extractor.dart';
import 'package:shiori/infrastructure/resource_archive_verifier.dart';

//POSIX ENOSPC and Windows ERROR_DISK_FULL / ERROR_HANDLE_DISK_FULL
const _noSpaceErrorCodes = <int>[28, 39, 112];

//Archives are mostly stored (uncompressed) webp, so the extracted tree is roughly the archive size.
//Budget for the archive plus its extracted copy, plus headroom for the swap into the assets folder.
const _diskHeadroomBytes = 64 * 1024 * 1024;

class ResourceArchiveServiceImpl implements ResourceArchiveService {
  final LoggingService _loggingService;
  final ApiService _apiService;
  final DiskSpaceChecker _diskSpaceChecker;

  ResourceArchiveServiceImpl(this._loggingService, this._apiService, this._diskSpaceChecker);

  @override
  Future<ArchiveApplyResult> downloadAndApply(
    List<ResourceArchiveResponseDto> archives,
    String tempPath,
    String assetsPath, {
    required bool replaceAssetsFolder,
    ProgressChanged? onProgress,
  }) async {
    if (archives.isEmpty) {
      _loggingService.warning(runtimeType, 'downloadAndApply: No archives were provided');
      return const ArchiveApplyResult(failureType: AppResourceUpdateFailureType.unknown, bytesDownloaded: 0);
    }

    final stagingPath = p.join(tempPath, 'staging');
    int bytesDownloaded = 0;
    final deletions = <String>[];

    final int totalArchiveBytes = archives.fold(0, (sum, a) => sum + a.sizeInBytes);
    final int requiredBytes = totalArchiveBytes * 2 + _diskHeadroomBytes;
    final int? freeBytes = await _diskSpaceChecker.freeBytesFor(tempPath);
    //A null answer means unknown, not zero: carry on and let the OS error be the real check
    if (freeBytes != null && freeBytes < requiredBytes) {
      _loggingService.error(
        runtimeType,
        'downloadAndApply: Not enough disk space. Free = $freeBytes, required = $requiredBytes',
      );
      return const ArchiveApplyResult(
        failureType: AppResourceUpdateFailureType.insufficientDiskSpace,
        bytesDownloaded: 0,
      );
    }

    try {
      await _deleteDirectoryIfExists(tempPath);
      await Directory(stagingPath).create(recursive: true);

      for (int i = 0; i < archives.length; i++) {
        final archive = archives[i];
        final archivePath = p.join(tempPath, 'archive_$i.zip');

        _loggingService.info(runtimeType, 'downloadAndApply: Downloading ${archive.keyName}...');
        final int baseBytes = bytesDownloaded;
        final written = await _apiService.downloadAssetStreamed(
          archive.keyName,
          archivePath,
          onBytes: (received, _) {
            final progress = totalArchiveBytes > 0 ? (baseBytes + received) * 100 / totalArchiveBytes : 0.0;
            onProgress?.call(progress.clamp(0, 100).toDouble(), baseBytes + received);
          },
        );
        if (written == null) {
          return ArchiveApplyResult(
            failureType: AppResourceUpdateFailureType.downloadFailed,
            bytesDownloaded: bytesDownloaded,
          );
        }
        bytesDownloaded += written;

        final hash = await FileHashUtils.sha256OfFile(File(archivePath));
        if (hash != archive.sha256) {
          _loggingService.error(
            runtimeType,
            'downloadAndApply: ${archive.keyName} hash mismatch. Expected = ${archive.sha256}, got = $hash',
          );
          return ArchiveApplyResult(
            failureType: AppResourceUpdateFailureType.checksumMismatch,
            bytesDownloaded: bytesDownloaded,
          );
        }

        //Extract into the shared staging folder so later archives overlay earlier ones,
        //which is exactly the semantics of applying deltas in ascending version order
        await ResourceArchiveExtractor.extract(archivePath, stagingPath);

        final ArchiveManifest manifest = await ResourceArchiveExtractor.readManifest(stagingPath);
        if (!manifest.isSupported) {
          _loggingService.error(
            runtimeType,
            'downloadAndApply: ${archive.keyName} declares contract ${manifest.contractVersion}, '
            'which this build cannot apply',
          );
          return ArchiveApplyResult(
            failureType: AppResourceUpdateFailureType.manifestMismatch,
            bytesDownloaded: bytesDownloaded,
          );
        }

        final verification = await ResourceArchiveVerifier.verifyExtracted(stagingPath, manifest);
        if (verification != AppResourceUpdateFailureType.none) {
          _loggingService.error(runtimeType, 'downloadAndApply: ${archive.keyName} failed verification');
          return ArchiveApplyResult(failureType: verification, bytesDownloaded: bytesDownloaded);
        }

        deletions.addAll(manifest.deleted);
        //Applied to staging right away so a deletion also removes what an earlier archive in the
        //same chain staged, instead of only touching the assets folder at the end
        for (final relativePath in manifest.deleted) {
          await _deleteFileIfExists(p.join(stagingPath, relativePath));
        }

        await File(archivePath).delete();
        //The manifest describes the archive, it is not an asset
        await _deleteFileIfExists(p.join(stagingPath, ResourceArchiveExtractor.manifestFilename));
      }

      //Resolved before the swap: staging is consumed by the move below, so asking it afterwards
      //whether a later archive re-added a file would always answer no
      final pendingDeletions = <String>[];
      for (final relativePath in deletions) {
        if (!await File(p.join(stagingPath, relativePath)).exists()) {
          pendingDeletions.add(relativePath);
        }
      }

      bool moved = false;
      if (replaceAssetsFolder) {
        await _deleteDirectoryIfExists(assetsPath);
        //With the destination gone the whole tree moves as one metadata operation
        moved = await _tryRenameDirectory(stagingPath, assetsPath);
      }

      if (!moved) {
        await Directory(assetsPath).create(recursive: true);
        await _moveDirectoryContents(stagingPath, assetsPath);
      }

      for (final relativePath in pendingDeletions) {
        await _deleteFileIfExists(p.join(assetsPath, relativePath));
      }

      _loggingService.info(runtimeType, 'downloadAndApply: Applied ${archives.length} archive(s)');
      return ArchiveApplyResult(
        failureType: AppResourceUpdateFailureType.none,
        bytesDownloaded: bytesDownloaded,
      );
    } on FileSystemException catch (e, s) {
      if (_noSpaceErrorCodes.contains(e.osError?.errorCode)) {
        _loggingService.error(runtimeType, 'downloadAndApply: Ran out of disk space', e, s);
        return ArchiveApplyResult(
          failureType: AppResourceUpdateFailureType.insufficientDiskSpace,
          bytesDownloaded: bytesDownloaded,
        );
      }

      _loggingService.error(runtimeType, 'downloadAndApply: File system error', e, s);
      return ArchiveApplyResult(
        failureType: AppResourceUpdateFailureType.extractFailed,
        bytesDownloaded: bytesDownloaded,
      );
    } catch (e, s) {
      _loggingService.error(runtimeType, 'downloadAndApply: Unknown error', e, s);
      return ArchiveApplyResult(failureType: AppResourceUpdateFailureType.unknown, bytesDownloaded: bytesDownloaded);
    } finally {
      await _deleteDirectoryIfExists(tempPath);
    }
  }

  Future<bool> _tryRenameDirectory(String from, String to) async {
    try {
      await Directory(from).rename(to);
      return true;
    } catch (e) {
      _loggingService.info(runtimeType, 'downloadAndApply: Could not rename $from, falling back to a per-file move');
      return false;
    }
  }

  /// Moves rather than copies, so a 150 MB tree never exists twice on disk at once.
  Future<void> _moveDirectoryContents(String from, String to) async {
    final entities = await Directory(from).list(recursive: true).toList();
    for (final entity in entities) {
      final relative = p.relative(entity.path, from: from);
      final target = p.join(to, relative);
      if (entity is Directory) {
        await Directory(target).create(recursive: true);
        continue;
      }

      if (entity is File) {
        await Directory(p.dirname(target)).create(recursive: true);
        try {
          await entity.rename(target);
        } catch (e) {
          //Renaming only works within one filesystem, so fall back for anything else
          await entity.copy(target);
          await entity.delete();
        }
      }
    }
  }

  Future<void> _deleteDirectoryIfExists(String path) async {
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<void> _deleteFileIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
