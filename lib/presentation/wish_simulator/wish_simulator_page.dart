import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/banner_history/banner_history_page.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/wish_simulator/widgets/banner_main_image.dart';
import 'package:shiori/presentation/wish_simulator/widgets/banner_top_image.dart';
import 'package:shiori/presentation/wish_simulator/widgets/wish_button.dart';

class WishSimulatorPage extends StatefulWidget {
  @override
  State<WishSimulatorPage> createState() => _WishSimulatorPageState();
}

class _WishSimulatorPageState extends State<WishSimulatorPage> {
  final centerPageController = PageController();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocProvider<WishSimulatorBloc>(
      create: (context) => Injection.wishSimulatorBloc..add(const WishSimulatorEvent.init()),
      child: Scaffold(
        body: SafeArea(
          child: Ink(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.wishBannerBackgroundImgPath),
                fit: BoxFit.fill,
              ),
            ),
            child: BlocListener<WishSimulatorBloc, WishSimulatorState>(
              listener: (context, state) {
                if (centerPageController.hasClients) {
                  state.maybeMap(
                    loaded: (state) => centerPageController.jumpToPage(
                      state.selectedBannerIndex,
                      // duration: const Duration(milliseconds: 300),
                      // curve: Curves.easeInOut,
                    ),
                    orElse: () {},
                  );
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          flex: 15,
                          fit: FlexFit.tight,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.chevron_left),
                              iconSize: 50,
                              color: Colors.black,
                              splashRadius: Styles.mediumBigButtonSplashRadius,
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 70,
                          child: _CenterTopPageView(),
                        ),
                        Flexible(
                          flex: 15,
                          fit: FlexFit.tight,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: IconButton(
                              onPressed: () => _showBannerListSelector(context),
                              icon: const Icon(Icons.settings),
                              iconSize: 50,
                              color: Colors.black,
                              splashRadius: Styles.mediumBigButtonSplashRadius,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: _CenterPageView(
                      controller: centerPageController,
                      maxImageHeight: getValueForScreenType<double>(
                        context: context,
                        mobile: 200,
                        tablet: 400,
                        desktop: 400,
                      ),
                      maxImageWidth: getValueForScreenType<double>(
                        context: context,
                        mobile: 600,
                        tablet: 900,
                        desktop: 900,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: Styles.edgeInsetAll10,
                      child: BlocBuilder<WishSimulatorBloc, WishSimulatorState>(
                        builder: (context, state) => state.map(
                          loading: (_) => const SizedBox.shrink(),
                          loaded: (state) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Spacer(),
                              WishButton(
                                imagePath: state.wishIconImage,
                                quantity: 1,
                                onTap: (qty) => _wish(context, state.selectedBannerIndex, qty),
                              ),
                              WishButton(
                                imagePath: state.wishIconImage,
                                quantity: 10,
                                onTap: (qty) => _wish(context, state.selectedBannerIndex, qty),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showBannerListSelector(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WishBannerHistoryPage()),
    );
  }

  void _wish(BuildContext context, int index, int qty) {
    context.read<WishSimulatorBloc>().add(WishSimulatorEvent.wish(index: index, quantity: qty));
  }
}

class _CenterTopPageView extends StatelessWidget {
  const _CenterTopPageView();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      child: BlocBuilder<WishSimulatorBloc, WishSimulatorState>(
        builder: (context, state) => state.map(
          loading: (_) => const SizedBox.expand(),
          loaded: (state) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: state.period.banners.mapIndex(
                (e, index) {
                  final selected = state.selectedBannerIndex == index;
                  return BannerTopImage(
                    index: index,
                    imagesPath: e.promotedItems.map((e) => e.image).toList(),
                    width: 200,
                    height: selected ? 70 : 60,
                    selected: selected,
                    onTap: (index) => context.read<WishSimulatorBloc>().add(WishSimulatorEvent.bannerSelected(index: index)),
                  );
                },
              ).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterPageView extends StatelessWidget {
  final double maxImageWidth;
  final double maxImageHeight;
  final PageController controller;

  const _CenterPageView({
    required this.maxImageWidth,
    required this.maxImageHeight,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    double maxWidth = maxImageWidth;
    final width = MediaQuery.of(context).size.width;
    if (width - maxWidth < 0) {
      maxWidth = width * 0.9;
    }
    final margin = ((width - maxWidth) / 2).abs();
    return SizedBox(
      height: maxImageHeight,
      child: BlocBuilder<WishSimulatorBloc, WishSimulatorState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading(useScaffold: false),
          loaded: (state) => PageView.builder(
            itemCount: state.period.banners.length,
            controller: controller,
            onPageChanged: (index) => context.read<WishSimulatorBloc>().add(WishSimulatorEvent.bannerSelected(index: index)),
            itemBuilder: (context, index) {
              final banner = state.period.banners[index];
              String topTitle;
              Color color;
              switch (banner.type) {
                case BannerItemType.character:
                  topTitle = 'Character Event Wish';
                  color =
                      banner.characters.firstWhere((c) => c.key == banner.promotedItems.first.key).elementType.getElementColorFromContext(context);
                  break;
                case BannerItemType.weapon:
                  topTitle = 'Weapon Event Wish';
                  color = Colors.orange;
                  break;
                case BannerItemType.standard:
                  topTitle = 'Standard Event Wish';
                  color = Colors.deepPurple;
                  break;
              }
              return BannerMainImage(
                topTitle: topTitle,
                topTitleColor: color,
                imagePath: state.period.banners[index].image,
                margin: margin,
                imageWidth: maxWidth,
              );
            },
          ),
        ),
      ),
    );
  }
}
