import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/home/widgets/main_title.dart';
import 'package:shiori/presentation/shared/images/circle_character.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';

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
                        itemBuilder: (ctx, index) => _CakeCard(item: state.characterImgBirthday[index]),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _CakeCard extends StatelessWidget {
  final ItemCommon item;

  const _CakeCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return SizedBox(
      width: Styles.birthdayCardWidth,
      child: Card(
        margin: Styles.edgeInsetAll5,
        shape: Styles.cardShape,
        child: Row(
          children: [
            Flexible(
              flex: 50,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(Assets.cakeIconPath, width: 120, height: 120),
                  //The cake has some space in the top and bottom, that's why we used this offset here
                  FractionalTranslation(
                    translation: const Offset(0, -0.5),
                    child: Tooltip(
                      message: s.happyBirthday,
                      child: Text(
                        s.happyBirthday,
                        style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
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
              child: CircleCharacter.fromItem(item: item, radius: 55),
            ),
          ],
        ),
      ),
    );
  }
}
