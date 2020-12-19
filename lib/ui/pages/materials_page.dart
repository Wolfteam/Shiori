import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bloc.dart';
import '../../common/styles.dart';
import '../../generated/l10n.dart';
import '../widgets/common/loading.dart';
import '../widgets/materials/sliver_character_ascention_materials.dart';
import '../widgets/materials/sliver_weapon_ascention_materials.dart';

class MaterialsPage extends StatefulWidget {
  @override
  _MaterialsPageState createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> with AutomaticKeepAliveClientMixin<MaterialsPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);
    final s = S.of(context);
    return BlocBuilder<MaterialsBloc, MaterialsState>(
      builder: (context, state) {
        return state.when(
          loading: () => const Loading(),
          loaded: (charsMaterials, weaponMaterials) => Scaffold(
            appBar: AppBar(title: Text(s.materials)),
            body: SafeArea(
              child: Container(
                padding: Styles.edgeInsetAll10,
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: Styles.edgeInsetAll5,
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          s.forCharacters,
                          style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SliverCharacterAscentionMaterials(charAscMaterials: charsMaterials),
                    SliverPadding(
                      padding: Styles.edgeInsetAll5,
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          s.forWeapons,
                          style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SliverWeaponAscentionMaterials(weaponAscMaterials: weaponMaterials),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
