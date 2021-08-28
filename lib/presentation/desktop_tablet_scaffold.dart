import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/artifacts/artifacts_page.dart';
import 'package:shiori/presentation/characters/characters_page.dart';
import 'package:shiori/presentation/home/home_page.dart';
import 'package:shiori/presentation/map/map_page.dart';
import 'package:shiori/presentation/settings/settings_page.dart';
import 'package:shiori/presentation/shared/extensions/focus_scope_node_extensions.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/weapons/weapons_page.dart';

typedef OnWillPop = Future<bool> Function();

class DesktopTabletScaffold extends StatefulWidget {
  final int defaultIndex;
  final TabController tabController;

  const DesktopTabletScaffold({
    Key? key,
    required this.defaultIndex,
    required this.tabController,
  }) : super(key: key);

  @override
  _DesktopTabletScaffoldState createState() => _DesktopTabletScaffoldState();
}

class _DesktopTabletScaffoldState extends State<DesktopTabletScaffold> {
  late int _index;

  @override
  void initState() {
    _index = widget.defaultIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final extended = MediaQuery.of(context).orientation != Orientation.portrait;
    return Scaffold(
      body: SafeArea(
        child: BlocListener<MainTabBloc, MainTabState>(
          listener: (ctx, state) async {
            state.maybeMap(
              initial: (s) => _changeCurrentTab(s.currentSelectedTab),
              orElse: () => {},
            );
          },
          child: Row(
            children: <Widget>[
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: (index) => _gotoTab(index),
                labelType: extended ? null : NavigationRailLabelType.selected,
                extended: extended,
                destinations: <NavigationRailDestination>[
                  NavigationRailDestination(
                    icon: const Icon(Icons.people),
                    selectedIcon: const Icon(Icons.people),
                    label: Text(s.characters),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(GenshinDb.crossed_swords),
                    selectedIcon: const Icon(GenshinDb.crossed_swords),
                    label: Text(s.weapons),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.home),
                    selectedIcon: const Icon(Icons.home),
                    label: Text(s.home),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(GenshinDb.overmind),
                    selectedIcon: const Icon(GenshinDb.overmind),
                    label: Text(s.artifacts),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.map),
                    selectedIcon: const Icon(Icons.map),
                    label: Text(s.map),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.settings),
                    selectedIcon: const Icon(Icons.settings),
                    label: Text(s.settings),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              // This is the main content.
              Expanded(
                child: TabBarView(
                  controller: widget.tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const CharactersPage(),
                    const WeaponsPage(),
                    HomePage(),
                    const ArtifactsPage(),
                    MapPage(),
                  ],
                ),
              )
            ],
          ),
        ),
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

  Future<void> _gotoTab(int newIndex) async {
    if (newIndex == 5) {
      await _gotoSettingsPage();
      return;
    }
    context.read<MainTabBloc>().add(MainTabEvent.goToTab(index: newIndex));
  }

  Future<void> _gotoSettingsPage() async {
    final route = MaterialPageRoute(builder: (c) => SettingsPage());
    await Navigator.push(context, route);
  }
}
