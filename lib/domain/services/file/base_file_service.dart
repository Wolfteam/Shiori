import 'dart:convert';
import 'dart:io';

import 'package:shiori/domain/services/file/file_infrastructure.dart';
import 'package:shiori/domain/services/resources_service.dart';

abstract class BaseFileService {
  ResourceService get resources;

  TranslationFileService get translations;

  Future<Map<String, dynamic>> readJson(String assetPath) async {
    final file = File(assetPath);
    final jsonString = await file.readAsString();
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<void> init(String assetPath, {bool noResourcesHaveBeenDownloaded = false});
}
