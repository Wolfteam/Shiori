import 'package:shiori/domain/models/dtos.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/api_service.dart';

abstract class ResourceArchiveService {
  /// Downloads every archive, verifies it, and only then writes anything into [assetsPath].
  ///
  /// [replaceAssetsFolder] is true for a full install (wipe and replace) and false for a delta,
  /// which overlays what is already there.
  Future<ArchiveApplyResult> downloadAndApply(
    List<ResourceArchiveResponseDto> archives,
    String tempPath,
    String assetsPath, {
    required bool replaceAssetsFolder,
    ProgressChanged? onProgress,
  });
}
