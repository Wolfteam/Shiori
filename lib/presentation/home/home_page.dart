import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
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
import 'package:shiori/presentation/home/widgets/sliver_today_ascension_materials.dart';
import 'package:shiori/presentation/home/widgets/sliver_today_main_title.dart';
import 'package:shiori/presentation/home/widgets/tierlist_card.dart';
import 'package:shiori/presentation/home/widgets/wish_simulator_card.dart';
import 'package:shiori/presentation/shared/styles.dart';

class HomePage extends StatefulWidget {
  final ScrollController? scrollController;

  const HomePage({this.scrollController});

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
        controller: widget.scrollController,
        slivers: [
          SliverCharactersBirthdayCard(),
          const SliverTodayMainTitle(),
          SliverTodayAscensionMaterials(),
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
        return const ElementsCard();
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
        return const DailyCheckInCard(iconToTheLeft: true);
      case 1:
        return const GameCodesCard(iconToTheLeft: true);
      case 2:
        return const WishSimulatorCard(iconToTheLeft: true);
      default:
        throw Exception('Invalid other section');
    }
  }
}
