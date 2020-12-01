import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/main/main_bloc.dart';
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
  final _pages = [MapPage(), CharactersPage(), HomePage(), WeaponsPage(), ArtifactsPage()];

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<MainBloc, MainState>(
          listener: (ctx, state) async {
            if (state is MainLoadedState) {
              _changeCurrentTab(state.currentSelectedTab);
            }
          },
          builder: (context, state) {
            return TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: _pages,
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
    final i18n = S.of(context);
    return [
      BottomNavigationBarItem(
        label: 'Map',
        icon: const Icon(Icons.map),
      ),
      BottomNavigationBarItem(
        label: 'Characters',
        icon: const Icon(Icons.people),
      ),
      BottomNavigationBarItem(
        label: 'Home',
        icon: const Icon(Icons.home),
      ),
      BottomNavigationBarItem(
        label: 'Weapons',
        icon: const Icon(Icons.settings),
      ),
      BottomNavigationBarItem(
        label: 'Artifacts',
        icon: const Icon(Icons.settings),
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
