import 'package:shiori/domain/models/models.dart';

abstract class GameCodeService {
  Future<List<GameCodeModel>> getAllGameCodes();
}
