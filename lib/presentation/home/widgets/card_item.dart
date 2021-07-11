import 'package:flutter/material.dart';
import 'package:genshindb/presentation/shared/styles.dart';

class CardItem extends StatelessWidget {
  final String title;
  final Widget icon;
  final List<Widget> children;
  final bool iconToTheLeft;
  final Function(BuildContext) onClick;

  const CardItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.onClick,
    required this.children,
    this.iconToTheLeft = false,
  }) : super(key: key);

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
          width: 300,
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
              if (iconToTheLeft) _LeftLayout(icon: icon, children: children) else _RightLayout(icon: icon, children: children),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeftLayout extends StatelessWidget {
  final Widget icon;
  final List<Widget> children;

  const _LeftLayout({
    Key? key,
    required this.icon,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          flex: 40,
          fit: FlexFit.tight,
          child: icon,
        ),
        Flexible(
          flex: 60,
          fit: FlexFit.tight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _RightLayout extends StatelessWidget {
  final Widget icon;
  final List<Widget> children;

  const _RightLayout({
    Key? key,
    required this.icon,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          flex: 60,
          fit: FlexFit.tight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
        Flexible(
          flex: 40,
          fit: FlexFit.tight,
          child: icon,
        ),
      ],
    );
  }
}
