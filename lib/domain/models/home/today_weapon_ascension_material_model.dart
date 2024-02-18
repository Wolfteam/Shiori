import 'package:shiori/domain/models/models.dart';

class TodayWeaponAscensionMaterialModel {
  final String key;
  final String name;
  final String image;
  final List<int> days;
  final List<ItemCommonWithName> weapons;
  TodayWeaponAscensionMaterialModel({
    required this.key,
    required this.name,
    required this.image,
    required this.days,
    required this.weapons,
  });
}
