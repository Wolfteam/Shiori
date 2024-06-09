import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';

typedef OnBarChartTap = void Function(int, int);
typedef GetText = String Function(double);
typedef GetBarChartRodData = List<BarChartRodData> Function(int);

class VerticalBarDataModel {
  final int index;
  final Color color;
  final int x;
  final double y;
  final bool useIndexAsX;

  VerticalBarDataModel(this.index, this.color, this.x, this.y, {this.useIndexAsX = false});
}

const _textStyle = TextStyle(
  color: Colors.grey,
  fontWeight: FontWeight.bold,
  fontSize: 12,
);

class VerticalBarChart extends StatelessWidget {
  final List<VerticalBarDataModel> items;
  final OnBarChartTap? onBarChartTap;
  final GetText getBottomText;
  final GetText getLeftText;
  final GetBarChartRodData? getBarChartRodData;

  final double maxY;
  final double interval;

  final int bottomTextMaxLength;
  final int leftTextMaxLength;

  final bool rotateBottomText;

  const VerticalBarChart({
    super.key,
    required this.items,
    required this.getLeftText,
    required this.getBottomText,
    this.onBarChartTap,
    this.getBarChartRodData,
    required this.maxY,
    required this.interval,
    this.bottomTextMaxLength = 10,
    this.leftTextMaxLength = 10,
    this.rotateBottomText = false,
  });

  @override
  Widget build(BuildContext context) {
    final (TextStyle tooltipTextStyle, BoxDecoration tooltipBoxDecoration, EdgeInsets tooltipPadding) = Styles.getTooltipStyling(context);
    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            getTooltipColor: (spot) => tooltipBoxDecoration.color!,
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              rod.toY.toInt().toString(),
              tooltipTextStyle,
            ),
            tooltipPadding: tooltipPadding,
          ),
          touchCallback: (FlTouchEvent event, response) {
            if (event is FlTapUpEvent && response?.spot?.touchedBarGroupIndex != null) {
              final spot = response!.spot!;
              onBarChartTap?.call(spot.touchedBarGroupIndex, spot.touchedRodDataIndex);
            }
          },
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => _BottomTitles(
                getBottomText: getBottomText,
                bottomTextMaxLength: bottomTextMaxLength,
                value: value,
                rotateBottomText: rotateBottomText,
              ),
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: interval,
              getTitlesWidget: (value, meta) => _LeftTitle(getLeftText: getLeftText, leftTextMaxLength: leftTextMaxLength, value: value),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: items
            .map(
              (e) => BarChartGroupData(
                x: e.useIndexAsX ? e.index : e.x,
                barRods: getBarChartRodData?.call(e.x) ??
                    [
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
        gridData: const FlGridData(show: false),
      ),
    );
  }
}

class _BottomTitles extends StatelessWidget {
  final GetText getBottomText;
  final double value;
  final int bottomTextMaxLength;
  final bool rotateBottomText;

  const _BottomTitles({
    required this.getBottomText,
    required this.value,
    required this.bottomTextMaxLength,
    required this.rotateBottomText,
  });

  @override
  Widget build(BuildContext context) {
    final text = getBottomText(value);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: !rotateBottomText
          ? Tooltip(
              message: text,
              child: Text(
                text.substringIfOverflow(bottomTextMaxLength),
                textAlign: TextAlign.center,
                style: _textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : RotationTransition(
              turns: const AlwaysStoppedAnimation(15 / 360),
              child: Tooltip(
                message: text,
                child: Text(
                  text.substringIfOverflow(bottomTextMaxLength),
                  textAlign: TextAlign.center,
                  style: _textStyle,
                  overflow: TextOverflow.ellipsis,
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
    required this.getLeftText,
    required this.value,
    required this.leftTextMaxLength,
  });

  @override
  Widget build(BuildContext context) {
    final text = getLeftText(value);
    return Tooltip(
      message: text,
      child: Text(
        text.substringIfOverflow(leftTextMaxLength),
        textAlign: TextAlign.center,
        style: _textStyle,
      ),
    );
  }
}
