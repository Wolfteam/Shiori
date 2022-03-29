import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/banner_history/banner_history_charts_page.dart';
import 'package:shiori/presentation/banner_history/banner_history_versions_page.dart';

class BannerHistoryPage extends StatefulWidget {
  const BannerHistoryPage({Key? key}) : super(key: key);

  @override
  State<BannerHistoryPage> createState() => _BannerHistoryPageState();
}

class _BannerHistoryPageState extends State<BannerHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _AppBar(),
        body: SafeArea(
          child: TabBarView(
            children: [
              BannerHistoryVersionsPage(),
              BannerHistoryChartsPage(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AppBar(
      title: Text(s.bannerHistory),
      bottom: TabBar(
        tabs: const [
          Tab(icon: Icon(Icons.history_toggle_off)),
          Tab(icon: Icon(Icons.pie_chart)),
        ],
        indicatorColor: Theme.of(context).colorScheme.secondary,
      ),
      actions: [],
    );
  }

  @override
  //toolbar + tabbar + indicator height
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 46 + 2);
}
