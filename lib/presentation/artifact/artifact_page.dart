import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_stats.dart';
import 'package:shiori/presentation/character/character_page.dart';
import 'package:shiori/presentation/shared/details/detail_horizontal_list.dart';
import 'package:shiori/presentation/shared/details/detail_landscape_content.dart';
import 'package:shiori/presentation/shared/details/detail_main_card.dart';
import 'package:shiori/presentation/shared/details/detail_main_content.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/dialogs/item_common_with_name_dialog.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/images/rarity.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/scaffold_with_fab.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

part 'widgets/bonus.dart';
part 'widgets/dropped_by.dart';
part 'widgets/main.dart';
part 'widgets/pieces.dart';
part 'widgets/used_by.dart';

class ArtifactPage extends StatelessWidget {
  final String itemKey;

  const ArtifactPage({super.key, required this.itemKey});

  static Future<void> route(String itemKey, BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => ArtifactPage(itemKey: itemKey));
    await Navigator.push(context, route);
    await route.completed;
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocProvider(
      create: (context) => Injection.artifactBloc..add(ArtifactEvent.loadFromKey(key: itemKey)),
      child: BlocBuilder<ArtifactBloc, ArtifactState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading.column(),
          loaded: (state) {
            final color = state.maxRarity.getRarityColors().first;

            final main = Main(
              name: state.name,
              image: state.image,
              maxRarity: state.maxRarity,
            );
            final children = <Widget>[
              _Bonus(
                color: color,
                bonus: state.bonus,
              ),
              _Pieces(
                color: color,
                pieces: state.images,
              ),
              if (state.usedBy.isNotEmpty)
                _UsedBy(
                  color: color,
                  usedBy: state.usedBy,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
