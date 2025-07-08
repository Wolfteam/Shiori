import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class CommonButtonBar extends StatelessWidget {
  final List<Widget> children;
  final WrapAlignment alignment;
  final double? runSpacing;
  final double spacing;

  const CommonButtonBar({
    super.key,
    required this.children,
    this.alignment = WrapAlignment.end,
    this.runSpacing,
    this.spacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    final forEndDrawer = getDeviceType(MediaQuery.of(context).size) != DeviceScreenType.mobile;
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Wrap(
        alignment: alignment,
        spacing: spacing,
        runSpacing: runSpacing != null
            ? runSpacing!
            : forEndDrawer
            ? 10
            : 0,
        children: children,
      ),
    );
  }
}
