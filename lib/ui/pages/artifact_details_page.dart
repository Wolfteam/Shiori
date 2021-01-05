import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bloc.dart';
import '../../common/extensions/rarity_extensions.dart';
import '../../common/styles.dart';
import '../../generated/l10n.dart';
import '../../models/models.dart';
import '../widgets/artifacts/artifact_stats.dart';
import '../widgets/common/circle_character.dart';
import '../widgets/common/item_description_detail.dart';
import '../widgets/common/loading.dart';
import '../widgets/common/rarity.dart';

class ArtifactDetailsPage extends StatelessWidget {
  final double imgHeight = 350;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocBuilder<ArtifactDetailsBloc, ArtifactDetailsState>(
            builder: (context, state) {
              return state.map(
                loading: (_) => const Loading(useScaffold: false),
                loaded: (s) => Stack(
                  fit: StackFit.passthrough,
                  clipBehavior: Clip.none,
                  children: [
                    _buildTop(s.name, s.rarityMax, s.image, context),
                    _buildBottom(s.rarityMax, s.images, s.bonus, s.charImages, context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTop(
    String name,
    int rarity,
    String image,
    BuildContext context,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final descriptionWidth = mediaQuery.size.width / (isPortrait ? 1.2 : 2);
    //TODO: IM NOT SURE HOW THIS WILL LOOK LIKE IN BIGGER DEVICES
    // final padding = mediaQuery.padding;
    // final screenHeight = mediaQuery.size.height - padding.top - padding.bottom;

    return Container(
      color: rarity.getRarityColors().last,
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: Container(
              transform: Matrix4.translationValues(60, -30, 0.0),
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(image, width: imgHeight),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Image.asset(
              image,
              width: 340,
              height: imgHeight,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: descriptionWidth,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: _buildGeneralCard(name, rarity, context),
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(backgroundColor: Colors.transparent, elevation: 0.0),
          ),
        ],
      ),
    );
  }

  Widget _buildBottom(
    int rarity,
    List<String> images,
    List<ArtifactCardBonusModel> bonus,
    List<String> charImgs,
    BuildContext context,
  ) {
    final s = S.of(context);
    final items = images
        .map((e) => Container(margin: Styles.edgeInsetAll5, child: Image.asset(e, width: 90, height: 90)))
        .toList();
    return Card(
      margin: const EdgeInsets.only(top: 300, right: 10, left: 10),
      shape: Styles.cardItemDetailShape,
      child: Padding(
        padding: Styles.edgeInsetAll10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: ItemDescriptionDetail(
                title: s.bonus,
                body: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: ArtifactStats(bonus: bonus),
                ),
                textColor: rarity.getRarityColors().last,
              ),
            ),
            ItemDescriptionDetail(
              title: s.pieces,
              body: Wrap(
                alignment: WrapAlignment.center,
                children: items,
              ),
              textColor: rarity.getRarityColors().last,
            ),
            if (charImgs.isNotEmpty)
              ItemDescriptionDetail(
                title: s.builds,
                body: Wrap(
                  alignment: WrapAlignment.center,
                  children: charImgs.map((e) => CircleCharacter(image: e)).toList(),
                ),
                textColor: rarity.getRarityColors().last,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralCard(
    String name,
    int rarity,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: theme.textTheme.headline5.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
        Rarity(stars: rarity, starSize: 25, alignment: MainAxisAlignment.start),
      ],
    );
    return Card(
      color: rarity.getRarityColors().last.withOpacity(0.1),
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Padding(padding: Styles.edgeInsetAll10, child: details),
    );
  }
}
