import 'package:flutter/material.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/presentation/shared/custom_divider.dart';
import 'package:shiori/presentation/shared/styles.dart';

class DetailSection extends StatelessWidget {
  final String title;
  final Color color;
  final String? description;
  final List<Widget> children;
  final EdgeInsets margin;

  DetailSection({
    required this.title,
    required this.color,
    this.description,
    this.margin = Styles.edgeInsetVertical5,
  }) : children = <Widget>[];

  const DetailSection.complex({
    required this.title,
    required this.color,
    required this.children,
    this.description,
    this.margin = Styles.edgeInsetVertical5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall!.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          CustomDivider(color: color),
          if (description.isNotNullEmptyOrWhitespace)
            Padding(
              padding: Styles.edgeInsetHorizontal10,
              child: Text(description!),
            ),
          ...children.map(
            (e) => Padding(
              padding: Styles.edgeInsetHorizontal10,
              child: e,
            ),
          ),
        ],
      ),
    );
  }
}
