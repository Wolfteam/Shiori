import '../../enums/enums.dart';

class CharacterCardModel {
  final String key;
  final String logoName;
  final String name;
  final int stars;
  final WeaponType weaponType;
  final ElementType elementType;
  final bool isNew;
  final bool isComingSoon;
  final List<String> materials;
  final CharacterRoleType roleType;

  const CharacterCardModel({
    required this.key,
    required this.logoName,
    required this.name,
    required this.stars,
    required this.weaponType,
    required this.elementType,
    required this.materials,
    required this.roleType,
    this.isNew = false,
    this.isComingSoon = false,
  });
}
