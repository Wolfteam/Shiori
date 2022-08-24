import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/base_file_service.dart';

abstract class FurnitureFileService implements BaseFileService {
  FurnitureFileModel getDefaultFurnitureForNotifications();

  FurnitureFileModel getFurniture(String key);
}
