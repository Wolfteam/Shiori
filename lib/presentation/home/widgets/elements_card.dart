import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/elements/elements_page.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';
import 'package:shiori/presentation/shared/images/element_image.dart';

class ElementsCard extends StatelessWidget {
  const ElementsCard();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return CardItem(
      title: s.elements,
      onClick: _gotoElementsPage,
      children: [
        Wrap(
          runAlignment: WrapAlignment.center,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          children: ElementType.values.map((type) => ElementImage.fromType(type: type, radius: 15)).toList(),
        ),
      ],
    );
  }

  Future<void> _gotoElementsPage(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (c) => ElementsPage()));
  }
}
