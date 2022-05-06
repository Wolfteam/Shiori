import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';

class TopPieChart extends StatelessWidget {
  final List<ChartTopItemModel> items;
  final List<Color> colors;

  const TopPieChart({
    Key? key,
    required this.items,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: TOOLTIP ?
    return PieChart(
      PieChartData(
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        centerSpaceRadius: 0,
        startDegreeOffset: -90,
        sections: List.generate(
          items.length,
          (index) {
            final item = items[index];
            return PieChartSectionData(
              color: colors[index],
              value: item.percentage,
              title: '${item.value}',
              radius: 100.0,
              showTitle: true,
              titlePositionPercentageOffset: 0.8,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}
