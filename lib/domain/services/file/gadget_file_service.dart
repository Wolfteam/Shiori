import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/base_file_service.dart';

abstract class GadgetFileService implements BaseFileService {
  List<GadgetFileModel> getAllGadgetsForNotifications();

  GadgetFileModel getGadget(String key);
}
