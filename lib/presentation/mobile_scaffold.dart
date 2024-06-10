import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/artifacts/artifacts_page.dart';
import 'package:shiori/presentation/characters/characters_page.dart';
import 'package:shiori/presentation/home/home_page.dart';
import 'package:shiori/presentation/map/map_page.dart';
import 'package:shiori/presentation/shared/extensions/focus_scope_node_extensions.dart';
import 'package:shiori/presentation/shared/mixins/scroll_to_top_on_double_tab_tap_mixin.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/weapons/weapons_page.dart';

typedef OnWillPop = Future<bool> Function();

class MobileScaffold extends StatefulWidget {
  final int defaultIndex;
  final TabController tabController;
  final List<ScrollController> scrollControllers;

  const MobileScaffold({
    super.key,
    required this.defaultIndex,
    required this.tabController,
    required this.scrollControllers,
  });

  @override
  _MobileScaffoldState createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> with SingleTickerProviderStateMixin, ScrollToTopOnDoubleTabTapMixin {
  late int _index;

  @override
  void initState() {
    _index = widget.defaultIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocListener<MainTabBloc, MainTabState>(
          listener: (ctx, state) async {
            state.maybeMap(
              initial: (s) => _changeCurrentTab(s.currentSelectedTab),
              orElse: () => {},
            );
          },
          child: TabBarView(
            controller: widget.tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              CharactersPage(scrollController: widget.scrollControllers.first),
              WeaponsPage(scrollController: widget.scrollControllers[1]),
              HomePage(scrollController: widget.scrollControllers[2]),
              ArtifactsPage(scrollController: widget.scrollControllers.last),
              MapPage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        showUnselectedLabels: true,
        useLegacyColorScheme: false,
        type: BottomNavigationBarType.fixed,
        landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
        items: [
          BottomNavigationBarItem(label: s.characters, icon: const Icon(Icons.people)),
          BottomNavigationBarItem(label: s.weapons, icon: const Icon(Shiori.crossed_swords)),
          BottomNavigationBarItem(label: s.home, icon: const Icon(Icons.home)),
          BottomNavigationBarItem(label: s.artifacts, icon: const Icon(Shiori.overmind)),
          BottomNavigationBarItem(label: s.map, icon: const Icon(Icons.map)),
        ],
        onTap: (index) => _gotoTab(index),
      ),
    );
  }

  void _changeCurrentTab(int index) {
    FocusScope.of(context).removeFocus();
    widget.tabController.index = index;
    setState(() {
      _index = index;
    });
  }

  void _gotoTab(int newIndex) {
    scrollToTopOnTabTap(widget.tabController.index, newIndex, widget.scrollControllers);
    context.read<MainTabBloc>().add(MainTabEvent.goToTab(index: newIndex));
  }
}
