import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';
import 'package:shiori/domain/services/resources_service.dart';

class GadgetFileServiceImpl extends GadgetFileService {
  late GadgetsFile _gadgetsFile;

  @override
  ResourceService get resources => throw UnimplementedError('Resource service is not required in this file');

  @override
  TranslationFileService get translations => throw UnimplementedError('Translations are not required in this file');

  @override
  Future<void> init(String assetPath, bool noResourcesHaveBeenDownloaded) async {
    if (noResourcesHaveBeenDownloaded) {
      _gadgetsFile = GadgetsFile(gadgets: []);
      return;
    }
    final json = await readJson(assetPath);
    _gadgetsFile = GadgetsFile.fromJson(json);
    assert(
      _gadgetsFile.gadgets.map((e) => e.key).toSet().length == _gadgetsFile.gadgets.length,
      'All the gadgets keys must be unique',
    );
  }

  @override
  List<GadgetFileModel> getAllGadgetsForNotifications() {
    return _gadgetsFile.gadgets.where((el) => el.cooldownDuration != null).toList();
  }

  @override
  GadgetFileModel getGadget(String key) {
    return _gadgetsFile.gadgets.firstWhere((m) => m.key == key);
  }
}
