import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

class CustomBuildModel {
  final int key;
  final String title;

  final CharacterRoleType type;
  final CharacterRoleSubType subType;
  final bool showOnCharacterDetail;

  final CharacterCardModel character;
  final List<WeaponCardModel> weapons;
  final List<ArtifactCardModel> artifacts;

  CustomBuildModel({
    required this.key,
    required this.title,
    required this.type,
    required this.subType,
    required this.showOnCharacterDetail,
    required this.character,
    required this.weapons,
    required this.artifacts,
  });
}
