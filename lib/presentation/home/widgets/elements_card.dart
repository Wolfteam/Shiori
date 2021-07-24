import 'package:flutter/material.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/elements/elements_page.dart';
import 'package:genshindb/presentation/shared/images/element_image.dart';
import 'package:genshindb/presentation/shared/styles.dart';

class ElementsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return InkWell(
      borderRadius: Styles.homeCardItemBorderRadius,
      onTap: () => _gotoElementsPage(context),
      child: Card(
        clipBehavior: Clip.hardEdge,
        margin: Styles.edgeInsetAll15,
        shape: RoundedRectangleBorder(borderRadius: Styles.homeCardItemBorderRadius),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          constraints: const BoxConstraints(minHeight: 80, maxWidth: 340),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.elements,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Wrap(
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ElementType.anemo,
                  ElementType.geo,
                  ElementType.electro,
                ]
                    .map((type) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: ElementImage.fromType(type: type, radius: 20)))
                    .toList(),
              ),
              Wrap(
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ElementType.dendro,
                  ElementType.hydro,
                  ElementType.pyro,
                  ElementType.cryo,
                ]
                    .map((type) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: ElementImage.fromType(type: type, radius: 20)))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _gotoElementsPage(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (c) => ElementsPage()));
  }
}
