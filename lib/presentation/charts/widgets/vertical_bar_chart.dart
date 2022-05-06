import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

typedef OnBarChartTap = void Function(int);
typedef GetText = String Function(double);

class VerticalBarDataModel {
  final int index;
  final Color color;
  final int x;
  final double y;

  VerticalBarDataModel(this.index, this.color, this.x, this.y);
}

class VerticalBarChart extends StatelessWidget {
  final List<VerticalBarDataModel> items;
  final OnBarChartTap? onBarChartTap;
  final GetText getBottomText;
  final GetText getLeftText;

  final double maxY;
  final double interval;

  final Color? tooltipColor;

  const VerticalBarChart({
    Key? key,
    required this.items,
    required this.getLeftText,
    required this.getBottomText,
    this.onBarChartTap,
    required this.maxY,
    required this.interval,
    this.tooltipColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const textStyle = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            tooltipBgColor: tooltipColor ?? theme.backgroundColor,
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
                  getBottomText(value),
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
                getLeftText(value),
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
                x: e.x,
                barRods: [
                  BarChartRodData(
                    toY: e.y,
                    color: e.color,
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
