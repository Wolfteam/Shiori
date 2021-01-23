import '../common/extensions/string_extensions.dart';
import 'enums/app_language_type.dart';
import 'enums/artifact_type.dart';
import 'enums/element_type.dart';
import 'enums/material_type.dart';
import 'enums/weapon_type.dart';

class Assets {
  static String dbPath = 'assets/db';
  static String charactersDbPath = '$dbPath/characters.json';
  static String weaponsDbPath = '$dbPath/weapons.json';
  static String artifactsDbPath = '$dbPath/artifacts.json';
  static String materialsDbPath = '$dbPath/materials.json';
  static String elementsDbPath = '$dbPath/elements.json';
  static String translationsBasePath = 'assets/i18n';

  //General
  static String artifactsBasePath = 'assets/artifacts';
  static String charactersBasePath = 'assets/characters';
  static String characterFullBasePath = 'assets/characters_full';
  static String skillsBasePath = 'assets/skills';
  static String elementsBasePath = 'assets/elements';
  static String noImageAvailableName = 'na.png';

  //Weapons
  static String weaponsBasePath = 'assets/weapons';
  static String bowsBasePath = '$weaponsBasePath/bows';
  static String catalystBasePath = '$weaponsBasePath/catalysts';
  static String claymoresBasePath = '$weaponsBasePath/claymores';
  static String polearmsBasePath = '$weaponsBasePath/polearms';
  static String swordsBasePath = '$weaponsBasePath/swords';

  //Items
  static String itemsBasePath = 'assets/items';
  static String commonBasePath = '$itemsBasePath/common';
  static String elementalBasePath = '$itemsBasePath/elemental';
  static String jewelsBasePath = '$itemsBasePath/jewels';
  static String localBasePath = '$itemsBasePath/local';
  static String talentBasePath = '$itemsBasePath/talents';
  static String weaponBasePath = '$itemsBasePath/weapon';
  static String weaponPrimaryBasePath = '$itemsBasePath/weapon_primary';
  static String currencyBasePath = '$itemsBasePath/currency';
  static String othersBasePath = '$itemsBasePath/others';

  static String getArtifactPath(String name) => '$artifactsBasePath/$name';
  static String getCharacterPath(String name) => '$charactersBasePath/$name';
  static String getCharacterFullPath(String name) => '$characterFullBasePath/$name';
  static String getSkillPath(String name) {
    var skill = name;
    if (name.isNullEmptyOrWhitespace) {
      skill = noImageAvailableName;
    }
    return '$skillsBasePath/$skill';
  }

  static String getBowPath(String name) => '$bowsBasePath/$name';
  static String getCatalystPath(String name) => '$catalystBasePath/$name';
  static String getClaymorePath(String name) => '$claymoresBasePath/$name';
  static String getPolearmPath(String name) => '$polearmsBasePath/$name';
  static String getSwordPath(String name) => '$swordsBasePath/$name';

  static String getCommonMaterialPath(String name) => '$commonBasePath/$name';
  static String getElementalMaterialPath(String name) => '$elementalBasePath/$name';
  static String getJewelMaterialPath(String name) => '$jewelsBasePath/$name';
  static String getLocalMaterialPath(String name) => '$localBasePath/$name';
  static String getTalentMaterialPath(String name) => '$talentBasePath/$name';
  static String getWeaponMaterialPath(String name) => '$weaponBasePath/$name';
  static String getWeaponPrimaryMaterialPath(String name) => '$weaponPrimaryBasePath/$name';
  static String getCurrencyMaterialPath(String name) => '$currencyBasePath/$name';
  static String getOtherMaterialPath(String name) => '$othersBasePath/$name';

  static String getMaterialPath(String name, MaterialType type) {
    switch (type) {
      case MaterialType.common:
        return getCommonMaterialPath(name);
      case MaterialType.currency:
        return getCurrencyMaterialPath(name);
      case MaterialType.elemental:
        return getElementalMaterialPath(name);
      case MaterialType.jewels:
        return getJewelMaterialPath(name);
      case MaterialType.local:
        return getLocalMaterialPath(name);
      case MaterialType.talents:
        return getTalentMaterialPath(name);
      case MaterialType.weapon:
        return getWeaponMaterialPath(name);
      case MaterialType.weaponPrimary:
        return getWeaponPrimaryMaterialPath(name);
      case MaterialType.others:
        return getOtherMaterialPath(name);
      default:
        throw Exception('Invalid material type = $type');
    }
  }

  static String getTranslationPath(AppLanguageType languageType) {
    switch (languageType) {
      case AppLanguageType.english:
        return '$translationsBasePath/en.json';
      case AppLanguageType.spanish:
        return '$translationsBasePath/es.json';
      case AppLanguageType.french:
        return '$translationsBasePath/fr.json';
      default:
        throw Exception('Invalid language = $languageType');
    }
  }

  static String getWeaponPath(String name, WeaponType type) {
    switch (type) {
      case WeaponType.bow:
        return getBowPath(name);
      case WeaponType.catalyst:
        return getCatalystPath(name);
      case WeaponType.claymore:
        return getClaymorePath(name);
      case WeaponType.polearm:
        return getPolearmPath(name);
      case WeaponType.sword:
        return getSwordPath(name);
      default:
        throw Exception('Invalid language = $type');
    }
  }

  static String getElementPath(String name) => '$elementsBasePath/$name';

  static String getElementPathFromType(ElementType type) {
    switch (type) {
      case ElementType.anemo:
        return getElementPath('anemo.png');
      case ElementType.cryo:
        return getElementPath('cryo.png');
      case ElementType.dendro:
        return getElementPath('dendro.png');
      case ElementType.electro:
        return getElementPath('electro.png');
      case ElementType.geo:
        return getElementPath('geo.png');
      case ElementType.hydro:
        return getElementPath('hydro.png');
      case ElementType.pyro:
        return getElementPath('pyro.png');
      default:
        throw Exception('Invalid element type = $type');
    }
  }

  static ElementType getElementTypeFromPath(String path) {
    return ElementType.values.firstWhere((type) => getElementPathFromType(type) == path);
  }

  static String getArtifactPathFromType(ArtifactType type) {
    switch (type) {
      case ArtifactType.clock:
        return getMaterialPath('clock.png', MaterialType.others);
      case ArtifactType.crown:
        return getMaterialPath('crown.png', MaterialType.others);
      case ArtifactType.flower:
        return getMaterialPath('flower.png', MaterialType.others);
      case ArtifactType.goblet:
        return getMaterialPath('goblet.png', MaterialType.others);
      case ArtifactType.plume:
        return getMaterialPath('plume.png', MaterialType.others);
      default:
        throw Exception('Invalid artifact type = $type');
    }
  }
}
