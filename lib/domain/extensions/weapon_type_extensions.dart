import '../assets.dart';
import '../enums/weapon_type.dart';

extension WeaponTypeExtension on WeaponType {
  String getWeaponAssetPath() {
    switch (this) {
      case WeaponType.bow:
        return Assets.getWeaponPath('amos-bow.png', this);
      case WeaponType.sword:
        return Assets.getWeaponPath('skyward-blade.png', this);
      case WeaponType.catalyst:
        return Assets.getWeaponPath('lost-prayer-to-the-sacred-winds.png', this);
      case WeaponType.claymore:
        return Assets.getWeaponPath('wolfs-gravestone.png', this);
      case WeaponType.polearm:
        return Assets.getWeaponPath('skyward-spine.png', this);
      default:
        throw Exception('Invalid weapon type = ${this}');
    }
  }
}
