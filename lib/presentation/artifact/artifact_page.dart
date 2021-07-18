import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/artifacts/widgets/artifact_stats.dart';
import 'package:genshindb/presentation/shared/circle_character.dart';
import 'package:genshindb/presentation/shared/circle_monster.dart';
import 'package:genshindb/presentation/shared/details/detail_appbar.dart';
import 'package:genshindb/presentation/shared/details/detail_bottom_portrait_layout.dart';
import 'package:genshindb/presentation/shared/details/detail_general_card.dart';
import 'package:genshindb/presentation/shared/details/detail_tab_landscape_layout.dart';
import 'package:genshindb/presentation/shared/details/detail_top_layout.dart';
import 'package:genshindb/presentation/shared/extensions/rarity_extensions.dart';
import 'package:genshindb/presentation/shared/item_description_detail.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/scaffold_with_fab.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/shared/utils/size_utils.dart';

class ArtifactPage extends StatelessWidget {
  final double imgHeight = 350;

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return isPortrait ? const _PortraitLayout() : const _LandscapeLayout();
  }
}

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ScaffoldWithFab(
      child: BlocBuilder<ArtifactBloc, ArtifactState>(
        builder: (context, state) {
          return state.map(
            loading: (_) => const Loading(useScaffold: false),
            loaded: (state) {
              final rarityColor = state.rarityMax.getRarityColors().last;
              final size = SizeUtils.getSizeForCircleImages(context);
              return Stack(
                fit: StackFit.passthrough,
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  CommonDetailTopLayout(
                    color: rarityColor,
                    fullImage: state.image,
                    charDescriptionHeight: 120,
                    appBar: const DetailAppBar(),
                    isAnSmallImage: true,
                    generalCard: DetailGeneralCard(
                      rarity: state.rarityMax,
                      itemName: state.name,
                      color: rarityColor,
                    ),
                  ),
                  CommonDetailBottomPortraitLayout(
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
                              .map((e) => Container(
                                    margin: Styles.edgeInsetAll5,
                                    child: Image.asset(e, width: size * 2, height: size * 2),
                                  ))
                              .toList(),
                        ),
                        textColor: rarityColor,
                      ),
                      if (state.charImages.isNotEmpty)
                        ItemDescriptionDetail(
                          title: s.builds,
                          body: Wrap(
                            alignment: WrapAlignment.center,
                            children: state.charImages.map((e) => CircleCharacter(image: e, radius: size)).toList(),
                          ),
                          textColor: rarityColor,
                        ),
                      if (state.droppedBy.isNotEmpty)
                        ItemDescriptionDetail(
                          title: s.droppedBy,
                          body: Wrap(
                            alignment: WrapAlignment.center,
                            children: state.droppedBy.map((e) => CircleMonster(image: e, radius: size)).toList(),
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
  const _LandscapeLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ArtifactBloc, ArtifactState>(
          builder: (ctx, state) => state.map(
            loading: (_) => const Loading(useScaffold: false),
            loaded: (state) {
              final rarityColor = state.rarityMax.getRarityColors().last;
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
                    child: CommonDetailTopLayout(
                      color: rarityColor,
                      appBar: const DetailAppBar(),
                      fullImage: state.image,
                      charDescriptionHeight: 120,
                      heightOnLandscape: size.height * 0.7,
                      generalCard: DetailGeneralCard(
                        rarity: state.rarityMax,
                        itemName: state.name,
                        color: rarityColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CommonDetailTabLandscapeLayout(
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
                                      .map((e) =>
                                          Container(margin: Styles.edgeInsetAll5, child: Image.asset(e, width: imgSize * 2, height: imgSize * 2)))
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
                                children: state.charImages.map((e) => CircleCharacter(image: e, radius: imgSize)).toList(),
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
                                children: state.droppedBy.map((e) => CircleMonster(image: e, radius: imgSize)).toList(),
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
