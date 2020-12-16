import '../assets.dart';
import '../enums/weapon_type.dart';

extension WeaponTypeExtension on WeaponType {
  String getWeaponAssetPath() {
    switch (this) {
      case WeaponType.bow:
        return Assets.getWeaponPath('amos_bow.png', this);
      case WeaponType.sword:
        return Assets.getWeaponPath('skyward_blade.png', this);
      case WeaponType.catalyst:
        return Assets.getWeaponPath('lost_prayer_to_the_sacred_winds.png', this);
      case WeaponType.claymore:
        return Assets.getWeaponPath('wolfs_gravestone.png', this);
      case WeaponType.polearm:
        return Assets.getWeaponPath('skyward_spine.png', this);
      default:
        throw Exception('Invalid weapon type = ${this}');
    }
  }
}
