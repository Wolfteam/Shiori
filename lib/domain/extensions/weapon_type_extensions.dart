import 'package:shiori/domain/app_constants.dart';

import '../assets.dart';
import '../enums/weapon_type.dart';

extension WeaponTypeExtension on WeaponType {
  String getWeaponAssetPath() {
    switch (this) {
      case WeaponType.bow:
        return Assets.getWeaponPath('amos-bow$imageFileExtension', this);
      case WeaponType.sword:
        return Assets.getWeaponPath('skyward-blade$imageFileExtension', this);
      case WeaponType.catalyst:
        return Assets.getWeaponPath('lost-prayer-to-the-sacred-winds$imageFileExtension', this);
      case WeaponType.claymore:
        return Assets.getWeaponPath('wolfs-gravestone$imageFileExtension', this);
      case WeaponType.polearm:
        return Assets.getWeaponPath('skyward-spine$imageFileExtension', this);
      default:
        throw Exception('Invalid weapon type = ${this}');
    }
  }
}
