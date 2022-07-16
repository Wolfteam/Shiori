import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/persistence/base_data_service.dart';

abstract class TierListDataService implements BaseDataService {
  List<TierListRowModel> getTierList();

  Future<void> saveTierList(List<TierListRowModel> tierList);

  Future<void> deleteTierList();
}
