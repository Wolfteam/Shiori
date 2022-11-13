import 'package:flutter/material.dart';

class ChildItemDisabled extends StatelessWidget {
  final Widget child;
  final bool isDisabled;

  const ChildItemDisabled({
    super.key,
    required this.child,
    this.isDisabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isDisabled) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Colors.grey,
          BlendMode.saturation,
        ),
        child: child,
      );
    }

    return child;
  }
}
