import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';

typedef OnSectionTap = void Function(ChartTopItemModel);

class TopPieChart extends StatelessWidget {
  final List<ChartTopItemModel> items;
  final List<Color> colors;
  final double radius;
  final OnSectionTap? onSectionTap;

  const TopPieChart({
    Key? key,
    required this.items,
    required this.colors,
    this.radius = 110,
    this.onSectionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        centerSpaceRadius: 0,
        startDegreeOffset: -90,
        pieTouchData: PieTouchData(
          enabled: true,
          touchCallback: _handleTap,
        ),
        sections: List.generate(
          items.length,
          (index) {
            final item = items[index];
            return PieChartSectionData(
              color: colors[index],
              value: item.percentage,
              title: '${item.value}',
              radius: radius,
              showTitle: true,
              titlePositionPercentageOffset: 0.8,
              titleStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleTap(FlTouchEvent event, PieTouchResponse? response) {
    if (event is FlTapUpEvent && response?.touchedSection?.touchedSectionIndex != null) {
      final item = items[response!.touchedSection!.touchedSectionIndex];
      onSectionTap?.call(item);
    }
  }
}
