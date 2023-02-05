import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/persistence/base_data_service.dart';

abstract class GameCodesDataService implements BaseDataService {
  List<GameCodeModel> getAllGameCodes();

  Future<void> saveGameCodes(List<GameCodeModel> items);

  Future<void> saveGameCodeRewards(int gameCodeKey, List<ItemAscensionMaterialModel> rewards);

  Future<void> deleteAllGameCodeRewards(int gameCodeKey);

  Future<void> markCodeAsUsed(String code, {bool wasUsed = true});

  List<BackupGameCodeModel> getDataForBackup();

  Future<void> restoreFromBackup(List<BackupGameCodeModel> data);
}
