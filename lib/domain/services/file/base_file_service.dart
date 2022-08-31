import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';

abstract class BaseFileService {
  TranslationFileService get translations;

  Future<Map<String, dynamic>> readJson(String assetPath) async {
    final jsonString = await Assets.getJsonFromPath(assetPath);
    return jsonString;
  }

  Future<void> init(String assetPath);
}
