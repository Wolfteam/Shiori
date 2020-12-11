import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../widgets/home/elements_card.dart';
import '../widgets/home/today_char_ascention_materials.dart';
import '../widgets/home/today_weapon_materials.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return CustomScrollView(
      slivers: [
        _buildMainTitle(s.todayAscentionMaterials, context),
        _buildClickableTitle(s.forCharacters, s.seeAll, context),
        TodayCharAscentionMaterials(),
        _buildClickableTitle(s.forWeapons, s.seeAll, context),
        TodayWeaponMaterials(),
        _buildMainTitle(s.elements, context),
        ElementsCard(),
//TODO: SETTINGS GOES HERE
      ],
    );
  }

  Widget _buildMainTitle(String title, BuildContext context) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10),
      sliver: SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            title,
            style: theme.textTheme.headline6.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildClickableTitle(String title, String buttonText, BuildContext context) {
    final theme = Theme.of(context);
    final row = buttonText != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [const Icon(Icons.chevron_right), Text(buttonText)],
          )
        : null;
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10),
      sliver: SliverToBoxAdapter(
        child: ListTile(
          dense: true,
          onTap: () => {},
          visualDensity: const VisualDensity(vertical: -4, horizontal: -2),
          trailing: row,
          title: Text(
            title,
            textAlign: TextAlign.start,
            style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
