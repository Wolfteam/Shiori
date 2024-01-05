import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_stats.dart';
import 'package:shiori/presentation/shared/details/detail_appbar.dart';
import 'package:shiori/presentation/shared/details/detail_bottom_portrait_layout.dart';
import 'package:shiori/presentation/shared/details/detail_general_card.dart';
import 'package:shiori/presentation/shared/details/detail_tab_landscape_layout.dart';
import 'package:shiori/presentation/shared/details/detail_top_layout.dart';
import 'package:shiori/presentation/shared/disabled_card_surface_tint_color.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/images/circle_character.dart';
import 'package:shiori/presentation/shared/images/circle_monster.dart';
import 'package:shiori/presentation/shared/item_description_detail.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/scaffold_with_fab.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';

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
    return DisabledSurfaceCardTintColor(
      child: BlocProvider(
        create: (context) => Injection.artifactBloc..add(ArtifactEvent.loadFromKey(key: itemKey)),
        child: isPortrait ? const _PortraitLayout() : const _LandscapeLayout(),
      ),
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ScaffoldWithFab(
      child: BlocBuilder<ArtifactBloc, ArtifactState>(
        builder: (context, state) {
          return state.map(
            loading: (_) => const Loading(useScaffold: false),
            loaded: (state) {
              final rarityColor = state.maxRarity.getRarityColors().last;
              final size = SizeUtils.getSizeForCircleImages(context);
              return Stack(
                fit: StackFit.passthrough,
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  DetailTopLayout(
                    color: rarityColor,
                    fullImage: state.image,
                    charDescriptionHeight: 120,
                    appBar: const DetailAppBar(),
                    isAnSmallImage: true,
                    generalCard: DetailGeneralCard(
                      rarity: state.maxRarity,
                      itemName: state.name,
                      color: rarityColor,
                    ),
                  ),
                  DetailBottomPortraitLayout(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ItemDescriptionDetail(
                          title: s.bonus,
                          body: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ArtifactStats(bonus: state.bonus),
                          ),
                          textColor: rarityColor,
                        ),
                      ),
                      ItemDescriptionDetail(
                        title: s.pieces,
                        body: Wrap(
                          alignment: WrapAlignment.center,
                          children: state.images
                              .map(
                                (e) => Container(
                                  margin: Styles.edgeInsetAll5,
                                  child: Image.file(File(e), width: size * 2, height: size * 2),
                                ),
                              )
                              .toList(),
                        ),
                        textColor: rarityColor,
                      ),
                      if (state.charImages.isNotEmpty)
                        ItemDescriptionDetail(
                          title: s.builds,
                          body: Wrap(
                            alignment: WrapAlignment.center,
                            children: state.charImages.map((e) => CharacterIconImage(itemKey: e.key, image: e.iconImage, size: size)).toList(),
                          ),
                          textColor: rarityColor,
                        ),
                      if (state.droppedBy.isNotEmpty)
                        ItemDescriptionDetail(
                          title: s.droppedBy,
                          body: Wrap(
                            alignment: WrapAlignment.center,
                            children: state.droppedBy.map((e) => CircleMonster(itemKey: e.key, image: e.image, radius: size)).toList(),
                          ),
                          textColor: rarityColor,
                        ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ArtifactBloc, ArtifactState>(
          builder: (ctx, state) => state.map(
            loading: (_) => const Loading(useScaffold: false),
            loaded: (state) {
              final rarityColor = state.maxRarity.getRarityColors().last;
              final tabs = [
                s.description,
              ];

              if (state.charImages.isNotEmpty) {
                tabs.add(s.builds);
              }

              if (state.droppedBy.isNotEmpty) {
                tabs.add(s.droppedBy);
              }
              final imgSize = SizeUtils.getSizeForCircleImages(context);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 40,
                    child: DetailTopLayout(
                      color: rarityColor,
                      appBar: const DetailAppBar(),
                      fullImage: state.image,
                      charDescriptionHeight: 120,
                      generalCard: DetailGeneralCard(
                        rarity: state.maxRarity,
                        itemName: state.name,
                        color: rarityColor,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 60,
                    child: DetailTabLandscapeLayout(
                      color: rarityColor,
                      tabs: tabs,
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ItemDescriptionDetail(
                                  title: s.bonus,
                                  body: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                    child: ArtifactStats(bonus: state.bonus),
                                  ),
                                  textColor: rarityColor,
                                ),
                              ),
                              ItemDescriptionDetail(
                                title: s.pieces,
                                body: Wrap(
                                  alignment: WrapAlignment.center,
                                  children: state.images
                                      .map(
                                        (e) => Container(
                                          margin: Styles.edgeInsetAll5,
                                          child: Image.file(File(e), width: imgSize * 2, height: imgSize * 2),
                                        ),
                                      )
                                      .toList(),
                                ),
                                textColor: rarityColor,
                              ),
                            ],
                          ),
                        ),
                        if (state.charImages.isNotEmpty)
                          SingleChildScrollView(
                            child: ItemDescriptionDetail(
                              title: s.builds,
                              body: Wrap(
                                alignment: WrapAlignment.center,
                                children: state.charImages.map((e) => CharacterIconImage(itemKey: e.key, image: e.iconImage, size: imgSize)).toList(),
                              ),
                              textColor: rarityColor,
                            ),
                          ),
                        if (state.droppedBy.isNotEmpty)
                          SingleChildScrollView(
                            child: ItemDescriptionDetail(
                              title: s.droppedBy,
                              body: Wrap(
                                alignment: WrapAlignment.center,
                                children: state.droppedBy.map((e) => CircleMonster(itemKey: e.key, image: e.image, radius: imgSize)).toList(),
                              ),
                              textColor: rarityColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
