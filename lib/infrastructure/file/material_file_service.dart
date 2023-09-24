import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/material_file_service.dart';
import 'package:shiori/domain/services/file/translation_file_service.dart';
import 'package:shiori/domain/services/resources_service.dart';

class MaterialFileServiceImpl extends MaterialFileService {
  final ResourceService _resourceService;
  final TranslationFileService _translations;

  late MaterialsFile _materialsFile;

  @override
  ResourceService get resources => _resourceService;

  @override
  TranslationFileService get translations => _translations;

  MaterialFileServiceImpl(this._resourceService, this._translations);

  @override
  Future<void> init(String assetPath) async {
    final json = await readJson(assetPath);
    _materialsFile = MaterialsFile.fromJson(json);
  }

  @override
  List<MaterialCardModel> getAllMaterialsForCard() {
    return _materialsFile.materials.where((el) => el.isReadyToBeUsed).map((e) => _toMaterialForCard(e)).toList();
  }

  @override
  MaterialFileModel getMaterial(String key) {
    return _materialsFile.materials.firstWhere((m) => m.key == key);
  }

  @override
  MaterialFileModel getMaterialByImage(String image) {
    return _materialsFile.materials.firstWhere((m) => _resourceService.getMaterialImagePath(m.image, m.type) == image);
  }

  @override
  List<MaterialFileModel> getMaterials(MaterialType type, {bool onlyReadyToBeUsed = true}) {
    if (onlyReadyToBeUsed) {
      return _materialsFile.materials.where((m) => m.type == type && m.isReadyToBeUsed).toList();
    }
    return _materialsFile.materials.where((m) => m.type == type).toList();
  }

  @override
  MaterialFileModel getMoraMaterial() {
    return _materialsFile.materials.firstWhere((el) => el.type == MaterialType.currency && el.key == 'mora');
  }

  @override
  String getMaterialImg(String key) {
    final material = _materialsFile.materials.firstWhere((m) => m.key == key);
    return _resourceService.getMaterialImagePath(material.image, material.type);
  }

  @override
  MaterialCardModel getMaterialForCard(String key) {
    final material = _materialsFile.materials.firstWhere((m) => m.key == key);
    return _toMaterialForCard(material);
  }

  @override
  List<MaterialFileModel> getAllMaterialsThatCanBeObtainedFromAnExpedition() {
    return _materialsFile.materials.where((el) => el.canBeObtainedFromAnExpedition).toList();
  }

  @override
  List<MaterialFileModel> getAllMaterialsThatHaveAFarmingRespawnDuration() {
    return _materialsFile.materials.where((el) => el.farmingRespawnDuration != null).toList();
  }

  @override
  List<MaterialFileModel> getMaterialsFromAscensionMaterials(
    List<ItemAscensionMaterialFileModel> materials, {
    List<MaterialType> ignore = const [MaterialType.currency],
  }) {
    final mp = <String, MaterialFileModel>{};
    for (final item in materials) {
      if (!ignore.contains(item.type)) {
        final material = getMaterial(item.key);
        mp[item.key] = material;
      }
    }

    return mp.values.toList();
  }

  @override
  List<MaterialFileModel> getCharacterAscensionMaterials(int day) {
    return day == DateTime.sunday
        ? _materialsFile.talents.where((t) => t.days.isNotEmpty && t.level == 0).toList()
        : _materialsFile.talents.where((t) => t.days.contains(day) && t.level == 0).toList();
  }

  @override
  List<MaterialFileModel> getWeaponAscensionMaterials(int day) {
    return day == DateTime.sunday
        ? _materialsFile.weaponPrimary.where((t) => t.level == 0).toList()
        : _materialsFile.weaponPrimary.where((t) => t.days.contains(day) && t.level == 0).toList();
  }

  @override
  MaterialFileModel getRealmCurrencyMaterial() {
    final materials = getMaterials(MaterialType.currency);
    return materials.firstWhere((el) => el.key == 'realm-currency');
  }

  @override
  MaterialFileModel getPrimogemMaterial() {
    final materials = getMaterials(MaterialType.currency);
    return materials.firstWhere((el) => el.key == 'primogem');
  }

  @override
  MaterialFileModel getFragileResinMaterial() {
    final materials = getMaterials(MaterialType.currency);
    return materials.firstWhere((el) => el.key == 'fragile-resin');
  }

  @override
  MaterialFileModel getIntertwinedFate() {
    final materials = getMaterials(MaterialType.currency);
    return materials.firstWhere((el) => el.key == 'intertwined-fate');
  }

  @override
  MaterialFileModel getAcquaintFate() {
    final materials = getMaterials(MaterialType.currency);
    return materials.firstWhere((el) => el.key == 'acquaint-fate');
  }

  MaterialCardModel _toMaterialForCard(MaterialFileModel material) {
    final translation = _translations.getMaterialTranslation(material.key);
    return MaterialCardModel.item(
      key: material.key,
      image: _resourceService.getMaterialImagePath(material.image, material.type),
      rarity: material.rarity,
      position: material.position,
      type: material.type,
      name: translation.name,
      level: material.level,
      hasSiblings: material.hasSiblings,
    );
  }
}
