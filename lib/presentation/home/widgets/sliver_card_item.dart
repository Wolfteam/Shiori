import 'package:flutter/material.dart';
import 'package:genshindb/presentation/shared/styles.dart';

class SliverCardItem extends StatelessWidget {
  final Widget icon;
  final List<Widget> children;
  final bool iconToTheLeft;
  final Function(BuildContext) onClick;

  const SliverCardItem({
    Key? key,
    required this.icon,
    required this.onClick,
    required this.children,
    this.iconToTheLeft = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: InkWell(
        borderRadius: Styles.homeCardItemBorderRadius,
        onTap: () => onClick(context),
        child: Card(
          clipBehavior: Clip.hardEdge,
          margin: Styles.edgeInsetAll15,
          shape: RoundedRectangleBorder(borderRadius: Styles.homeCardItemBorderRadius),
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
