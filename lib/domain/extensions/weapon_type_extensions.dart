import '../assets.dart';
import '../enums/weapon_type.dart';

extension WeaponTypeExtension on WeaponType {
  String getWeaponAssetPath() {
    return Assets.getWeaponTypePath(this);
  }
}
