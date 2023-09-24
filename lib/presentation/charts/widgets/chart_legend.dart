import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/styles.dart';

class ChartLegend extends StatelessWidget {
  final List<ChartLegendIndicator> indicators;

  const ChartLegend({
    super.key,
    required this.indicators,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: indicators,
    );
  }
}

class ChartLegendIndicator extends StatelessWidget {
  final Color color;
  final String text;
  final double size;
  final VoidCallback? tap;
  final bool expandText;
  final bool selected;
  final double? width;

  const ChartLegendIndicator({
    super.key,
    required this.color,
    required this.text,
    this.size = 16,
    this.tap,
    this.expandText = true,
    this.selected = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: Colors.grey,
      decorationThickness: 3,
    );
    return Container(
      margin: expandText ? const EdgeInsets.symmetric(vertical: 3) : Styles.edgeInsetAll5,
      width: width,
      child: Tooltip(
        message: text,
        child: InkWell(
          onTap: tap != null ? () => tap?.call() : null,
          child: Row(
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: selected ? Icon(Icons.check_circle_outline, size: size / 1.2) : null,
              ),
              const SizedBox(width: 4),
              if (expandText)
                Expanded(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                )
              else
                Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
