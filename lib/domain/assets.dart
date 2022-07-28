import 'enums/enums.dart';

class Assets {
  static String elementsBasePath = 'assets/elements';
  static String otherImgsBasePath = 'assets/others';
  static String weaponTypesBasePath = 'assets/weapon_types';
  static String noImageAvailablePath = '$otherImgsBasePath/na.png';
  static String paimonImagePath = '$otherImgsBasePath/paimon.png';

  static String _getElementPath(String name) => '$elementsBasePath/$name';

  static String getElementPathFromType(ElementType type) {
    switch (type) {
      case ElementType.anemo:
        return _getElementPath('anemo.png');
      case ElementType.cryo:
        return _getElementPath('cryo.png');
      case ElementType.dendro:
        return _getElementPath('dendro.png');
      case ElementType.electro:
        return _getElementPath('electro.png');
      case ElementType.geo:
        return _getElementPath('geo.png');
      case ElementType.hydro:
        return _getElementPath('hydro.png');
      case ElementType.pyro:
        return _getElementPath('pyro.png');
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
        return '$otherImgsBasePath/clock.png';
      case ArtifactType.crown:
        return '$otherImgsBasePath/crown.png';
      case ArtifactType.flower:
        return '$otherImgsBasePath/flower.png';
      case ArtifactType.goblet:
        return '$otherImgsBasePath/goblet.png';
      case ArtifactType.plume:
        return '$otherImgsBasePath/plume.png';
      default:
        throw Exception('Invalid artifact type = $type');
    }
  }

  static String getWeaponTypePath(WeaponType type) {
    switch (type) {
      case WeaponType.bow:
        return '$weaponTypesBasePath/bow.png';
      case WeaponType.catalyst:
        return '$weaponTypesBasePath/catalyst.png';
      case WeaponType.claymore:
        return '$weaponTypesBasePath/claymore.png';
      case WeaponType.polearm:
        return '$weaponTypesBasePath/polearm.png';
      case WeaponType.sword:
        return '$weaponTypesBasePath/sword.png';
      default:
        throw Exception('Invalid weapon type = $type');
    }
  }

  static String getBagIconPath() => '$otherImgsBasePath/bag.png';

  static String getMonsterIconPath() => '$otherImgsBasePath/monster.png';

  static String getCakeIconPath() => '$otherImgsBasePath/cake.png';

  static String getGachaIconPath() => '$otherImgsBasePath/gacha.png';

  static String getStarCrystalIconPath() => '$otherImgsBasePath/mark_wind_crystal.png';

  static String getPrimogemIconPath() => '$otherImgsBasePath/primogem.png';
}
