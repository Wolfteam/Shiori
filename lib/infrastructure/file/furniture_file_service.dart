import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';
import 'package:shiori/domain/services/resources_service.dart';

class FurnitureFileServiceImpl extends FurnitureFileService {
  late FurnitureFile _furnitureFile;

  @override
  ResourceService get resources => throw UnimplementedError('Resource service is not required in this file');

  @override
  TranslationFileService get translations => throw UnimplementedError('Translations are not required in this file');

  @override
  Future<void> init(String assetPath, {bool noResourcesHaveBeenDownloaded = false}) async {
    if (noResourcesHaveBeenDownloaded) {
      _furnitureFile = FurnitureFile(furniture: []);
      return;
    }
    final json = await readJson(assetPath);
    _furnitureFile = FurnitureFile.fromJson(json);
    assert(
      _furnitureFile.furniture.map((e) => e.key).toSet().length == _furnitureFile.furniture.length,
      'All the furniture keys must be unique',
    );
  }

  @override
  FurnitureFileModel getDefaultFurnitureForNotifications() {
    return _furnitureFile.furniture.first;
  }

  @override
  FurnitureFileModel getFurniture(String key) {
    return _furnitureFile.furniture.firstWhere((m) => m.key == key);
  }
}
