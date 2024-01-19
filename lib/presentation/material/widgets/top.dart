import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart' as enums;
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/details/detail_general_card.dart';
import 'package:shiori/presentation/shared/details/detail_top_layout.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/images/rarity.dart';

class Top extends StatelessWidget {
  final String name;
  final int rarity;
  final enums.MaterialType type;
  final String image;
  final List<int> days;

  const Top({
    required this.name,
    required this.rarity,
    required this.type,
    required this.image,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final gradient = rarity.getRarityGradient();
    return DetailTopLayout(
      fullImage: image,
      secondFullImage: image,
      decoration: BoxDecoration(gradient: gradient),
      isAnSmallImage: isPortrait,
      generalCard: DetailGeneralCardNew(
        itemName: name,
        color: gradient.colors.first,
        rows: [
          GeneralCardRow(
            left: GeneralCardColumn(
              title: s.rarity,
              child: Rarity(
                stars: rarity,
                color: Colors.white,
                centered: false,
              ),
            ),
            right: days.isNotEmpty
                ? GeneralCardColumn(
                    title: s.day,
                    child: Text(
                      s.translateDays(days),
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : null,
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
