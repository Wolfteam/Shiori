import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/utils/file_hash_utils.dart';

class ResourceArchiveVerifier {
  static Future<AppResourceUpdateFailureType> verifyExtracted(
    String extractedDirPath,
    ArchiveManifest manifest,
  ) async {
    for (final entry in manifest.files) {
      final file = File(p.join(extractedDirPath, entry.path));
      if (!await file.exists()) {
        return AppResourceUpdateFailureType.manifestMismatch;
      }

      //The hash subsumes a length check: a truncated or altered file cannot match it
      final hash = await FileHashUtils.sha256OfFile(file);
      if (hash != entry.sha256) {
        return AppResourceUpdateFailureType.manifestMismatch;
      }
    }

    return AppResourceUpdateFailureType.none;
  }
}
