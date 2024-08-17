import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
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

class LeftItemCard extends StatelessWidget {
  final String itemKey;
  final BannerHistoryItemType type;
  final String name;
  final String image;
  final int rarity;
  final int numberOfTimesReleased;
  final EdgeInsets margin;

  const LeftItemCard({
    required this.itemKey,
    required this.type,
    required this.name,
    required this.image,
    required this.rarity,
    required this.numberOfTimesReleased,
    required this.margin,
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
                width: double.maxFinite,
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
                  backgroundColor: Colors.black.withOpacity(0.6),
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
