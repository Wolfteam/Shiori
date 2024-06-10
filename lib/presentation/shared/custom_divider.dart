import 'dart:math';

import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color color;
  final bool drawShape;

  const CustomDivider({
    this.height = 10,
    this.thickness = 0.3,
    this.indent = 10,
    this.endIndent = 10,
    this.color = Colors.white,
    this.drawShape = true,
  });

  const CustomDivider.zeroIndent({
    this.height = 10,
    this.thickness = 0.3,
    this.color = Colors.white,
    this.drawShape = true,
  })  : indent = 0,
        endIndent = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Container(
        height: thickness,
        margin: EdgeInsetsDirectional.only(start: indent, end: endIndent),
        child: CustomPaint(
          painter: _DividerPainter(color: color, drawShape: drawShape),
        ),
      ),
    );
  }
}

class _DividerPainter extends CustomPainter {
  final Color color;
  final Paint shapePaint;
  final Paint linePaint;
  final bool drawShape;

  _DividerPainter({required this.color, required this.drawShape})
      : shapePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..color = color,
        linePaint = Paint()
          ..style = PaintingStyle.stroke
          ..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const double startPointX = 0;
    final double endPointX = size.width;

    const int sides = 4;
    const double radius = 5;
    const double angle = (2 * pi) / sides;
    final angles = List.generate(sides, (index) => index * angle);

    final Path leftShape = _drawShape(startPointX, center.dy, radius, angles);
    final Path rightShape = _drawShape(endPointX, center.dy, radius, angles);
    final Path linePath = Path();
    linePath.moveTo(startPointX + radius, center.dy);
    linePath.lineTo(endPointX - radius, center.dy);
    if (drawShape) {
      canvas.drawPath(leftShape, shapePaint);
    }
    canvas.drawPath(linePath, linePaint);
    if (drawShape) {
      canvas.drawPath(rightShape, shapePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  Path _drawShape(double dx, double dy, double radius, List<double> angles) {
    final path = Path();
    path.moveTo(
      dx + radius * cos(0),
      dy + radius * sin(0),
    );

    for (final double angle in angles) {
      path.lineTo(
        dx + radius * cos(angle),
        dy + radius * sin(angle),
      );
    }
    path.close();
    return path;
  }
}
