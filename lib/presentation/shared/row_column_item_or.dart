import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';

class RowColumnItemOr extends StatelessWidget {
  final Widget widget;
  final Color color;
  final bool useColumn;
  final EdgeInsets? margin;
  final double? radius;

  const RowColumnItemOr({
    super.key,
    required this.widget,
    required this.color,
    this.useColumn = false,
    this.margin,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: useColumn
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [widget, _OrWidget(color: color, radius: radius)],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [widget, _OrWidget(color: color, radius: radius)],
            ),
    );
  }
}

class _OrWidget extends StatelessWidget {
  final Color color;
  final double? radius;

  const _OrWidget({
    required this.color,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return CircleAvatar(
      backgroundColor: color,
      radius: radius,
      child: Text(
        s.or,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
