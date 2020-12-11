import 'package:flutter/material.dart';
import 'package:genshindb/common/assets.dart';
import 'package:genshindb/common/styles.dart';

import '../../pages/elements_page.dart';

class ElementsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: () => _gotoElementsPage(context),
        child: Card(
          margin: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FractionalTranslation(
                  translation: const Offset(0, -1),
                  child: Image.asset(Assets.getElementPath('anemo.png'), width: 50, height: 50),
                ),
                FractionalTranslation(
                  translation: const Offset(-1.4, -0.5),
                  child: Image.asset(Assets.getElementPath('cryo.png'), width: 50, height: 50),
                ),
                FractionalTranslation(
                    translation: const Offset(-1.4, 0.5),
                    child: Image.asset(Assets.getElementPath('dendro.png'), width: 50, height: 50)),
                FractionalTranslation(
                  translation: const Offset(0, 1),
                  child: Image.asset(Assets.getElementPath('geo.png'), width: 50, height: 50),
                ),
                FractionalTranslation(
                  translation: const Offset(1.4, -0.5),
                  child: Image.asset(Assets.getElementPath('hydro.png'), width: 50, height: 50),
                ),
                FractionalTranslation(
                  translation: const Offset(1.4, 0.5),
                  child: Image.asset(Assets.getElementPath('pyro.png'), width: 50, height: 50),
                ),
              ],
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
