import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppPathUtils {
  //internal memory/android/data/com.miraisoft.genshindb/files/logs
  static Future<String> get logsPath async {
    final dir = await getExternalStorageDirectory();
    final dirPath = '${dir!.path}/Logs';
    await _generateDirectoryIfItDoesntExist(dirPath);
    return dirPath;
  }

  static Future<void> _generateDirectoryIfItDoesntExist(String path) async {
    final dirExists = await Directory(path).exists();
    if (!dirExists) {
      await Directory(path).create(recursive: true);
    }
  }

  static Future<void> deleteOlLogs() async {
    final maxDate = DateTime.now().subtract(const Duration(days: 3));
    final path = await logsPath;
    final dir = Directory(path);
    final files = dir.listSync();
    final filesToDelete = <FileSystemEntity>[];
    for (final file in files) {
      final stat = await file.stat();
      if (stat.modified.isBefore(maxDate)) {
        filesToDelete.add(file);
      }
    }
    if (filesToDelete.isNotEmpty) {
      await Future.wait(filesToDelete.map((f) => f.delete()).toList());
    }
  }
}
