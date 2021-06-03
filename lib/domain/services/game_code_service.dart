import 'package:genshindb/domain/models/models.dart';

abstract class GameCodeService {
  Future<List<GameCodeModel>> getAllGameCodes();
}
