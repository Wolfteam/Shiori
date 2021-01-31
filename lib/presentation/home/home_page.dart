import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/today_materials/materials_page.dart';

import 'widgets/sliver_calculators_card.dart';
import 'widgets/sliver_elements_card.dart';
import 'widgets/sliver_settings_card.dart';
import 'widgets/sliver_today_char_ascension_materials.dart';
import 'widgets/sliver_today_weapon_materials.dart';
import 'widgets/sliver_wish_simulator_card.dart';

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
        _buildMainTitle(s.todayAscensionMaterials, context),
        _buildClickableTitle(s.forCharacters, s.seeAll, context, onClick: () => _gotoMaterialsPage(context)),
        SliverTodayCharAscensionMaterials(),
        _buildClickableTitle(s.forWeapons, s.seeAll, context, onClick: () => _gotoMaterialsPage(context)),
        SliverTodayWeaponMaterials(),
        _buildMainTitle(s.elements, context),
        SliverElementsCard(),
        _buildMainTitle(s.calculators, context),
        SliverCalculatorsCard(),
        _buildMainTitle(s.wishSimulator, context),
        SliverWishSimulatorCard(),
        _buildMainTitle(s.settings, context),
        SliverSettingsCard(),
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
    context.read<MaterialsBloc>().add(const MaterialsEvent.init());
    await Navigator.push(context, MaterialPageRoute(builder: (_) => MaterialsPage()));
  }
}
