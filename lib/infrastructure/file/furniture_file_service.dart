import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/furniture_file_service.dart';

class FurnitureFileServiceImpl implements FurnitureFileService {
  late FurnitureFile _furnitureFile;

  @override
  Future<void> init() async {
    final json = await Assets.getJsonFromPath(Assets.furnitureDbPath);
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
