import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';

typedef OnBarChartTap = void Function(int);

class VerticalBarChart extends StatelessWidget {
  final List<ChartBirthdayMonthModel> items;
  final List<String> months;
  final OnBarChartTap? onBarChartTap;

  const VerticalBarChart({
    Key? key,
    required this.items,
    required this.months,
    this.onBarChartTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = items.map((e) => e.items.length);
    final maxValue = values.reduce(max).toDouble() + 1;
    final interval = (maxValue / 5).roundToDouble();

    const textStyle = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    //TODO: TOOLTIP COLOR
    //TODO: HIGHLIGHT THE CURRENT BAR
    //TODO: MOVE THE BIRTHDAY LOGIC OUT OF HERE
    return BarChart(
      BarChartData(
        maxY: maxValue,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: theme.backgroundColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              rod.toY.toInt().toString(),
              const TextStyle(color: Colors.white),
            ),
          ),
          touchCallback: (FlTouchEvent event, response) {
            if (event is FlTapUpEvent && response?.spot?.touchedBarGroupIndex != null) {
              onBarChartTap?.call(response!.spot!.touchedBarGroupIndex);
            }
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  months[value.toInt() - 1],
                  textAlign: TextAlign.center,
                  style: textStyle,
                ),
              ),
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: interval,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: items
            .map(
              (e) => BarChartGroupData(
                x: e.month,
                barRods: [
                  BarChartRodData(
                    toY: e.items.length.toDouble(),
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.zero,
                    width: 10,
                  ),
                ],
              ),
            )
            .toList(),
        gridData: FlGridData(show: true),
      ),
    );
  }
}
