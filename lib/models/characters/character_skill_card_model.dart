import 'package:flutter/widgets.dart';

class CharacterSkillCardModel {
  final String image;
  final String skillTitle;
  final String skillSubTitle;
  final String description;
  final Map<String, String> abilities;

  CharacterSkillCardModel({
    @required this.image,
    @required this.skillTitle,
    @required this.skillSubTitle,
    this.description = '',
    @required this.abilities,
  });
}
