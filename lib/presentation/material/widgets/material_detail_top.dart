import 'package:flutter/material.dart';
import 'package:genshindb/domain/enums/enums.dart' as enums;
import 'package:genshindb/presentation/shared/details/detail_appbar.dart';
import 'package:genshindb/presentation/shared/details/detail_top_layout.dart';
import 'package:genshindb/presentation/shared/extensions/rarity_extensions.dart';

import 'material_detail_general_card.dart';

class MaterialDetailTop extends StatelessWidget {
  final String name;
  final int rarity;
  final enums.MaterialType type;
  final String image;
  final List<int> days;

  const MaterialDetailTop({
    Key? key,
    required this.name,
    required this.rarity,
    required this.type,
    required this.image,
    required this.days,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DetailTopLayout(
      fullImage: image,
      charDescriptionHeight: 170,
      isAnSmallImage: MediaQuery.of(context).orientation == Orientation.portrait,
      decoration: BoxDecoration(gradient: rarity.getRarityGradient()),
      appBar: const DetailAppBar(),
      generalCard: MaterialDetailGeneralCard(
        type: type,
        name: name,
        rarity: rarity,
        days: days,
      ),
    );
  }
}
