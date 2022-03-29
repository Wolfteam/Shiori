import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';

class Content extends StatelessWidget {
  final List<BannerHistoryItemModel> banners;
  final List<double> versions;
  final EdgeInsets margin;
  final double cellWidth;
  final double cellHeight;

  const Content({
    Key? key,
    required this.banners,
    required this.versions,
    required this.margin,
    required this.cellWidth,
    required this.cellHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        banners.length,
        (i) => Row(
          children: List.generate(
            versions.length,
            (j) {
              final version = versions[j];
              final banner = banners[i];
              return _ContentCard(
                number: banner.versions.firstWhere((el) => el.version == version).number,
                margin: margin,
                cellHeight: cellHeight,
                cellWidth: cellWidth,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final EdgeInsets margin;
  final double cellWidth;
  final double cellHeight;
  final int? number;
  final double iconSize;

  const _ContentCard({
    Key? key,
    required this.margin,
    required this.cellWidth,
    required this.cellHeight,
    this.number,
    this.iconSize = 45,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (number == 0) {
      return SizedBox.fromSize(size: Size(cellWidth + margin.horizontal, cellHeight + margin.vertical));
    }
    final theme = Theme.of(context);
    //TODO: LIGHT COLOR
    return SizedBox(
      child: Container(
        width: cellWidth,
        height: cellHeight,
        margin: margin,
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
          color: theme.colorScheme.background.withOpacity(0.2),
          child: number != null
              ? Text(
                  '$number',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                )
              : Icon(Icons.check_circle, size: iconSize, color: Colors.green),
        ),
      ),
    );
  }
}
