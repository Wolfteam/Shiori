import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/item_priority.dart';
import 'package:shiori/presentation/shared/styles.dart';

class CharacterSkillPriority extends StatelessWidget {
  final List<CharacterSkillType> skillPriorities;
  final Color color;
  final EdgeInsetsGeometry margin;
  final double fontSize;

  const CharacterSkillPriority({
    Key? key,
    required this.skillPriorities,
    required this.color,
    this.margin = Styles.edgeInsetHorizontal5,
    this.fontSize = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ItemPriority<CharacterSkillType>(
      title: s.talentsAscension,
      items: skillPriorities,
      color: color,
      textResolver: (e) => s.translateCharacterSkillType(e),
      margin: margin,
      fontSize: fontSize,
    );
  }
}
