import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/daily_check_in/daily_check_in_page.dart';
import 'package:genshindb/presentation/home/widgets/card_item.dart';

class DailyCheckInCard extends StatelessWidget {
  final bool iconToTheLeft;

  const DailyCheckInCard({
    Key? key,
    required this.iconToTheLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return CardItem(
      title: s.dailyCheckIn,
      onClick: _goToPageDailyCheckInPage,
      iconToTheLeft: iconToTheLeft,
      icon: Icon(Icons.rotate_right_sharp, size: 60, color: theme.accentColor),
      children: [
        Text(s.dailyCheckInMsg, style: theme.textTheme.subtitle2, textAlign: TextAlign.center),
      ],
    );
  }

  Future<void> _goToPageDailyCheckInPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => DailyCheckInPage());
    await Navigator.push(context, route);
    await route.completed;
  }
}
