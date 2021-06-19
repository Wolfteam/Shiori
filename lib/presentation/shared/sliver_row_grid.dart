import 'package:flutter/material.dart';

//TODO: WORKAROUND FOR https://github.com/letsar/flutter_staggered_grid_view/issues/145
class SliverRowGrid extends StatelessWidget {
  final int itemsCount;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final Widget Function(int) builder;

  const SliverRowGrid({
    Key? key,
    required this.itemsCount,
    required this.builder,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var i = 0; i < itemsCount; i++) {
      final children = <Widget>[];
      for (var j = 0; j < crossAxisCount; j++) {
        final item = builder(i);
        final isLastRowItem = (j == crossAxisCount - 1) || i + 1 >= itemsCount;

        children.add(Expanded(child: item));

        if (!isLastRowItem) {
          children.add(_buildDummyItem(false));
        } else {
          //Here we just fill the remaining holes
          if (j < crossAxisCount - 1) {
            final diff = crossAxisCount - 1 - j;
            for (var z = 0; z < diff; z++) {
              children.add(_buildDummyItem(true));
            }
          }
          break;
        }
        i++;
      }
      rows.add(Row(children: children));
    }

    return SliverList(delegate: SliverChildListDelegate(rows));
  }

  Widget _buildDummyItem(bool useExpanded) {
    final dummy = Container(margin: EdgeInsets.symmetric(horizontal: crossAxisSpacing / 2));
    if (useExpanded) {
      return Expanded(child: dummy);
    }
    return dummy;
  }
}
