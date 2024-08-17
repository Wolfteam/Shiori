import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/shared/dialogs/item_release_history_dialog.dart';

class ContentCard extends StatelessWidget {
  final BannerHistoryItemModel banner;
  final EdgeInsets margin;
  final int? number;
  final double iconSize;
  final double version;

  const ContentCard({
    required this.banner,
    required this.margin,
    this.number,
    this.iconSize = 45,
    required this.version,
  });

  @override
  Widget build(BuildContext context) {
    if (number == 0) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(16);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
      child: InkWell(
        borderRadius: borderRadius,
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
        child: Card(
          color: theme.dividerColor,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          child: Center(
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
