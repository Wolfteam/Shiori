import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/images/character_icon_image.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';

class Builds extends StatelessWidget {
  final Color color;
  final List<ItemCommon> images;

  const Builds({
    required this.color,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailSection.complex(
      title: s.builds,
      color: color,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: images.map((e) => CharacterIconImage.circleItem(item: e, size: SizeUtils.getSizeForCircleImages(context))).toList(),
        ),
      ],
    );
  }
}
