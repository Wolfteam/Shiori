import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/daily_check_in/daily_check_in_page.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';

class DailyCheckInCard extends StatelessWidget {
  final bool iconToTheLeft;

  const DailyCheckInCard({
    super.key,
    required this.iconToTheLeft,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return CardItem(
      title: s.dailyCheckIn,
      onClick: _goToPageDailyCheckInPage,
      iconToTheLeft: iconToTheLeft,
      icon: Icon(Icons.rotate_right_sharp, size: 60, color: theme.colorScheme.secondary),
      children: [
        CardDescription(text: s.dailyCheckInMsg),
      ],
    );
  }

  Future<void> _goToPageDailyCheckInPage(BuildContext context) async {
    final route = MaterialPageRoute(fullscreenDialog: true, builder: (c) => DailyCheckInPage());
    await Navigator.push(context, route);
    await route.completed;
  }
}
