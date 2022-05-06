import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/styles.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? bottom;
  final double height;
  final double width;

  const ChartCard({
    Key? key,
    required this.title,
    required this.child,
    required this.width,
    required this.height,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: Styles.cardShape,
      child: Padding(
        padding: Styles.edgeInsetAll10,
        child: SizedBox(
          height: height,
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Text(
                  title,
                  style: theme.textTheme.headline6,
                ),
              ),
              Expanded(child: child),
              if (bottom != null) bottom!,
            ],
          ),
        ),
      ),
    );
  }
}
