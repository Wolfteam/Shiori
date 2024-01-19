import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/details/detail_general_card.dart';
import 'package:shiori/presentation/shared/details/detail_top_layout.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/images/rarity.dart';

class Top extends StatelessWidget {
  final String name;
  final int maxRarity;
  final String image;

  const Top({
    required this.name,
    required this.maxRarity,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final gradient = maxRarity.getRarityGradient();
    return DetailTopLayout(
      fullImage: image,
      secondFullImage: image,
      decoration: BoxDecoration(gradient: gradient),
      showShadowImage: isPortrait,
      charDescriptionHeight: 120,
      isAnSmallImage: isPortrait,
      generalCard: DetailGeneralCardNew(
        itemName: name,
        color: gradient.colors.first,
        rows: [
          GeneralCardRow(
            left: GeneralCardColumn(
              title: s.rarity,
              child: Rarity(
                stars: maxRarity,
                color: Colors.white,
                centered: false,
              ),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
    );
  }
}
