import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/styles.dart';

class ChartLegend extends StatelessWidget {
  final List<ChartLegendIndicator> indicators;

  const ChartLegend({
    Key? key,
    required this.indicators,
  }) : super(key: key);

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
  final Function? tap;
  final bool expandText;
  final bool lineThrough;

  const ChartLegendIndicator({
    Key? key,
    required this.color,
    required this.text,
    this.size = 16,
    this.tap,
    this.expandText = true,
    this.lineThrough = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: Colors.grey,
      decoration: lineThrough ? TextDecoration.lineThrough : null,
      decorationThickness: 3,
    );
    return Container(
      margin: expandText ? const EdgeInsets.symmetric(vertical: 3) : Styles.edgeInsetAll5,
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
            ),
            const SizedBox(width: 4),
            if (expandText)
              Expanded(
                child: Tooltip(
                  message: text,
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                ),
              )
            else
              Tooltip(
                message: text,
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              )
          ],
        ),
      ),
    );
  }
}
