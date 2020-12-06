import 'package:flutter/material.dart';

import '../widgets/home/elements_card.dart';
import '../widgets/home/today_char_ascention_materials.dart';
import '../widgets/home/today_weapon_materials.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildTitle('Today Character Ascention Materials', 'See All', context),
        TodayCharAscentionMaterials(),
        _buildTitle('Today Weapon Ascention Materials', 'See All', context),
        TodayWeaponMaterials(),
        _buildTitle('Elements', null, context),
        ElementsCard(),
//TODO: SETTINGS GOES HERE
      ],
    );
  }

  Widget _buildTitle(String title, String buttonText, BuildContext context) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: EdgeInsets.only(top: 10),
      sliver: SliverToBoxAdapter(
        child: ListTile(
          dense: true,
          visualDensity: VisualDensity(vertical: -4, horizontal: -2),
          trailing: buttonText != null
              ? FlatButton.icon(onPressed: () => {}, icon: Icon(Icons.chevron_right), label: Text(buttonText))
              : null,
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
