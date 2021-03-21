import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';

abstract class DataService {
  List<CalculatorSessionModel> getAllCalAscMatSessions();

  Future<int> createCalAscMatSession(String name);

  Future<void> updateCalAscMatSession(int sessionKey, String name);

  Future<void> deleteCalAscMatSession(int sessionKey);

  Future<void> addCalAscMatSessionItems(int sessionKey, List<ItemAscensionMaterials> items);

  Future<void> addCalAscMatSessionItem(int sessionKey, ItemAscensionMaterials item);

  Future<void> updateCalAscMatSessionItem(int sessionKey, int itemIndex, ItemAscensionMaterials item);

  Future<void> deleteCalAscMatSessionItem(int sessionKey, int itemIndex);

  List<CharacterCardModel> getAllCharactersInInventory();

  List<WeaponCardModel> getAllWeaponsInInventory();

  List<MaterialCardModel> getAllMaterialsInInventory();

  Future<void> addItemToInventory(String key, ItemType type, int quantity);

  Future<void> updateItemInInventory(String key, ItemType type, int quantity);

  Future<void> deleteItemFromInventory(String key, ItemType type);

  bool isItemInInventory(String key, ItemType type);
}
