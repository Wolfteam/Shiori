import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/base_file_service.dart';

abstract class ElementFileService implements BaseFileService {
  List<ElementCardModel> getElementDebuffs();

  List<ElementReactionCardModel> getElementReactions();

  List<ElementReactionCardModel> getElementResonances();
}
