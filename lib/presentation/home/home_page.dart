import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/home/widgets/banner_history_count_card.dart';
import 'package:shiori/presentation/home/widgets/calculators_card.dart';
import 'package:shiori/presentation/home/widgets/charts_card.dart';
import 'package:shiori/presentation/home/widgets/custom_builds_card.dart';
import 'package:shiori/presentation/home/widgets/daily_check_in_card.dart';
import 'package:shiori/presentation/home/widgets/elements_card.dart';
import 'package:shiori/presentation/home/widgets/game_codes_card.dart';
import 'package:shiori/presentation/home/widgets/materials_card.dart';
import 'package:shiori/presentation/home/widgets/monsters_card.dart';
import 'package:shiori/presentation/home/widgets/my_inventory_card.dart';
import 'package:shiori/presentation/home/widgets/notifications_card.dart';
import 'package:shiori/presentation/home/widgets/settings_card.dart';
import 'package:shiori/presentation/home/widgets/sliver_characters_birthday_card.dart';
import 'package:shiori/presentation/home/widgets/sliver_main_title.dart';
import 'package:shiori/presentation/home/widgets/sliver_today_char_ascension_materials.dart';
import 'package:shiori/presentation/home/widgets/sliver_today_main_title.dart';
import 'package:shiori/presentation/home/widgets/sliver_today_weapon_materials.dart';
import 'package:shiori/presentation/home/widgets/tierlist_card.dart';
import 'package:shiori/presentation/home/widgets/wish_simulator_card.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/today_materials/today_materials_page.dart';

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
    return ResponsiveBuilder(
      builder: (ctx, size) => CustomScrollView(
        slivers: [
          SliverCharactersBirthdayCard(),
          const SliverTodayMainTitle(),
          _buildClickableTitle(s.forCharacters, s.seeAll, context, onClick: () => _gotoMaterialsPage(context)),
          SliverTodayCharAscensionMaterials(),
          _buildClickableTitle(s.forWeapons, s.seeAll, context, onClick: () => _gotoMaterialsPage(context)),
          SliverTodayWeaponMaterials(),
          SliverMainTitle(title: s.gameSpecific),
          SliverToBoxAdapter(
            child: SizedBox(
              height: Styles.homeCardHeight,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) => _buildGameSectionMenus(index),
              ),
            ),
          ),
          SliverMainTitle(title: s.tools),
          SliverToBoxAdapter(
            child: SizedBox(
              height: Styles.homeCardHeight,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (context, index) => _buildToolsSectionMenu(index),
              ),
            ),
          ),
          SliverMainTitle(title: s.others),
          SliverToBoxAdapter(
            child: SizedBox(
              height: Styles.homeCardHeight,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) => _buildOthersSectionMenu(index),
              ),
            ),
          ),
          if (size.isMobile) SliverMainTitle(title: s.settings),
          if (size.isMobile)
            SliverToBoxAdapter(
              child: SizedBox(
                height: Styles.homeCardHeight,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: 1,
                  itemBuilder: (context, index) => const SettingsCard(iconToTheLeft: true),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameSectionMenus(int index) {
    switch (index) {
      case 0:
        return const MaterialsCard(iconToTheLeft: true);
      case 1:
        return const MonstersCard(iconToTheLeft: true);
      case 2:
        return const BannerHistoryCard(iconToTheLeft: true);
      case 3:
        return ElementsCard();
      default:
        throw Exception('Invalid game section');
    }
  }

  Widget _buildToolsSectionMenu(int index) {
    switch (index) {
      case 0:
        return const MyInventoryCard(iconToTheLeft: true);
      case 1:
        return const CalculatorsCard(iconToTheLeft: true);
      case 2:
        return const NotificationsCard(iconToTheLeft: true);
      case 3:
        return const CustomBuildsCard(iconToTheLeft: true);
      case 4:
        return const ChartsCard(iconToTheLeft: true);
      case 5:
        return const TierListCard(iconToTheLeft: true);
      default:
        throw Exception('Invalid tool section');
    }
  }

  Widget _buildOthersSectionMenu(int index) {
    switch (index) {
      case 0:
        if (Platform.isMacOS) {
          return const SizedBox.shrink();
        }
        return const DailyCheckInCard(iconToTheLeft: true);
      case 1:
        return const GameCodesCard(iconToTheLeft: true);
      case 2:
        return const WishSimulatorCard(iconToTheLeft: true);
      default:
        throw Exception('Invalid other section');
    }
  }

  Widget _buildClickableTitle(String title, String? buttonText, BuildContext context, {VoidCallback? onClick}) {
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
            style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
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
