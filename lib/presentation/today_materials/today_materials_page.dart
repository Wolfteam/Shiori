import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/today_materials/widgets/sliver_character_ascension_materials.dart';
import 'package:shiori/presentation/today_materials/widgets/sliver_weapon_ascension_materials.dart';

class TodayMaterialsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return BlocBuilder<TodayMaterialsBloc, TodayMaterialsState>(
      builder: (context, state) => switch (state) {
        TodayMaterialsStateLoading() => const Loading(),
        TodayMaterialsStateLoaded() => Scaffold(
          appBar: AppBar(title: Text(s.materials)),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      s.forCharacters,
                      style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverCharacterAscensionMaterials(charAscMaterials: state.charAscMaterials, useListView: false),
                SliverPadding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      s.forWeapons,
                      style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverWeaponAscensionMaterials(weaponAscMaterials: state.weaponAscMaterials, useListView: false),
              ],
            ),
          ),
        ),
      },
    );
  }
}
