import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart' as bloc;
import 'package:shiori/domain/enums/enums.dart' as enums;
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/character/character_page.dart';
import 'package:shiori/presentation/material/material_page.dart' as mp;
import 'package:shiori/presentation/shared/details/detail_horizontal_list.dart';
import 'package:shiori/presentation/shared/details/detail_landscape_content.dart';
import 'package:shiori/presentation/shared/details/detail_main_card.dart';
import 'package:shiori/presentation/shared/details/detail_main_content.dart';
import 'package:shiori/presentation/shared/details/detail_materials.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/dialogs/item_common_with_name_dialog.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/images/rarity.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/scaffold_with_fab.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';

part 'widgets/characters.dart';
part 'widgets/dropped_by.dart';
part 'widgets/main.dart';
part 'widgets/obtained_from.dart';
part 'widgets/related_to.dart';
part 'widgets/weapons.dart';

class MaterialPage extends StatelessWidget {
  final String itemKey;

  const MaterialPage({super.key, required this.itemKey});

  static Future<void> route(String itemKey, BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => MaterialPage(itemKey: itemKey));
    await Navigator.push(context, route);
    await route.completed;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocProvider(
      create: (context) => Injection.materialBloc..add(bloc.MaterialEvent.loadFromKey(key: itemKey)),
      child: BlocBuilder<bloc.MaterialBloc, bloc.MaterialState>(
        builder: (context, state) {
          switch (state) {
            case bloc.MaterialStateLoading():
              return const Loading.scaffold();
            case bloc.MaterialStateLoaded():
              final color = state.rarity.getRarityColors().first;
              final main = _Main(
                name: state.name,
                image: state.fullImage,
                type: state.type,
                rarity: state.rarity,
                days: state.days,
              );
              final children = <Widget>[
                if (state.description.isNotNullEmptyOrWhitespace)
                  DetailSection(
                    title: s.description,
                    color: color,
                    description: state.description,
                  ),
                if (state.obtainedFrom.isNotEmpty)
                  _ObtainedFrom(
                    color: color,
                    obtainedFrom: state.obtainedFrom,
                  ),
                if (state.relatedMaterials.isNotEmpty)
                  _RelatedTo(
                    color: color,
                    relatedTo: state.relatedMaterials,
                  ),
                if (state.characters.isNotEmpty)
                  _Characters(
                    color: color,
                    characters: state.characters,
                  ),
                if (state.weapons.isNotEmpty)
                  _Weapons(
                    color: color,
                    weapons: state.weapons,
                  ),
                if (state.droppedBy.isNotEmpty)
                  _DroppedBy(
                    color: color,
                    droppedBy: state.droppedBy,
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
                    mainAxisAlignment: MainAxisAlignment.center,
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
          }
        },
      ),
    );
  }
}
