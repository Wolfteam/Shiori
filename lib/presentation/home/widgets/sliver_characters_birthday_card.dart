import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/images/circle_character.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/styles.dart';

import 'main_title.dart';

class SliverCharactersBirthdayCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SliverToBoxAdapter(
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (ctx, state) => state.map(
          loading: (_) => const Loading(useScaffold: false),
          loaded: (state) => state.characterImgBirthday.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: MainTitle(title: s.todayBirthdays),
                    ),
                    SizedBox(
                      height: Styles.homeCardHeight,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: state.characterImgBirthday.length,
                        itemBuilder: (ctx, index) => _CakeCard(image: state.characterImgBirthday[index]),
                      ),
                    ),
                  ],
                )
              : Container(),
        ),
      ),
    );
  }
}

class _CakeCard extends StatelessWidget {
  final String image;

  const _CakeCard({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return SizedBox(
      width: Styles.birthdayCardWidth,
      child: Card(
        margin: Styles.edgeInsetAll10,
        shape: Styles.cardShape,
        child: Row(
          children: [
            Flexible(
              flex: 50,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(Assets.getOtherMaterialPath('cake.png'), width: 120, height: 120),
                  //The cake has some space in the top and bottom, that's why we used this offset here
                  FractionalTranslation(
                    translation: const Offset(0, -0.5),
                    child: Tooltip(
                      message: s.happyBirthday,
                      child: Text(
                        s.happyBirthday,
                        style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 50,
              fit: FlexFit.tight,
              child: CircleCharacter(image: image, radius: 55),
            )
          ],
        ),
      ),
    );
  }
}
