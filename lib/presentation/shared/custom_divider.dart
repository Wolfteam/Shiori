import 'dart:math';

import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color color;

  const CustomDivider({
    this.height = 10,
    this.thickness = 0.3,
    this.indent = 0,
    this.endIndent = 0,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Container(
        height: thickness,
        margin: EdgeInsetsDirectional.only(start: indent, end: endIndent),
        child: CustomPaint(
          painter: _DividerPainter(color: color),
        ),
      ),
    );
  }
}

class _DividerPainter extends CustomPainter {
  final Color color;
  final Paint shapePaint;
  final Paint linePaint;

  _DividerPainter({required this.color})
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
    final startPointX = size.width * 0.05;
    final endPointX = size.width * 0.95;

    const int sides = 4;
    const double radius = 5;
    const double angle = (2 * pi) / sides;
    final angles = List.generate(sides, (index) => index * angle);

    final Path leftShape = _drawShape(startPointX, center.dy, radius, angles);
    final Path rightShape = _drawShape(endPointX, center.dy, radius, angles);
    final Path linePath = Path();
    linePath.moveTo(startPointX + radius, center.dy);
    linePath.lineTo(endPointX - radius, center.dy);
    canvas.drawPath(leftShape, shapePaint);
    canvas.drawPath(linePath, linePaint);
    canvas.drawPath(rightShape, shapePaint);
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
