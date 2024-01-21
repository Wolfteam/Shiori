import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/weapon_type_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/character/character_page.dart';
import 'package:shiori/presentation/shared/details/detail_horizontal_list.dart';
import 'package:shiori/presentation/shared/details/detail_landscape_content.dart';
import 'package:shiori/presentation/shared/details/detail_main_card.dart';
import 'package:shiori/presentation/shared/details/detail_main_content.dart';
import 'package:shiori/presentation/shared/details/detail_materials.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/details/detail_stats.dart';
import 'package:shiori/presentation/shared/dialogs/item_common_with_name_dialog.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/highlighted_text.dart';
import 'package:shiori/presentation/shared/images/rarity.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/scaffold_with_fab.dart';
import 'package:shiori/presentation/shared/styles.dart';

part 'widgets/ascension_materials.dart';
part 'widgets/builds.dart';
part 'widgets/crafting_materials.dart';
part 'widgets/description.dart';
part 'widgets/main.dart';
part 'widgets/refinements.dart';

class WeaponPage extends StatelessWidget {
  final String itemKey;

  const WeaponPage({super.key, required this.itemKey});

  static Future<void> route(String itemKey, BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => WeaponPage(itemKey: itemKey));
    await Navigator.push(context, route);
    await route.completed;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocProvider(
      create: (context) => Injection.weaponBloc..add(WeaponEvent.loadFromKey(key: itemKey)),
      child: BlocBuilder<WeaponBloc, WeaponState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading.column(),
          loaded: (state) {
            final Color color = state.rarity.getRarityColors().first;
            final main = _Main(
              itemKey: state.key,
              name: state.name,
              atk: state.atk,
              rarity: state.rarity,
              secondaryStatType: state.secondaryStat,
              secondaryStatValue: state.secondaryStatValue,
              type: state.weaponType,
              locationType: state.locationType,
              image: state.fullImage,
              isInInventory: state.isInInventory,
            );
            final children = <Widget>[
              if (isPortrait)
                _Description(
                  color: color,
                  description: state.description,
                  secondaryStatType: state.secondaryStat,
                  stats: state.stats,
                )
              else
                _Description.noButtons(
                  color: color,
                  description: state.description,
                  secondaryStatType: state.secondaryStat,
                ),
              if (state.ascensionMaterials.isNotEmpty)
                _AscensionMaterials(
                  color: color,
                  ascensionMaterials: state.ascensionMaterials,
                ),
              if (state.craftingMaterials.isNotEmpty)
                _CraftingMaterials(
                  color: color,
                  craftingMaterials: state.craftingMaterials,
                ),
              if (state.characters.isNotEmpty)
                _Builds(
                  color: color,
                  characters: state.characters,
                ),
              if (state.refinements.isNotEmpty)
                _Refinements(
                  color: color,
                  refinements: state.refinements,
                ),
              if (state.stats.isNotEmpty)
                StatsTable(
                  color: color,
                  stats: state.stats.map((e) => StatItem.weapon(e, state.secondaryStat, s)).toList(),
                ),
            ];
            if (isPortrait) {
              return ScaffoldWithFab(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    main,
                    Padding(
                      padding: Styles.edgeInsetHorizontal5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Scaffold(
              body: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      flex: 40,
                      child: main,
                    ),
                    Expanded(
                      flex: 60,
                      child: DetailLandscapeContent.noTabs(
                        color: color,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
