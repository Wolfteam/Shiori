import 'package:flutter/material.dart';

class ChildItemDisabled extends StatelessWidget {
  final Widget child;
  final bool isDisabled;

  const ChildItemDisabled({
    Key? key,
    required this.child,
    this.isDisabled = true,
  }) : super(key: key);

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
