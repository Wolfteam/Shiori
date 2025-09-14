import 'package:mockito/mockito.dart';
import 'package:shiori/domain/models/models.dart';

//sealed class cannot be instantiated by mockito, so we have to manually provide dummy values
void provideDummyMocks() {
  provideDummyBuilder<ItemAscensionMaterials>(
    (parent, inv) => const ItemAscensionMaterials.forWeapons(
      key: 'na',
      name: 'na',
      image: 'na',
      position: 0,
      rarity: 0,
      materials: [],
      currentLevel: 0,
      desiredLevel: 0,
      currentAscensionLevel: 0,
      desiredAscensionLevel: 0,
      useMaterialsFromInventory: false,
    ),
  );
}
