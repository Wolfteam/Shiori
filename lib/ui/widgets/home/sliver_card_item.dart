import 'package:flutter/material.dart';

import '../../../common/styles.dart';

class SliverCardItem extends StatelessWidget {
  final Widget icon;
  final List<Widget> children;
  final bool iconToTheLeft;
  final Function(BuildContext) onClick;

  const SliverCardItem({
    Key key,
    @required this.icon,
    @required this.onClick,
    @required this.children,
    this.iconToTheLeft = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: () => onClick(context),
        child: Card(
          margin: Styles.edgeInsetAll15,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: Container(
            padding: Styles.edgeInsetAll15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: iconToTheLeft
                  ? [
                      Flexible(
                        flex: 40,
                        fit: FlexFit.tight,
                        child: icon,
                      ),
                      Flexible(
                        flex: 60,
                        fit: FlexFit.tight,
                        child: Column(children: children),
                      ),
                    ]
                  : [
                      Flexible(
                        flex: 60,
                        fit: FlexFit.tight,
                        child: Column(children: children),
                      ),
                      Flexible(
                        flex: 40,
                        fit: FlexFit.tight,
                        child: icon,
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
