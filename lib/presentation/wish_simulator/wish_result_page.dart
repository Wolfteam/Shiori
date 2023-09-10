import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/wish_simulator/widgets/wish_result_item.dart';

class WishResultPage extends StatelessWidget {
  final int index;
  final int qty;
  final WishSimulatorBannerItemsPerPeriodModel period;

  const WishResultPage({
    required this.index,
    required this.qty,
    required this.period,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => Injection.wishSimulatorResultBloc..add(WishSimulatorResultEvent.init(bannerIndex: index, pulls: qty, period: period)),
      child: Scaffold(
        body: SafeArea(
          child: Ink(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.wishBannerResultBackgroundImgPath),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, right: 20),
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    backgroundColor: Styles.wishButtonBackgroundColor,
                    radius: 20,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      splashRadius: Styles.mediumButtonSplashRadius,
                      icon: const Icon(Icons.close),
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => Center(
                      child: Container(
                        height: constraints.maxWidth * 0.6,
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight * 0.8,
                          minHeight: constraints.maxHeight * 0.4,
                        ),
                        alignment: Alignment.center,
                        margin: Styles.edgeInsetHorizontal16,
                        child: BlocBuilder<WishSimulatorResultBloc, WishSimulatorResultState>(
                          builder: (context, state) => state.maybeMap(
                            loaded: (state) => ListView.builder(
                              shrinkWrap: true,
                              itemCount: state.results.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => state.results[index].map(
                                character: (char) => WishResultItem.character(
                                  image: char.image,
                                  rarity: char.rarity,
                                  elementType: char.elementType,
                                ),
                                weapon: (weapon) => WishResultItem.weapon(
                                  image: weapon.image,
                                  rarity: weapon.rarity,
                                  weaponType: weapon.weaponType,
                                ),
                              ),
                            ),
                            orElse: () => const Loading(useScaffold: false),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
