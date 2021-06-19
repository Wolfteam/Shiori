import 'package:flutter/material.dart';
import 'package:genshindb/presentation/settings/widgets/settings_card.dart';

class SettingsCardContent extends StatelessWidget {
  final String title;
  final String subTitle;
  final Icon icon;
  final Widget child;

  const SettingsCardContent({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.icon,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              icon,
              Container(
                margin: const EdgeInsets.only(left: 5),
                child: Text(title, style: textTheme.headline6),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              subTitle,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
