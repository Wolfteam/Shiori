import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/furniture_file_service.dart';

class FurnitureFileServiceImpl extends FurnitureFileService {
  late FurnitureFile _furnitureFile;

  @override
  Future<void> init(String assetPath) async {
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
