import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/item_priority.dart';
import 'package:shiori/presentation/shared/styles.dart';

class SubStatToFocus extends StatelessWidget {
  final List<StatType> subStatsToFocus;
  final Color color;
  final EdgeInsetsGeometry margin;
  final double fontSize;

  const SubStatToFocus({
    super.key,
    required this.subStatsToFocus,
    required this.color,
    this.margin = Styles.edgeInsetHorizontal5,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ItemPriority<StatType>(
      title: s.subStats,
      items: subStatsToFocus,
      color: color,
      textResolver: (e) => s.translateStatTypeWithoutValue(e),
      margin: margin,
      fontSize: fontSize,
    );
  }
}
