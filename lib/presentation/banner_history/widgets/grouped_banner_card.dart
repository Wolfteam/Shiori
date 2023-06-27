import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/character/character_page.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');

typedef OnGroupedBannerCardTap = void Function(WishBannerHistoryPartItemModel banner);

class GroupedBannerCard extends StatelessWidget {
  final WishBannerHistoryPartItemModel part;
  final double bannerImageWidth;
  final OnGroupedBannerCardTap onTap;

  const GroupedBannerCard({
    required this.part,
    required this.bannerImageWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onTap(part),
      child: Card(
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: part.bannerImages.mapIndex((e, index) => Image.asset(e, width: bannerImageWidth)).toList(),
            ),
            _ClickableText(
              characters: part.promotedCharacters,
              weapons: part.promotedWeapons,
              style: theme.textTheme.headlineSmall!,
            ),
            Text(
              '${_dateFormat.format(part.from)} - ${_dateFormat.format(part.until)}',
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              width: bannerImageWidth * 0.75,
              child: Divider(color: theme.colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClickableText extends StatelessWidget {
  final List<ItemCommonWithNameOnly> characters;
  final List<ItemCommonWithNameOnly> weapons;
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

  void _addSpans(BuildContext context, ItemCommonWithNameOnly item, List<TextSpan> spans, bool isCharacter, bool addComma) {
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
