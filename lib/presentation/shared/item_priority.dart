import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/styles.dart';

class ItemPriority<TEnum> extends StatelessWidget {
  final String title;
  final List<TEnum> items;
  final Color color;
  final EdgeInsetsGeometry margin;
  final double fontSize;
  final String Function(TEnum item) textResolver;

  const ItemPriority({
    Key? key,
    required this.title,
    required this.items,
    required this.color,
    required this.textResolver,
    this.margin = Styles.edgeInsetHorizontal5,
    this.fontSize = 12,
  })  : assert(items.length > 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = items.map((e) => textResolver(e)).join(' > ');
    return Container(
      margin: margin,
      child: Text(
        '$title: $text',
        style: theme.textTheme.subtitle2!.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
