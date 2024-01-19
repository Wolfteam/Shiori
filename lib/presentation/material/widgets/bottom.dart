import 'package:flutter/material.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/details/detail_tab_landscape_layout.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/images/character_icon_image.dart';
import 'package:shiori/presentation/shared/images/monster_icon_image.dart';
import 'package:shiori/presentation/shared/images/weapon_icon_image.dart';
import 'package:shiori/presentation/shared/material_item_button.dart';
import 'package:shiori/presentation/shared/material_quantity_row.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';

class BottomPortraitLayout extends StatelessWidget {
  final String? description;
  final int rarity;
  final List<ItemCommon> characters;
  final List<ItemCommon> weapons;
  final List<ItemObtainedFrom> obtainedFrom;
  final List<ItemCommon> relatedTo;
  final List<ItemCommon> droppedBy;

  const BottomPortraitLayout({
    this.description,
    required this.rarity,
    required this.characters,
    required this.weapons,
    required this.obtainedFrom,
    required this.relatedTo,
    required this.droppedBy,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final size = SizeUtils.getSizeForCircleImages(context);
    final color = rarity.getRarityColors().first;
    return Padding(
      padding: Styles.edgeInsetHorizontal5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (description.isNotNullEmptyOrWhitespace)
            DetailSection(
              title: s.description,
              color: color,
              description: description,
            ),
          if (obtainedFrom.isNotEmpty)
            DetailSection.complex(
              title: s.obtainedFrom,
              color: color,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  children: obtainedFrom.mapIndex((e, index) => _ObtainedFromItem(from: e, showDivider: index != obtainedFrom.length - 1)).toList(),
                ),
              ],
            ),
          if (characters.isNotEmpty)
            DetailSection.complex(
              title: s.characters,
              color: color,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  children: characters.map((e) => CharacterIconImage(itemKey: e.key, image: e.iconImage, size: size)).toList(),
                ),
              ],
            ),
          if (weapons.isNotEmpty)
            DetailSection.complex(
              title: s.weapons,
              color: color,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  children: weapons.map((e) => WeaponIconImage(itemKey: e.key, image: e.image, size: size)).toList(),
                ),
              ],
            ),
          if (relatedTo.isNotEmpty)
            DetailSection.complex(
              title: s.related,
              color: color,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  children: relatedTo.map((e) => MaterialItemButton(itemKey: e.key, image: e.image, size: size * 2)).toList(),
                ),
              ],
            ),
          if (droppedBy.isNotEmpty)
            DetailSection.complex(
              title: s.droppedBy,
              color: color,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  children: droppedBy.map((e) => MonsterIconImage(itemKey: e.key, image: e.image, radius: size)).toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class BottomLandscapeLayout extends StatelessWidget {
  final String? description;
  final int rarity;
  final List<ItemCommon> characters;
  final List<ItemCommon> weapons;
  final List<ItemObtainedFrom> obtainedFrom;
  final List<ItemCommon> relatedTo;
  final List<ItemCommon> droppedBy;

  const BottomLandscapeLayout({
    this.description,
    required this.rarity,
    required this.characters,
    required this.weapons,
    required this.obtainedFrom,
    required this.relatedTo,
    required this.droppedBy,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final tabs = <String>[
      s.description,
      if (droppedBy.isNotEmpty) s.droppedBy,
    ];
    final size = SizeUtils.getSizeForCircleImages(context);
    final color = rarity.getRarityColors().first;
    return DetailTabLandscapeLayout(
      color: color,
      tabs: tabs,
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (description.isNotNullEmptyOrWhitespace)
                DetailSection(
                  title: s.description,
                  color: color,
                  description: description,
                ),
              if (obtainedFrom.isNotEmpty)
                DetailSection.complex(
                  title: s.obtainedFrom,
                  color: color,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      children:
                          obtainedFrom.mapIndex((e, index) => _ObtainedFromItem(from: e, showDivider: index != obtainedFrom.length - 1)).toList(),
                    ),
                  ],
                ),
              if (relatedTo.isNotEmpty)
                DetailSection.complex(
                  title: s.related,
                  color: color,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: relatedTo.map((e) => MaterialItemButton(itemKey: e.key, image: e.image, size: size * 2)).toList(),
                    ),
                  ],
                ),
              if (characters.isNotEmpty)
                DetailSection.complex(
                  title: s.characters,
                  color: color,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: characters.map((e) => CharacterIconImage(itemKey: e.key, image: e.iconImage, size: size)).toList(),
                    ),
                  ],
                ),
              if (weapons.isNotEmpty)
                DetailSection.complex(
                  title: s.weapons,
                  color: color,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: weapons.map((e) => WeaponIconImage(itemKey: e.key, image: e.image, size: size)).toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (droppedBy.isNotEmpty)
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                DetailSection.complex(
                  title: s.droppedBy,
                  color: color,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: droppedBy.map((e) => MonsterIconImage(itemKey: e.key, image: e.image, radius: size)).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ObtainedFromItem extends StatelessWidget {
  final ItemObtainedFrom from;
  final bool showDivider;

  const _ObtainedFromItem({required this.from, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: from.items.map((e) => MaterialQuantityRow.fromItemCommonQuantity(item: e, size: 70)).toList(),
        ),
        if (showDivider) const FractionallySizedBox(widthFactor: 0.8, child: Divider()),
      ],
    );
  }
}
