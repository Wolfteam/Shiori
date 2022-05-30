import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/shared/dialogs/item_release_history_dialog.dart';

class Content extends StatefulWidget {
  final List<BannerHistoryItemModel> banners;
  final List<double> versions;
  final EdgeInsets margin;
  final double cellWidth;
  final double cellHeight;
  final ScrollController verticalController;
  final LinkedScrollControllerGroup horizontalControllerGroup;
  final int maxNumberOfItems;

  const Content({
    Key? key,
    required this.banners,
    required this.versions,
    required this.margin,
    required this.cellWidth,
    required this.cellHeight,
    required this.verticalController,
    required this.horizontalControllerGroup,
    required this.maxNumberOfItems,
  }) : super(key: key);

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  final List<ScrollController> horizontalControllers = [];

  @override
  void initState() {
    for (int i = 0; i < widget.maxNumberOfItems; i++) {
      final controller = widget.horizontalControllerGroup.addAndGet();
      horizontalControllers.add(controller);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.verticalController,
      itemCount: widget.banners.length,
      itemBuilder: (context, i) {
        final banner = widget.banners[i];
        final horizontalController = horizontalControllers[i];
        return SizedBox(
          height: widget.cellHeight + widget.margin.vertical,
          child: ListView.builder(
            controller: horizontalController,
            itemCount: banner.versions.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, j) {
              final version = widget.versions[j];
              return _ContentCard(
                banner: banner,
                number: banner.versions.firstWhere((el) => el.version == version).number,
                margin: widget.margin,
                cellHeight: widget.cellHeight,
                cellWidth: widget.cellWidth,
                version: version,
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    for (final controller in horizontalControllers) {
      controller.dispose();
    }
    super.dispose();
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
    return InkWell(
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
          margin: const EdgeInsets.only(top: 25, bottom: 25, left: 10, right: 10),
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
    );
  }
}
