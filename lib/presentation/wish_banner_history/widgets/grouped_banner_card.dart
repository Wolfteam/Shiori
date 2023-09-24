import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/wish_banner_constants.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/character/character_page.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';

typedef OnGroupedBannerCardTap = void Function(WishBannerHistoryPartItemModel banner);

class GroupedBannerCard extends StatelessWidget {
  final WishBannerHistoryPartItemModel part;
  final double bannerImageWidth;
  final double bannerImageHeight;
  final bool showVersion;
  final OnGroupedBannerCardTap onTap;

  const GroupedBannerCard({
    required this.part,
    required this.bannerImageWidth,
    required this.bannerImageHeight,
    required this.showVersion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onTap(part),
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: part.bannerImages
                    .mapIndex(
                      (e, index) => Image.file(
                        File(e),
                        width: bannerImageWidth,
                        height: bannerImageHeight,
                        fit: BoxFit.cover,
                      ),
                    )
                    .toList(),
              ),
            ),
            _ClickableText(
              characters: part.featuredCharacters.where((el) => el.rarity == WishBannerConstants.maxObtainableRarity).toList(),
              weapons: part.featuredWeapons.where((el) => el.rarity == WishBannerConstants.maxObtainableRarity).toList(),
              style: theme.textTheme.titleMedium!.copyWith(overflow: TextOverflow.ellipsis),
            ),
            Text(
              '${WishBannerConstants.dateFormat.format(part.from)} - ${WishBannerConstants.dateFormat.format(part.until)}',
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
            if (showVersion)
              Text(
                s.appVersion(part.version),
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

class _ClickableText extends StatelessWidget {
  final List<ItemCommonWithNameAndRarity> characters;
  final List<ItemCommonWithNameAndRarity> weapons;
  final TextStyle style;

  const _ClickableText({
    required this.characters,
    required this.weapons,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spans = <TextSpan>[];
    for (int i = 0; i < characters.length; i++) {
      _addSpans(context, characters[i], spans, true, characters.length > 1 && i < characters.length - 1);
    }

    if (characters.isNotEmpty && weapons.isNotEmpty) {
      spans.add(TextSpan(text: ' - ', style: theme.textTheme.titleMedium));
    }

    for (int i = 0; i < weapons.length; i++) {
      _addSpans(context, weapons[i], spans, false, weapons.length > 1 && i < weapons.length - 1);
    }

    return RichText(
      text: TextSpan(
        style: style,
        children: spans,
      ),
    );
  }

  void _addSpans(BuildContext context, ItemCommonWithNameAndRarity item, List<TextSpan> spans, bool isCharacter, bool addComma) {
    final theme = Theme.of(context);
    final clickableSpan = TextSpan(
      text: item.name,
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          if (isCharacter) {
            await _goToCharacterPage(item.key, context);
          } else {
            await _goToWeaponPage(item.key, context);
          }
        },
    );
    spans.add(clickableSpan);

    if (addComma) {
      spans.add(TextSpan(text: ' & ', style: theme.textTheme.titleMedium));
    }
  }

  Future<void> _goToCharacterPage(String itemKey, BuildContext context) async {
    return CharacterPage.route(itemKey, context);
  }

  Future<void> _goToWeaponPage(String itemKey, BuildContext context) async {
    return WeaponPage.route(itemKey, context);
  }
}
