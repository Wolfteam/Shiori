import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/loading.dart';

import 'widgets/sliver_character_ascension_materials.dart';
import 'widgets/sliver_weapon_ascension_materials.dart';

class TodayMaterialsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return BlocBuilder<TodayMaterialsBloc, TodayMaterialsState>(
      builder: (context, state) {
        return state.when(
          loading: () => const Loading(),
          loaded: (charsMaterials, weaponMaterials) => Scaffold(
            appBar: AppBar(title: Text(s.materials)),
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.only(left: 10, top: 10),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        s.forCharacters,
                        style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SliverCharacterAscensionMaterials(charAscMaterials: charsMaterials),
                  SliverPadding(
                    padding: const EdgeInsets.only(left: 10, top: 10),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        s.forWeapons,
                        style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SliverWeaponAscensionMaterials(weaponAscMaterials: weaponMaterials),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
