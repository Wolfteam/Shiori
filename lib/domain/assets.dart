import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';

class Assets {
  static String elementsBasePath = 'assets/elements';
  static String otherImgsBasePath = 'assets/others';
  static String weaponTypesBasePath = 'assets/weapon_types';

  static String noImageAvailablePath = '$otherImgsBasePath/na$imageFileExtension';
  static String paimonImagePath = '$otherImgsBasePath/paimon$imageFileExtension';
  static String bagIconPath = '$otherImgsBasePath/bag$imageFileExtension';
  static String monsterIconPath = '$otherImgsBasePath/monster$imageFileExtension';
  static String cakeIconPath = '$otherImgsBasePath/cake$imageFileExtension';
  static String gachaIconPath = '$otherImgsBasePath/gacha$imageFileExtension';
  static String starCrystalIconPath = '$otherImgsBasePath/mark_wind_crystal$imageFileExtension';
  static String primogemIconPath = '$otherImgsBasePath/primogem$imageFileExtension';
  static String wishBannerBackgroundImgPath = '$otherImgsBasePath/wish_banner$imageFileExtension';
  static String wishBannerButtonBackgroundImgPath = '$otherImgsBasePath/wish_banner_button$imageFileExtension';

  static String testVentiImgPath = '$otherImgsBasePath/venti_icon$imageFileExtension';
  static String testGanyuImgPath = '$otherImgsBasePath/ganyu_icon$imageFileExtension';

  static List<String> test = [
    '$otherImgsBasePath/1c$imageFileExtension',
    '$otherImgsBasePath/2c$imageFileExtension',
    '$otherImgsBasePath/1w$imageFileExtension',
    '$otherImgsBasePath/2w$imageFileExtension'
  ];

  static String _getElementPath(String name) => '$elementsBasePath/$name';

  static String getElementPathFromType(ElementType type) {
    switch (type) {
      case ElementType.anemo:
        return _getElementPath('anemo$imageFileExtension');
      case ElementType.cryo:
        return _getElementPath('cryo$imageFileExtension');
      case ElementType.dendro:
        return _getElementPath('dendro$imageFileExtension');
      case ElementType.electro:
        return _getElementPath('electro$imageFileExtension');
      case ElementType.geo:
        return _getElementPath('geo$imageFileExtension');
      case ElementType.hydro:
        return _getElementPath('hydro$imageFileExtension');
      case ElementType.pyro:
        return _getElementPath('pyro$imageFileExtension');
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
}
