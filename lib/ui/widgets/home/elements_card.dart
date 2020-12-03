import 'package:flutter/material.dart';

import '../../pages/elements_page.dart';

class ElementsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: () => _gotoElementsPage(context),
        child: Card(
          margin: EdgeInsets.all(15),
          child: SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FractionalTranslation(
                  translation: Offset(0, -1),
                  child: Image.asset('assets/elements/anemo.png', width: 50, height: 50),
                ),
                FractionalTranslation(
                  translation: Offset(-1.4, -0.5),
                  child: Image.asset('assets/elements/cryo.png', width: 50, height: 50),
                ),
                FractionalTranslation(
                    translation: Offset(-1.4, 0.5),
                    child: Image.asset('assets/elements/dendro.png', width: 50, height: 50)),
                FractionalTranslation(
                  translation: Offset(0, 1),
                  child: Image.asset('assets/elements/geo.png', width: 50, height: 50),
                ),
                FractionalTranslation(
                  translation: Offset(1.4, -0.5),
                  child: Image.asset('assets/elements/hydro.png', width: 50, height: 50),
                ),
                FractionalTranslation(
                  translation: Offset(1.4, 0.5),
                  child: Image.asset('assets/elements/pyro.png', width: 50, height: 50),
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
