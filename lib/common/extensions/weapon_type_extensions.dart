import '../enums/weapon_type.dart';

extension WeaponTypeExtension on WeaponType {
  String getWeaponAssetPath() {
    const basePath = "assets/weapons";
    switch (this) {
      case WeaponType.bow:
        return "$basePath/bow.png";
      case WeaponType.sword:
        return "$basePath/sword.png";
      case WeaponType.catalyst:
        return "$basePath/catalyst.png";
      case WeaponType.claymore:
        return "$basePath/claymore.png";
      case WeaponType.polearm:
        return "$basePath/polearm.png";
      default:
        throw Exception('Invalid weapon type = ${this}');
    }
  }
}
