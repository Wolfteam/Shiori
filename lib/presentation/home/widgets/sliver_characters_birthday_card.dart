import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/character/character_page.dart';
import 'package:shiori/presentation/home/widgets/main_title.dart';
import 'package:shiori/presentation/shared/images/character_icon_image.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';

class SliverCharactersBirthdayCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SliverToBoxAdapter(
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (ctx, state) => switch (state) {
          HomeStateLoading() => const Loading(useScaffold: false),
          final HomeStateLoaded state when state.characterImgBirthday.isEmpty => const SizedBox.shrink(),
          HomeStateLoaded() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MainTitle(title: s.todayBirthdays),
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
          ),
        },
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
    return Container(
      margin: Styles.edgeInsetHorizontal10,
      width: Styles.birthdayCardWidth,
      child: InkWell(
        borderRadius: Styles.homeCardItemBorderRadius,
        onTap: () => CharacterPage.route(item.key, context),
        child: AbsorbPointer(
          child: Card(
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(borderRadius: Styles.homeCardItemBorderRadius),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Image.asset(
                          Assets.cakeIconPath,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      Tooltip(
                        message: s.happyBirthday,
                        child: Text(
                          s.happyBirthday,
                          style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CharacterIconImage.squareItem(item: item),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
