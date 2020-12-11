import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bloc.dart';
import '../../generated/l10n.dart';
import 'artifacts_page.dart';
import 'characters_page.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'weapons_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  bool _didChangeDependencies = false;
  TabController _tabController;
  int _index = 2;
  final _pages = [
    CharactersPage(),
    WeaponsPage(),
    HomePage(),
    ArtifactsPage(),
    MapPage(),
  ];

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: _index,
      length: _pages.length,
      vsync: this,
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didChangeDependencies) return;
    _didChangeDependencies = true;
    context.read<HomeBloc>().add(const HomeEvent.init());
    context.read<CharactersBloc>().add(const CharactersEvent.init());
    context.read<WeaponsBloc>().add(const WeaponsEvent.init());
    context.read<ArtifactsBloc>().add(const ArtifactsEvent.init());
    context.read<ElementsBloc>().add(const ElementsEvent.init());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<MainBloc, MainState>(
          listener: (ctx, state) async {
            state.maybeMap(
              loaded: (s) => _changeCurrentTab(s.currentSelectedTab),
              orElse: () => {},
            );
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: _pages,
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        showUnselectedLabels: true,
        items: _buildBottomNavBars(),
        type: BottomNavigationBarType.fixed,
        onTap: (newIndex) => context.read<MainBloc>().add(MainEvent.goToTab(index: newIndex)),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavBars() {
    final s = S.of(context);
    return [
      BottomNavigationBarItem(
        label: s.characters,
        icon: const Icon(Icons.people),
      ),
      BottomNavigationBarItem(
        label: s.weapons,
        icon: const Icon(Icons.settings),
      ),
      BottomNavigationBarItem(
        label: s.home,
        icon: const Icon(Icons.home),
      ),
      BottomNavigationBarItem(
        label: s.artifacts,
        icon: const Icon(Icons.settings),
      ),
      BottomNavigationBarItem(
        label: s.map,
        icon: const Icon(Icons.map),
      ),
    ];
  }

  void _changeCurrentTab(int index) {
    setState(() {
      _index = index;
      _tabController.index = index;
    });
  }
}
