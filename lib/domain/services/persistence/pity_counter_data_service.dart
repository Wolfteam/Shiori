import 'package:shiori/domain/services/persistence/base_data_service.dart';

abstract class PityCounterDataService implements BaseDataService {
  Future<void> singleRoll(String bannerType);
  Future<void> tenRoll(String bannerType);
}