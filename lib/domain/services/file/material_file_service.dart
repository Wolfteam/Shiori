import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/base_file_service.dart';

abstract class MaterialFileService extends BaseFileService {
  List<MaterialCardModel> getAllMaterialsForCard();

  MaterialCardModel getMaterialForCard(String key);

  MaterialFileModel getMaterial(String key);

  MaterialFileModel getMaterialByImage(String image);

  List<MaterialFileModel> getMaterials(MaterialType type, {bool onlyReadyToBeUsed = true});

  MaterialFileModel getMoraMaterial();

  String getMaterialImg(String key);

  List<MaterialFileModel> getAllMaterialsThatCanBeObtainedFromAnExpedition();

  List<MaterialFileModel> getAllMaterialsThatHaveAFarmingRespawnDuration();

  List<MaterialFileModel> getMaterialsFromAscensionMaterials(
    List<ItemAscensionMaterialFileModel> materials, {
    List<MaterialType> ignore = const [MaterialType.currency],
  });

  List<MaterialFileModel> getCharacterAscensionMaterials(int day);

  List<MaterialFileModel> getWeaponAscensionMaterials(int day);

  MaterialFileModel getRealmCurrencyMaterial();

  MaterialFileModel getPrimogemMaterial();

  MaterialFileModel getFragileResinMaterial();

  MaterialFileModel getIntertwinedFate();

  MaterialFileModel getAcquaintFate();
}
