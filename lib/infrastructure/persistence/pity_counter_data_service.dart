import 'package:hive/hive.dart';
import 'package:shiori/domain/services/persistence/pity_counter_data_service.dart';

class PityCounterDataServiceImpl implements PityCounterDataService {
  late Box<int> _pityCounterBox;

  @override
  Future<void> deleteThemAll() async {
    await _pityCounterBox.clear();
  }

  @override
  Future<void> init() async {
    _pityCounterBox = await Hive.openBox<int>('pityCounter');
  }

  @override
  Future<void> singleRoll(String bannerType) async {
    // I don't know how can this be null if we return 0 if no value is present
    int? currentValue = _pityCounterBox.get(bannerType, defaultValue: 0);
    int newValue = currentValue! + 1;
    _pityCounterBox.put(bannerType, newValue);
  }

  @override
  Future<void> tenRoll(String bannerType) async {
    // I don't know how can this be null if we return 0 if no value is present
    int? currentValue = _pityCounterBox.get(bannerType, defaultValue: 0);
    int newValue = currentValue! + 10;
    _pityCounterBox.put(bannerType, newValue);
  }
}