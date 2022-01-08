import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';

class SubStatToFocus extends StatelessWidget {
  final List<StatType> subStatsToFocus;
  final Color color;
  final EdgeInsetsGeometry margin;
  final double fontSize;

  const SubStatToFocus({
    Key? key,
    required this.subStatsToFocus,
    required this.color,
    this.margin = Styles.edgeInsetHorizontal5,
    this.fontSize = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final text = subStatsToFocus.map((e) => s.translateStatTypeWithoutValue(e)).join(' > ');
    return Container(
      margin: margin,
      child: Text(
        '${s.subStats}: $text',
        style: theme.textTheme.subtitle2!.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
