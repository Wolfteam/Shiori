import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/character/character_page.dart';
import 'package:shiori/presentation/shared/dialogs/item_release_history_dialog.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/gradient_card.dart';
import 'package:shiori/presentation/shared/images/character_icon_image.dart';
import 'package:shiori/presentation/shared/images/weapon_icon_image.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';

enum _ItemOptionsType {
  details,
  releaseHistory,
}

class FixedLeftColumn extends StatelessWidget {
  final List<BannerHistoryItemModel> items;
  final EdgeInsets margin;
  final double cellWidth;
  final double cellHeight;
  final ScrollController controller;

  const FixedLeftColumn({
    super.key,
    required this.items,
    required this.margin,
    required this.cellWidth,
    required this.cellHeight,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: cellWidth,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          controller: controller,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _ItemCard(
              cellWidth: cellWidth,
              cellHeight: cellHeight,
              margin: margin,
              image: item.iconImage,
              itemKey: item.key,
              type: item.type,
              rarity: item.rarity,
              name: item.name,
              numberOfTimesReleased: item.numberOfTimesReleased,
            );
          },
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final String itemKey;
  final BannerHistoryItemType type;
  final String name;
  final String image;
  final int rarity;
  final int numberOfTimesReleased;
  final EdgeInsets margin;
  final double cellWidth;
  final double cellHeight;

  const _ItemCard({
    required this.itemKey,
    required this.type,
    required this.name,
    required this.image,
    required this.rarity,
    required this.numberOfTimesReleased,
    required this.margin,
    required this.cellWidth,
    required this.cellHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = rarity.getRarityGradient();
    const double radius = 10;
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(radius)),
      onTap: () => showDialog<_ItemOptionsType>(context: context, builder: (_) => const _OptionsDialog()).then(
        (value) async => _handleOptionSelected(value, context),
      ),
      child: GradientCard(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        gradient: gradient,
        child: SizedBox(
          width: cellWidth,
          height: cellHeight,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              if (type == BannerHistoryItemType.character)
                AbsorbPointer(child: CharacterIconImage(itemKey: itemKey, image: image, useCircle: false))
              else
                AbsorbPointer(child: WeaponIconImage(itemKey: itemKey, image: image, useCircle: false)),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: cellWidth,
                  decoration: Styles.commonCardBoxDecoration,
                  child: Tooltip(
                    message: name,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.only(top: 3),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.black.withOpacity(0.25),
                    child: Tooltip(
                      message: '$numberOfTimesReleased',
                      child: Text(
                        '$numberOfTimesReleased',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleOptionSelected(_ItemOptionsType? value, BuildContext context) async {
    if (value == null) {
      return;
    }

    switch (value) {
      case _ItemOptionsType.details:
        switch (type) {
          case BannerHistoryItemType.character:
            await CharacterPage.route(itemKey, context);
          case BannerHistoryItemType.weapon:
            await WeaponPage.route(itemKey, context);
        }
      case _ItemOptionsType.releaseHistory:
        await showDialog(context: context, builder: (_) => ItemReleaseHistoryDialog(itemKey: itemKey, itemName: name));
    }
  }
}

class _OptionsDialog extends StatelessWidget {
  const _OptionsDialog();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      title: Text(s.selectAnOption),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
      ],
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(s.details),
              onTap: () => Navigator.pop(context, _ItemOptionsType.details),
            ),
            ListTile(
              title: Text(s.releaseHistory),
              onTap: () => Navigator.pop(context, _ItemOptionsType.releaseHistory),
            ),
          ],
        ),
      ),
    );
  }
}
