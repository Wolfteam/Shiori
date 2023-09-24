import 'package:flutter/material.dart';

class TransformTapScale extends StatefulWidget {
  final GestureTapCallback onTap;
  final Widget child;

  const TransformTapScale({
    required this.onTap,
    required this.child,
  });

  @override
  State<TransformTapScale> createState() => TransformTapScaleState();
}

class TransformTapScaleState extends State<TransformTapScale> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapUp: (details) => _buttonReleased(),
      onTapDown: (details) => _buttonPressed(),
      onTapCancel: () => _buttonReleased(),
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }

  void _buttonPressed() => setState(() {
        _scale = 0.9;
      });

  void _buttonReleased() => setState(() {
        _scale = 1;
      });
}
