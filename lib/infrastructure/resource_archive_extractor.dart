import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:shiori/domain/models/models.dart';

/// Zip extraction for resource archives. Extraction runs off the main isolate because inflating
/// a 150 MB archive would otherwise jank the splash screen.
class ResourceArchiveExtractor {
  static const String manifestFilename = 'manifest.json';

  static Future<void> extract(String archivePath, String destDirPath) async {
    await Directory(destDirPath).create(recursive: true);
    //Only two strings cross the isolate boundary
    await Isolate.run(() => extractFileToDisk(archivePath, destDirPath));
  }

  static Future<ArchiveManifest> readManifest(String extractedDirPath) async {
    final file = File(p.join(extractedDirPath, manifestFilename));
    if (!await file.exists()) {
      throw Exception('The archive does not contain a $manifestFilename');
    }

    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return ArchiveManifest.fromJson(json);
  }
}
