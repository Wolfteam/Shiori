import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/artifact/widgets/bonus.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/details/detail_tab_landscape_layout.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/images/character_icon_image.dart';
import 'package:shiori/presentation/shared/images/monster_icon_image.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';

class BottomPortraitLayout extends StatelessWidget {
  final int maxRarity;
  final List<ArtifactCardBonusModel> bonus;
  final List<String> pieces;
  final List<ItemCommon> usedBy;
  final List<ItemCommon> droppedBy;

  const BottomPortraitLayout({
    required this.maxRarity,
    required this.bonus,
    required this.pieces,
    required this.usedBy,
    required this.droppedBy,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final size = SizeUtils.getSizeForCircleImages(context);
    final color = maxRarity.getRarityColors().first;
    return Padding(
      padding: Styles.edgeInsetHorizontal5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Bonus(
            color: color,
            bonus: bonus,
          ),
          DetailSection.complex(
            title: s.pieces,
            color: color,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                children: pieces
                    .map(
                      (e) => Container(
                        margin: Styles.edgeInsetAll5,
                        child: Image.file(File(e), width: size * 2, height: size * 2),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          if (usedBy.isNotEmpty)
            DetailSection.complex(
              title: s.builds,
              color: color,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  children: usedBy.map((e) => CharacterIconImage(itemKey: e.key, image: e.iconImage, size: size)).toList(),
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
  final int maxRarity;
  final List<ArtifactCardBonusModel> bonus;
  final List<String> pieces;
  final List<ItemCommon> usedBy;
  final List<ItemCommon> droppedBy;

  const BottomLandscapeLayout({
    required this.maxRarity,
    required this.bonus,
    required this.pieces,
    required this.usedBy,
    required this.droppedBy,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final tabs = [s.description];
    final size = SizeUtils.getSizeForCircleImages(context);
    final color = maxRarity.getRarityColors().first;
    return DetailTabLandscapeLayout(
      color: color,
      tabs: tabs,
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Bonus(
                color: color,
                bonus: bonus,
              ),
              DetailSection.complex(
                title: s.pieces,
                color: color,
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: pieces
                        .map(
                          (e) => Container(
                            margin: Styles.edgeInsetAll5,
                            child: Image.file(File(e), width: size * 2, height: size * 2),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              if (usedBy.isNotEmpty)
                DetailSection.complex(
                  title: s.builds,
                  color: color,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: usedBy.map((e) => CharacterIconImage(itemKey: e.key, image: e.iconImage, size: size)).toList(),
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
        )
      ],
    );
  }
}
