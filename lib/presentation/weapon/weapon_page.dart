import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/shared/app_fab.dart';
import 'package:genshindb/presentation/shared/extensions/scroll_controller_extensions.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/weapon/widgets/weapon_detail_bottom.dart';
import 'package:genshindb/presentation/weapon/widgets/weapon_detaill_top.dart';

class WeaponPage extends StatefulWidget {
  @override
  _WeaponPageState createState() => _WeaponPageState();
}

class _WeaponPageState extends State<WeaponPage> with SingleTickerProviderStateMixin {
  ScrollController _scrollController;
  AnimationController _hideFabAnimController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 0, // initially not visible
    );
    _scrollController.addListener(() => _scrollController.handleScrollForFab(_hideFabAnimController));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: BlocBuilder<WeaponBloc, WeaponState>(
            builder: (context, state) {
              return state.map(
                loading: (_) => const Loading(useScaffold: false),
                loaded: (s) => Stack(
                  children: [
                    WeaponDetailTop(
                      name: s.name,
                      atk: s.atk,
                      rarity: s.rarity,
                      secondaryStatType: s.secondaryStat,
                      secondaryStatValue: s.secondaryStatValue,
                      type: s.weaponType,
                      locationType: s.locationType,
                      image: s.fullImage,
                    ),
                    WeaponDetailBottom(
                      description: s.description,
                      rarity: s.rarity,
                      secondaryStatType: s.secondaryStat,
                      stats: s.stats,
                      ascensionMaterials: s.ascensionMaterials,
                      refinements: s.refinements,
                      charImgs: s.charImages,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: AppFab(
        hideFabAnimController: _hideFabAnimController,
        scrollController: _scrollController,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }
}
