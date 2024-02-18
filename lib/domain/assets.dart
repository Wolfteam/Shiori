import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';

class Assets {
  static String elementsBasePath = 'assets/elements';
  static String otherImgsBasePath = 'assets/others';
  static String weaponTypesBasePath = 'assets/weapon_types';
  static String weaponNormalSkillTypesPath = 'assets/weapon_normal_skill_types';

  static String noImageAvailablePath = '$otherImgsBasePath/na$imageFileExtension';
  static String paimonImagePath = '$otherImgsBasePath/paimon$imageFileExtension';
  static String bagIconPath = '$otherImgsBasePath/bag$imageFileExtension';
  static String monsterIconPath = '$otherImgsBasePath/monster$imageFileExtension';
  static String cakeIconPath = '$otherImgsBasePath/cake$imageFileExtension';
  static String gachaIconPath = '$otherImgsBasePath/gacha$imageFileExtension';
  static String starCrystalIconPath = '$otherImgsBasePath/mark_wind_crystal$imageFileExtension';
  static String primogemIconPath = '$otherImgsBasePath/primogem$imageFileExtension';
  static String wishBannerBackgroundImgPath = '$otherImgsBasePath/wish_banner_background$imageFileExtension';
  static String wishBannerButtonBackgroundImgPath = '$otherImgsBasePath/wish_banner_button$imageFileExtension';
  static String wishBannerStandardImgPath = '$otherImgsBasePath/wish_banner_standard$imageFileExtension';
  static String wishBannerResultBackgroundImgPath = '$otherImgsBasePath/wish_banner_wish_result_background.webp';
  static String wishBannerItemResultBackgroundImgPath = '$otherImgsBasePath/wish_banner_wish_result_item_background.webp';

  static String _getElementPath(String name) => '$elementsBasePath/$name';

  static String _getElementImagePath(ElementType type, String imageSuffix) {
    switch (type) {
      case ElementType.anemo:
        return _getElementPath('anemo$imageSuffix');
      case ElementType.cryo:
        return _getElementPath('cryo$imageSuffix');
      case ElementType.dendro:
        return _getElementPath('dendro$imageSuffix');
      case ElementType.electro:
        return _getElementPath('electro$imageSuffix');
      case ElementType.geo:
        return _getElementPath('geo$imageSuffix');
      case ElementType.hydro:
        return _getElementPath('hydro$imageSuffix');
      case ElementType.pyro:
        return _getElementPath('pyro$imageSuffix');
      default:
        throw Exception('Invalid element type = $type');
    }
  }

  static String getElementPathFromType(ElementType type) => _getElementImagePath(type, imageFileExtension);

  static String getElementWhitePathFromType(ElementType type) => _getElementImagePath(type, '_white$imageFileExtension');

  static String getElementBlackPathFromType(ElementType type) => _getElementImagePath(type, '_black$imageFileExtension');

  static ElementType getElementTypeFromPath(String path) {
    return ElementType.values.firstWhere((type) => getElementPathFromType(type) == path);
  }

  static String getArtifactPathFromType(ArtifactType type) {
    switch (type) {
      case ArtifactType.clock:
        return '$otherImgsBasePath/clock$imageFileExtension';
      case ArtifactType.crown:
        return '$otherImgsBasePath/crown$imageFileExtension';
      case ArtifactType.flower:
        return '$otherImgsBasePath/flower$imageFileExtension';
      case ArtifactType.goblet:
        return '$otherImgsBasePath/goblet$imageFileExtension';
      case ArtifactType.plume:
        return '$otherImgsBasePath/plume$imageFileExtension';
      default:
        throw Exception('Invalid artifact type = $type');
    }
  }

  static String getWeaponTypePath(WeaponType type) {
    switch (type) {
      case WeaponType.bow:
        return '$weaponTypesBasePath/bow$imageFileExtension';
      case WeaponType.catalyst:
        return '$weaponTypesBasePath/catalyst$imageFileExtension';
      case WeaponType.claymore:
        return '$weaponTypesBasePath/claymore$imageFileExtension';
      case WeaponType.polearm:
        return '$weaponTypesBasePath/polearm$imageFileExtension';
      case WeaponType.sword:
        return '$weaponTypesBasePath/sword$imageFileExtension';
      default:
        throw Exception('Invalid weapon type = $type');
    }
  }

  static String getWeaponSkillAssetPath(WeaponType type) {
    switch (type) {
      case WeaponType.bow:
        return '$weaponNormalSkillTypesPath/bow$imageFileExtension';
      case WeaponType.catalyst:
        return '$weaponNormalSkillTypesPath/catalyst$imageFileExtension';
      case WeaponType.claymore:
        return '$weaponNormalSkillTypesPath/claymore$imageFileExtension';
      case WeaponType.polearm:
        return '$weaponNormalSkillTypesPath/polearm$imageFileExtension';
      case WeaponType.sword:
        return '$weaponNormalSkillTypesPath/sword$imageFileExtension';
      default:
        throw Exception('Invalid weapon type = $type');
    }
  }
}
