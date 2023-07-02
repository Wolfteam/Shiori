import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/banner_history/widgets/grouped_banner_card.dart';
import 'package:shiori/presentation/shared/dialogs/banner_version_history_dialog.dart';
import 'package:shiori/presentation/shared/styles.dart';

class BannerGroupedPeriod extends StatelessWidget {
  final WishBannerHistoryGroupedPeriodModel group;
  final WishBannerGroupedType groupedType;
  final bool forSelection;
  final double bannerImageWidth;
  final double bannerImgHeight;

  //TODO: MOVE THE IMAGE SIZE TO CONSTANTS
  const BannerGroupedPeriod({
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
          color: theme.colorScheme.primary.withOpacity(0.5),
          child: Container(
            margin: const EdgeInsets.only(left: 5),
            child: count != null
                ? RichText(
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
                  )
                : Text(
                    title,
                    style: theme.textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
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
      Navigator.pop(context);
      return Future.value();
    }
    return showDialog(context: context, builder: (context) => BannerVersionHistoryDialog(version: part.version));
  }
}
