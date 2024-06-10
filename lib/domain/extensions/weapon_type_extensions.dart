import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';

extension WeaponTypeExtension on WeaponType {
  String getWeaponAssetPath() {
    return Assets.getWeaponTypePath(this);
  }

  String getWeaponNormalSkillAssetPath() {
    return Assets.getWeaponSkillAssetPath(this);
  }
}
