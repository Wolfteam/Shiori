import 'package:flutter/material.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/presentation/elements/elements_page.dart';
import 'package:genshindb/presentation/shared/element_image.dart';
import 'package:genshindb/presentation/shared/styles.dart';

class SliverElementsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: InkWell(
        borderRadius: Styles.homeCardItemBorderRadius,
        onTap: () => _gotoElementsPage(context),
        child: Card(
          clipBehavior: Clip.hardEdge,
          margin: Styles.edgeInsetAll15,
          shape: RoundedRectangleBorder(borderRadius: Styles.homeCardItemBorderRadius),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            constraints: const BoxConstraints(minHeight: 80),
            child: Wrap(
              runAlignment: WrapAlignment.center,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: ElementType.values
                  .map((type) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: ElementImage.fromType(type: type)))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _gotoElementsPage(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (c) => ElementsPage()));
  }
}
