import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/base_file_service.dart';

abstract class FurnitureFileService extends BaseFileService {
  FurnitureFileModel getDefaultFurnitureForNotifications();

  FurnitureFileModel getFurniture(String key);
}
