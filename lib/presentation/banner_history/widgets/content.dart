import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/banner_history/widgets/item_release_history_dialog.dart';

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
                banner: banner,
                number: banner.versions.firstWhere((el) => el.version == version).number,
                margin: margin,
                cellHeight: cellHeight,
                cellWidth: cellWidth,
                version: version,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final BannerHistoryItemModel banner;
  final EdgeInsets margin;
  final double cellWidth;
  final double cellHeight;
  final int? number;
  final double iconSize;
  final double version;

  const _ContentCard({
    Key? key,
    required this.banner,
    required this.margin,
    required this.cellWidth,
    required this.cellHeight,
    this.number,
    this.iconSize = 45,
    required this.version,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (number == 0) {
      return SizedBox.fromSize(size: Size(cellWidth + margin.horizontal, cellHeight + margin.vertical));
    }
    final theme = Theme.of(context);
    return SizedBox(
      child: InkWell(
        onTap: number != null
            ? null
            : () => showDialog(
                  context: context,
                  builder: (_) => ItemReleaseHistoryDialog(
                    itemKey: banner.key,
                    itemName: banner.name,
                    selectedVersion: version,
                  ),
                ),
        child: Container(
          width: cellWidth,
          height: cellHeight,
          margin: margin,
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
            color: theme.brightness == Brightness.dark ? theme.colorScheme.background.withOpacity(0.2) : theme.dividerColor,
            child: number != null
                ? Text(
                    '$number',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                  )
                : Icon(Icons.check_circle, size: iconSize, color: Colors.green),
          ),
        ),
      ),
    );
  }
}
