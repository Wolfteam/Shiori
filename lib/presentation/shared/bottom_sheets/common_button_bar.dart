import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/presentation/shared/styles.dart';

class CommonButtonBar extends StatelessWidget {
  final List<Widget> children;
  final WrapAlignment alignment;
  final EdgeInsets margin;
  final double? runSpacing;
  final double spacing;

  const CommonButtonBar({
    super.key,
    required this.children,
    this.alignment = WrapAlignment.end,
    this.margin = Styles.edgeInsetVertical5,
    this.runSpacing,
    this.spacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    final forEndDrawer = getDeviceType(MediaQuery.of(context).size) != DeviceScreenType.mobile;

    return Container(
      margin: margin,
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
