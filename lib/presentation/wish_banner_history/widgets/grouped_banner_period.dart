import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/shared/dialogs/banner_version_history_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/item_release_history_dialog.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/wish_banner_history/widgets/grouped_banner_card.dart';

class GroupedBannerPeriod extends StatelessWidget {
  final WishBannerHistoryGroupedPeriodModel group;
  final WishBannerGroupedType groupedType;
  final bool forSelection;
  final double bannerImageWidth;
  final double bannerImgHeight;

  //TODO: MOVE THE IMAGE SIZE TO CONSTANTS
  const GroupedBannerPeriod({
    required this.group,
    required this.groupedType,
    required this.forSelection,
    this.bannerImageWidth = 250,
    this.bannerImgHeight = 190,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = group.groupingTitle;
    final int? count = groupedType != WishBannerGroupedType.version ? group.parts.groupListsBy((el) => el.version).length : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredBox(
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
          child: Container(
            margin: const EdgeInsets.only(left: 5),
            child: count != null
                ? InkWell(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => ItemReleaseHistoryDialog(itemKey: group.groupingKey, itemName: title),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.headlineSmall!.copyWith(overflow: TextOverflow.ellipsis),
                        children: [
                          TextSpan(text: title),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Text(
                              ' [$count]',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => BannerVersionHistoryDialog(version: group.parts.first.version),
                    ),
                    child: Text(
                      title,
                      style: theme.textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
          ),
        ),
        Container(
          height: bannerImgHeight + 50,
          margin: Styles.edgeInsetHorizontal16.copyWith(bottom: 15),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: group.parts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 20),
            itemBuilder: (context, index) {
              final part = group.parts[index];
              return GroupedBannerCard(
                part: part,
                bannerImageWidth: bannerImageWidth,
                bannerImageHeight: bannerImgHeight,
                showVersion: groupedType != WishBannerGroupedType.version,
                onTap: (part) => _onCardTap(context, part),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _onCardTap(BuildContext context, WishBannerHistoryPartItemModel part) {
    if (forSelection) {
      Navigator.pop(context, part);
      return Future.value();
    }
    return showDialog(
      context: context,
      builder: (context) => BannerVersionHistoryDialog(version: part.version),
    );
  }
}
