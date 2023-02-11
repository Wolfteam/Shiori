import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/styles.dart';

class MainTitle extends StatelessWidget {
  final String title;

  const MainTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: Styles.edgeInsetHorizontal16,
      child: Text(
        title,
        style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
