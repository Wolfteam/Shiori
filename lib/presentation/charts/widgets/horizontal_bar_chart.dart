import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';

class HorizontalBarChart extends StatelessWidget {
  final List<ChartElementItemModel> items;

  const HorizontalBarChart({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = items.expand((el) => el.points);
    final maxY = points.map((e) => e.y).reduce(max) + 1;
    final maxX = points.map((e) => e.x).reduce(max);
    //TODO: THESE VALUES
    final yIntervals = 1.0;
    final xIntervals = 0.1;
    return Padding(
      padding: Styles.edgeInsetAll10,
      child: LineChart(
        LineChartData(
          minX: 0,
          minY: 0,
          maxX: maxX,
          maxY: maxY,
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: theme.backgroundColor,
            ),
          ),
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: xIntervals,
                //TODO: TOOLTIPS
                getTitlesWidget: (value, meta) => value + 1 >= 1.7 && value + 1 < 2
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          (value + 1).toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
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
                  isCurved: true,
                  color: e.type.getElementColorFromContext(context),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                  spots: e.points.map((e) => FlSpot(e.x, e.y)).toList(),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
