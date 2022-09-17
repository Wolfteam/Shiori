import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';

class HorizontalBarDataModel {
  final int index;
  final Color color;
  final List<Point<double>> points;

  HorizontalBarDataModel(this.index, this.color, this.points);
}

typedef CanValueBeRendered = bool Function(double);
typedef OnPointTap = void Function(double);
typedef GetText = String Function(double);

class HorizontalBarChart extends StatelessWidget {
  final List<HorizontalBarDataModel> items;

  final CanValueBeRendered canValueBeRendered;
  final OnPointTap? onPointTap;
  final GetText getBottomText;
  final GetText getLeftText;
  final GetLineTooltipItems? getTooltipItems;

  final double yIntervals;
  final double xIntervals;

  final double minX;
  final double minY;

  final double barWidth;

  final Color? toolTipBgColor;

  final int bottomTextMaxLength;
  final int leftTextMaxLength;

  const HorizontalBarChart({
    Key? key,
    required this.items,
    required this.canValueBeRendered,
    this.onPointTap,
    required this.getBottomText,
    required this.getLeftText,
    this.getTooltipItems,
    this.xIntervals = 0.10,
    this.yIntervals = 1.0,
    this.minX = 0,
    this.minY = 0,
    this.barWidth = 4,
    this.toolTipBgColor,
    this.bottomTextMaxLength = 10,
    this.leftTextMaxLength = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = items.expand((el) => el.points);
    final maxY = points.map((e) => e.y).reduce(max) + 1;
    final maxX = points.map((e) => e.x).reduce(max);
    return Padding(
      padding: Styles.edgeInsetAll10,
      child: LineChart(
        LineChartData(
          minX: minX,
          minY: minY,
          maxX: maxX,
          maxY: maxY,
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchCallback: (event, response) {
              if (event is FlTapUpEvent && response?.lineBarSpots != null && response!.lineBarSpots!.isNotEmpty) {
                onPointTap?.call(response.lineBarSpots!.first.x);
              }
            },
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: toolTipBgColor ?? theme.backgroundColor,
              fitInsideHorizontally: true,
              getTooltipItems: getTooltipItems,
            ),
          ),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: xIntervals,
                getTitlesWidget: (value, meta) => _BottomTitle(getBottomText: getBottomText, bottomTextMaxLength: bottomTextMaxLength, value: value),
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                getTitlesWidget: (value, meta) => _LeftTitle(getLeftText: getLeftText, leftTextMaxLength: leftTextMaxLength, value: value),
                showTitles: true,
                interval: yIntervals,
                reservedSize: 40,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: items
              .map(
                (e) => LineChartBarData(
                  isCurved: false,
                  color: e.color,
                  barWidth: barWidth,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                  spots: e.points.map((e) {
                    if (!canValueBeRendered(e.x)) {
                      return FlSpot.nullSpot;
                    }
                    return FlSpot(e.x, e.y);
                  }).toList(),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _BottomTitle extends StatelessWidget {
  final GetText getBottomText;
  final double value;
  final int bottomTextMaxLength;
  const _BottomTitle({
    Key? key,
    required this.getBottomText,
    required this.value,
    required this.bottomTextMaxLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = getBottomText(value);
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Tooltip(
        message: text,
        child: Text(
          text.substringIfOverflow(bottomTextMaxLength),
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _LeftTitle extends StatelessWidget {
  final GetText getLeftText;
  final double value;
  final int leftTextMaxLength;

  const _LeftTitle({
    Key? key,
    required this.getLeftText,
    required this.value,
    required this.leftTextMaxLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = getLeftText(value);
    return Tooltip(
      message: text,
      child: Text(
        text.substringIfOverflow(leftTextMaxLength),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
