import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/styles.dart';

class CardItem extends StatelessWidget {
  final String title;
  final Widget icon;
  final List<Widget> children;
  final bool iconToTheLeft;
  final Function(BuildContext) onClick;

  const CardItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onClick,
    required this.children,
    this.iconToTheLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: Styles.homeCardItemBorderRadius,
      onTap: () => onClick(context),
      child: Card(
        clipBehavior: Clip.hardEdge,
        margin: Styles.edgeInsetAll15,
        shape: RoundedRectangleBorder(borderRadius: Styles.homeCardItemBorderRadius),
        child: Container(
          width: Styles.homeCardWidth,
          height: 100,
          padding: Styles.edgeInsetAll15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              _Content(icon: icon, iconToTheLeft: iconToTheLeft, children: children),
            ],
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final Widget icon;
  final bool iconToTheLeft;
  final List<Widget> children;

  const _Content({
    required this.icon,
    required this.iconToTheLeft,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final iconFlex = Flexible(
      flex: 40,
      fit: FlexFit.tight,
      child: icon,
    );
    final childrenFlex = Flexible(
      flex: 60,
      fit: FlexFit.tight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (iconToTheLeft) iconFlex else childrenFlex,
        if (iconToTheLeft) childrenFlex else iconFlex,
      ],
    );
  }
}
