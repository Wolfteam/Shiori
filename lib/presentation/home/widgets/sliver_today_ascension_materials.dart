import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/today_materials/today_materials_page.dart';
import 'package:shiori/presentation/today_materials/widgets/sliver_character_ascension_materials.dart';
import 'package:shiori/presentation/today_materials/widgets/sliver_weapon_ascension_materials.dart';

class SliverTodayAscensionMaterials extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) => state.map(
        loading: (_) => const SliverToBoxAdapter(child: Loading(useScaffold: false)),
        loaded: (state) => SliverMainAxisGroup(
          slivers: [
            if (state.charAscMaterials.isNotEmpty)
              _SliverClickableTitle(
                title: s.forCharacters,
                buttonText: s.seeAll,
              ),
            if (state.charAscMaterials.isNotEmpty)
              SliverCharacterAscensionMaterials(
                charAscMaterials: state.charAscMaterials,
              ),
            if (state.weaponAscMaterials.isNotEmpty)
              _SliverClickableTitle(
                title: s.forWeapons,
                buttonText: s.seeAll,
              ),
            if (state.weaponAscMaterials.isNotEmpty)
              SliverWeaponAscensionMaterials(
                weaponAscMaterials: state.weaponAscMaterials,
              ),
          ],
        ),
      ),
    );
  }
}

class _SliverClickableTitle extends StatelessWidget {
  final String title;
  final String buttonText;

  const _SliverClickableTitle({
    required this.title,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10),
      sliver: SliverToBoxAdapter(
        child: ListTile(
          dense: true,
          onTap: () => _gotoMaterialsPage(context),
          visualDensity: const VisualDensity(vertical: -4, horizontal: -2),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [const Icon(Icons.chevron_right), Text(buttonText)],
          ),
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
