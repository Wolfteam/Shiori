import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/banner_history/banner_history_page.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';

class BannerHistoryCard extends StatelessWidget {
  final bool iconToTheLeft;

  const BannerHistoryCard({
    super.key,
    required this.iconToTheLeft,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return CardItem(
      title: s.bannerHistory,
      iconToTheLeft: iconToTheLeft,
      onClick: _gotoBannerHistoryPage,
      icon: Icon(Icons.history_toggle_off, size: 60, color: theme.colorScheme.secondary),
      children: [
        CardDescription(text: s.checkBannerHistory),
      ],
    );
  }

  Future<void> _gotoBannerHistoryPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => const BannerHistoryPage());
    await Navigator.push(context, route);
    await route.completed;
  }
}
