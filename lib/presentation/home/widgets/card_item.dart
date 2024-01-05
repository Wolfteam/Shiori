import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/styles.dart';

class CardItem extends StatelessWidget {
  final String title;
  final Widget? icon;
  final List<Widget> children;
  final bool iconToTheLeft;
  final Function(BuildContext) onClick;

  const CardItem({
    super.key,
    required this.title,
    this.icon,
    required this.onClick,
    required this.children,
    this.iconToTheLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Styles.edgeInsetAll10,
      width: Styles.homeCardWidth,
      child: InkWell(
        borderRadius: Styles.homeCardItemBorderRadius,
        onTap: () => onClick(context),
        child: Card(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(borderRadius: Styles.homeCardItemBorderRadius),
          child: Padding(
            padding: Styles.edgeInsetHorizontal10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                if (icon != null)
                  _Content(
                    icon: icon!,
                    iconToTheLeft: iconToTheLeft,
                    children: children,
                  )
                else
                  ...children
              ],
            ),
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
