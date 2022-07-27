import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/gadget_file_service.dart';

class GadgetFileServiceImpl implements GadgetFileService {
  late GadgetsFile _gadgetsFile;

  @override
  Future<void> init() async {
    final json = await Assets.getJsonFromPath(Assets.gadgetsDbPath);
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