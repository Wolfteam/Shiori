import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/home/widgets/sliver_calculators_card.dart';
import 'package:genshindb/presentation/home/widgets/sliver_daily_check_in_card.dart';
import 'package:genshindb/presentation/home/widgets/sliver_game_codes_card.dart';
import 'package:genshindb/presentation/home/widgets/sliver_materials_card.dart';
import 'package:genshindb/presentation/home/widgets/sliver_monsters_card.dart';
import 'package:genshindb/presentation/home/widgets/sliver_settings_card.dart';
import 'package:genshindb/presentation/home/widgets/sliver_tierlist_card.dart';
import 'package:genshindb/presentation/home/widgets/sliver_wish_simulator_card.dart';
import 'package:genshindb/presentation/today_materials/today_materials_page.dart';

import 'widgets/sliver_characters_birthday_card.dart';
import 'widgets/sliver_elements_card.dart';
import 'widgets/sliver_main_title.dart';
import 'widgets/sliver_my_inventory_card.dart';
import 'widgets/sliver_today_char_ascension_materials.dart';
import 'widgets/sliver_today_main_title.dart';
import 'widgets/sliver_today_weapon_materials.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final s = S.of(context);
    return CustomScrollView(
      slivers: [
        SliverCharactersBirthdayCard(),
        const SliverTodayMainTitle(),
        _buildClickableTitle(s.forCharacters, s.seeAll, context, onClick: () => _gotoMaterialsPage(context)),
        SliverTodayCharAscensionMaterials(),
        _buildClickableTitle(s.forWeapons, s.seeAll, context, onClick: () => _gotoMaterialsPage(context)),
        SliverTodayWeaponMaterials(),
        SliverMainTitle(title: s.elements),
        SliverElementsCard(),
        ..._buildMenu(s),
      ],
    );
  }

  List<Widget> _buildMenu(S s) {
    var iconToTheLeft = false;
    final map = <String, int>{
      s.myInventory: 1,
      s.calculators: 2,
      s.materials: 3,
      s.monsters: 4,
      s.dailyCheckIn: 5,
      s.wishSimulator: 6,
      s.tierListBuilder: 7,
      s.gameCodes: 8,
      s.settings: 9,
    };
    final menu = <Widget>[];

    for (final kvp in map.entries) {
      menu.add(SliverMainTitle(title: kvp.key));
      menu.add(_getItemCard(kvp.value, iconToTheLeft));
      iconToTheLeft = !iconToTheLeft;
    }
    return menu;
  }

  Widget _getItemCard(int position, bool iconToTheLeft) {
    switch (position) {
      case 1:
        return SliverMyInventoryCard(iconToTheLeft: iconToTheLeft);
      case 2:
        return SliverCalculatorsCard(iconToTheLeft: iconToTheLeft);
      case 3:
        return SliverMaterialsCard(iconToTheLeft: iconToTheLeft);
      case 4:
        return SliverMonstersCard(iconToTheLeft: iconToTheLeft);
      case 5:
        return SliverDailyCheckInCard(iconToTheLeft: iconToTheLeft);
      case 6:
        return SliverWishSimulatorCard(iconToTheLeft: iconToTheLeft);
      case 7:
        return SliverTierList(iconToTheLeft: iconToTheLeft);
      case 8:
        return SliverGameCodesCard(iconToTheLeft: iconToTheLeft);
      case 9:
        return SliverSettingsCard(iconToTheLeft: iconToTheLeft);
      default:
        throw Exception('Invalid menu item card');
    }
  }

  Widget _buildClickableTitle(String title, String buttonText, BuildContext context, {Function onClick}) {
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
          onTap: () => onClick?.call(),
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

  Future<void> _gotoMaterialsPage(BuildContext context) async {
    context.read<TodayMaterialsBloc>().add(const TodayMaterialsEvent.init());
    await Navigator.push(context, MaterialPageRoute(builder: (_) => TodayMaterialsPage()));
  }
}
